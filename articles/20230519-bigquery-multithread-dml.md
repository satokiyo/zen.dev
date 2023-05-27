---
title: "BigQueryテーブルに対してマルチスレッドでDMLを発行するときに発生するエラー調査"
emoji: 👀
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["BigQuery"]
published: true
---

## 問題

BigQuery のデータ基盤運用中に、既存の ETL サーバーの不具合により、時折レコードの重複が発生していた。原因を調査した結果、BigQuery のテーブルに対してマルチスレッドで DELETE→INSERT による UPDATE 処理を行っていて、そこでスレッド処理が完了しないエラーが発生してしまうことがあることが判明。その結果、DELETE 処理完了前に INSERT 処理が実行され、重複レコードが発生していた。

この問題について、詳細を調査してみた。

## 原因の調査

子スレッドでの DML 発行箇所でログを出力するように変更。

エラー発生時のログを調査したところ、以下のエラーが出力されている。

```
 Could not serialize access to table due to concurrent update
```

ドキュメントでは次のトラブルシュートに該当する。

> This error can occur when mutating data manipulation language (DML) statements that are running concurrently on the same table conflict with each other, or when the table is truncated during a mutating DML statement. For more information, see DML statement conflicts.

https://cloud.google.com/bigquery/docs/troubleshoot-queries?hl=ja#could_not_serialize_access_to_table_due_to_concurrent_update

上記ドキュメントのリンクへ飛ぶと、以下の記述がある。**同一パーティションに対する同時更新は競合する**らしい。

> Mutating DML statements that run concurrently on a table cause DML statement conflicts when the statements try to mutate the same partition. The statements succeed as long as they don’t modify the same partition. BigQuery tries to rerun failed statements up to three times.

https://cloud.google.com/bigquery/docs/reference/standard-sql/data-manipulation-language#dml_statement_conflicts

（以下、推測）

そもそも、エラーが発生していたテーブルは、パーティション分割テーブルではないが、その場合、テーブル全体が 1 つの大きなパーティションとして扱われるため、パーティション分割ではないテーブルでも同時更新が競合する可能性がある。

言い換えれば、DML 文のマルチスレッド実行は保証されていないことになるのでは？

Google Cloud ブログによると、BigQuery は DML ステートメントの実行に際して、テーブルロックではなく、**楽観的並行性制御（optimistic concurrency control）**という方法を使用している。クエリジョブ開始時のテーブルスナップショットを基準に、DML の処理結果コミット時の変更差分を算出して、他のジョブによる変更内容と競合しないかをチェックする。以前は競合が発生した場合、エラーとなり、アプリケーション側で対処する必要があったらしいが、現在は基準となるスナップショットを更新した上で、3 回までリトライするので、エラー数は大幅に少なくなったらしい。
https://cloud.google.com/blog/ja/products/data-analytics/dml-without-limits-now-in-bigquery

上記を踏まえると、BigQuery の楽観的並行性制御という仕組み上、多くの DML を並列で実行する程、高い確率で DML の競合エラーが発生することになる。**DML 文は本質的にマルチスレッド実行を保証できない。**

## 実際に検証

実際、マルチスレッドでは DML が競合し、シングルスレッドでは競合しないのか、検証してみた。

- マルチスレッドではスレッド数いくつからエラーが出るか？

  - **2 スレッドからエラーが出始める。**
  - スレッド数を増やすと、エラー発生確率が上がっていく。
  - 2,3 スレッドでは多めにタスクを積まないとエラーにならない。

- 大量の DELETE リクエスト文をマルチスレッドで発行するとどうなるか？

  - 次のエラーが発生する。

  ```
  Error: 400 Resources exceeded during query execution: Too many DML statements outstanding against table xxx, limit is 20
  ```

  ⇒ ドキュメントに記載あり。DML ステートメントは最大 20 までキューイングでき、2 つづつ実行される

- 存在しないレコードに対する DELETE 文をマルチスレッドで実行するとエラーになるか？

  - エラーにならない。
    ⇒ クエリジョブを API でリクエスト、キューイングしただけではエラーにならない。実際に 同一パーティションのレコードに対する競合 DELETE 処理が動き、かつ 3 回のリトライですべて競合した場合、エラーになっていると思われる。

- クエリを分割してマルチスレッド実行している箇所をシングルスレッドで実行した場合、エラーになるか？

  - **シングルスレッドではエラーにならない。**

- DELETE 処理を、同一セッション内での マルチステートメントトランザクション処理にしてみる（各 DELETE ステートメントは並列スレッド内で実行）。
  - 以下のエラーが発生。
  ```
  Error: 400 Resources exceeded during query execution: Another job dtechlab-int:asia-northeast1.b2400ebd-84ae-4bcb-9799-49f52d433241 is currently running in the session Cg4KDGR0ZWNobGFiLWludBDJARokOWU4MGNjMzktY2YyMC00YjcyLWEzN2YtMjc5MzU5NDk0ODRh. Concurrent jobs in the same session are not allowed.
  ```
  ⇒ セッション内でのトランザクション処理では並列処理はできないらしい。

https://cloud.google.com/bigquery/docs/troubleshoot-queries?hl=ja#concurrent_jobs_in_the_same_session_are_not_allowed

### 結論として、

- マルチスレッド処理では、2 スレッドからエラーになりうることを確認した。
- シングルスレッド処理では、エラーにならないことを確認した。
- BigQuery が DML ロックを使わないという仕組み上、並列 DML 数が多いほど、競合エラーの発生は高くなる。

## 対処方法

シングルスレッド実行にすることで対処。念のために以下の確認をした。

- 実行時間
- 1 リクエストで DELETE できる最大レコード数

クエリ文字列のバイト数制限は 1MB
https://cloud.google.com/bigquery/quotas#query_jobs
なので、それをもとに概算すると、1 リクエストで DELETE できるレコード数は、DELETE するカラムを特定する複合キーのカラム数や、データ型にもよるが、2 カラムの複合キーだとおよそ 50000 レコードくらいまでいけそう。

実際に試してみると、
| レコード数 | 結果 | 経過時間 (秒) |
|------------|----------|-------------------------------|
| 10 | No Error | 3.0399248600006104 |
| 6500 | No Error | 13.780000925064087 |
| 14600 | No Error | 27.104164361953735 |
| 30000 | No Error | 187.42960047721863 |
| 50000 | ERROR | （下記参照） |

⇒ 50000 レコードの DELETE では、ボディサイズによるエラーは出なかったが、以下のリクエストエラーが発生。1 つのクエリであまりに大量のレコードに アクセスしようとするとエラーになるらしい。
※ スレッドエラーではない

> BadRequest Error: 400 Resources exceeded during query execution: Not enough resources for query planning - too many fields accessed or query is too complex.

https://cloud.google.com/bigquery/docs/troubleshoot-queries#not_enough_resources_for_query_planning_-_too_many_subqueries_or_query_is_too_complex

### 以上、まとめると

- シングルスレッドでの DELETE 処理の実行時間は十分許容範囲内[※]
- クエリを分割しなくても、1 ステートメントで数万行程度の同時削除ができる。

[※] むしろマルチスレッド処理とほぼ変わらない。なぜマルチスレッド処理にしていたのか謎だが、ETL サーバー実装時点での BigQuery には何らかの制約があったのかもしれない

## その他

- ここのベストプラクティスにもあるように、クラスタリングを使うとレコードの特定が早くなるので、DELETE 用のキーとなる列にクラスタリングを適用しておくとよさそう。

https://cloud.google.com/bigquery/docs/reference/standard-sql/data-manipulation-language#best_practices

- そもそも 列指向データベースである BigQuery の設計上、高速同時トランザクションの管理は一般的ではないので、データ基盤の設計時にはよく検討した方がよい。。

## 関連する制約まとめ

- DML ステートメントは最大 20 までキューイングでき、2 つづつ実行される

https://cloud.google.com/bigquery/docs/reference/standard-sql/data-manipulation-language#update_delete_merge_dml_concurrency

- DML は 10s あたり 25 ステートメントまで/table を許容

Quota and limit

https://cloud.google.com/bigquery/quotas#data-manipulation-language-statements

- クエリ文字列のバイト数制限

  - 256 KB (unresolved legacy SQL )
  - 1MB (unresolved GoogleSQL query )

https://cloud.google.com/bigquery/quotas#query_jobs

- 同じセッション内でのクエリの同時実行はエラー(マルチステートメントトランザクションは可能)

https://cloud.google.com/bigquery/docs/troubleshoot-queries?hl=ja#concurrent_jobs_in_the_same_session_are_not_allowed

- クエリが複雑すぎる、または一度に大量のレコードにアクセスしようとしている場合にエラー

https://cloud.google.com/bigquery/docs/troubleshoot-queries?hl=ja#not_enough_resources_for_query_planning_-_too_many_subqueries_or_query_is_too_complex
