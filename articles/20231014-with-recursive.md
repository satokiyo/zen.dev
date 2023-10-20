---
title: "BigQueryのINFORMATION_SCHEMAから再帰CTEを使ってリネージをたどり、派生先まで含めたテーブルの参照回数を取得する"
emoji: "📈"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["BigQuery", "SQL"]
published: true
---

### BigQuery の INFORMATION_SCHEMA.JOBS_BY_XXX ビュー：テーブルの親子関係を隣接リストとして保持しているビュー

BigQuery では、SQL ジョブの実行メタデータは、INFORMATION_SCHEMA の JOBS_BY_XXX ビューに記録されています。

https://cloud.google.com/bigquery/docs/information-schema-intro?hl=ja

このビューには、実行されるジョブごとに、そこで参照されるテーブル（親）と派生先のテーブル（子）を含むイベント情報が記録されます。このイベント情報がテーブル間の関連を表現し、ジョブによるテーブル間の親子関係のグラフを形成します。

親子関係にあるテーブルが循環依存しないように「ちゃんと」管理されている場合、このグラフは閉路のない木 (tree)として考えることが出来ます。なので、INFORMATION_SCHEMA.JOBS_BY_XXX ビューは、親子関係にあるテーブルの（階層的な）木を表現したテーブルであると捉えることができます。

このようにテーブルの関連をリストの形式で表現する方法は隣接リストモデル（adjacency list model）と呼ばれるようです。（※ただし、RDB においてこれはナイーブツリーと呼ばれるアンチパターンです）

### 階層構造を持つ木への再帰的なクエリ実行：再帰 CTE

複雑なグラフデータモデルをデータベースで扱う場合、グラフデータベースを使うのが自然です。しかし、木のような簡単なグラフデータであれば、RDB でも扱うことができます。

グラフデータは頂点と辺の 2 つのテーブルで表現できますが、上記のように隣接リストを使って一つのテーブルでも表現できます。これは、many-to-many の関係で自己再帰関連するテーブルの中間テーブルのようなモデルといえそうです。

階層構造を持つ木に対してクエリを実行する場合、グラフクエリを使用するとデータの関連性を自然に表現することが出来ますが、SQL クエリでは木の深さを事前に知る必要があり、クエリも複雑になります。そこで再帰 CTE を使用します。

再起 CTE（Common Table Expression）は、SQL:1999 標準で導入された機能で、SQL クエリ内で再帰的な処理を行うためのメカニズムです。これを用いることで、階層的なデータ構造、木構造、またはグラフのような関連データを効率的にクエリできます。

主要な RDBMS は再帰 CTE 構文（WITH RECURSIVE 句）をサポートしていますが、BigQuery でも GA（一般提供） になっています。

https://cloud.google.com/bigquery/docs/recursive-ctes?hl=ja

https://cloud.google.com/bigquery/docs/release-notes#March_02_2023

### 再帰 CTE を使って派生テーブルの参照回数を取得する

今回、再帰 CTE を使って、BigQuery の INFORMATION_SCHEMA からテーブルの親子関係をたどり、派生先のテーブルまで含めたテーブルの参照回数を取得するクエリを作成してみました。

まずは、再帰 CTE を使わずにテーブルの参照回数を取得するクエリです。プロジェクト内のすべてのテーブルの参照回数が一覧で取得できます。INFORMATION_SCHEMA.JOBS_BY_PROJECT のリージョンを適当に変更して実行します。

```sql
SELECT
  CONCAT( referenced_tables.project_id, '.', referenced_tables.dataset_id, '.', referenced_tables.table_id ) AS ref_table_fqn,
  COUNT(1) AS ref_count -- 参照回数
FROM
  `region-us`.INFORMATION_SCHEMA.JOBS_BY_PROJECT
CROSS JOIN
  UNNEST(referenced_tables) AS referenced_tables -- 配列を行へ変換
WHERE
  DATE(creation_time) = CURRENT_DATE() -- creation_timeでパーティション分割されている
  AND job_type = 'QUERY' -- クエリジョブのみを対象にする
  AND statement_type = 'SELECT' -- SELECTクエリのみを対象にする
  AND state = 'DONE' -- 実行完了したジョブのみを対象にする
  AND error_result IS NULL -- 正常終了したジョブのみを対象にする
-- 参照元と派生先のテーブルが同じジョブをグループ化する
GROUP BY 1
ORDER BY
  ref_count desc
```

次に再帰 CTE を使ったクエリです。指定した親テーブルの派生先テーブルの参照回数だけを再帰的に取得します。INFORMATION_SCHEMA.JOBS_BY_PROJECT のリージョンと ref_table_fqn = '<project_id>.<dataset_id>.<table_id>'の箇所を適当に変更して実行します。

```sql
WITH RECURSIVE count_job_list AS (
  SELECT
    CONCAT( destination_table.project_id, '.', destination_table.dataset_id, '.', destination_table.table_id ) AS dest_table_fqn,
    CONCAT( referenced_tables.project_id, '.', referenced_tables.dataset_id, '.', referenced_tables.table_id ) AS ref_table_fqn,
    COUNT(job_id) AS count_job -- ジョブ数をカウントする
  FROM
    `region-us`.INFORMATION_SCHEMA.JOBS_BY_PROJECT
  CROSS JOIN
    UNNEST(referenced_tables) AS referenced_tables -- 配列を行へ変換
  WHERE
    DATE(creation_time) = CURRENT_DATE() -- creation_timeでパーティション分割されている
    AND job_type = 'QUERY' -- クエリジョブのみを対象にする
    AND statement_type = 'SELECT' -- SELECTクエリのみを対象にする
    AND state = 'DONE' -- 実行完了したジョブのみを対象にする
    AND error_result IS NULL -- 正常終了したジョブのみを対象にする
  -- 参照元と派生先のテーブルが同じジョブをグループ化する
  GROUP BY 2,1
),
rec AS (
  SELECT
    parent.dest_table_fqn AS dest_table_fqn,
    parent.ref_table_fqn AS ref_table_fqn,
    parent.count_job AS count_job
  FROM
    count_job_list AS parent
  WHERE
    -- 親(木の根)となるテーブルを指定する。親を起点に派生先の子テーブルの参照数を再帰的に計算する
    ref_table_fqn = '<project_id>.<dataset_id>.<table_id>'
  UNION ALL (
    SELECT
      child.dest_table_fqn AS dest_table_fqn,
      child.ref_table_fqn AS ref_table_fqn,
      child.count_job AS count_job
    FROM
      rec -- 再帰
    INNER JOIN
      count_job_list AS child
    ON
      rec.dest_table_fqn = child.ref_table_fqn -- 親ジョブの出力先テーブルを参照する子ジョブを結合する
  )
)

-- 指定した親の派生テーブル毎に、参照数をカウントする
SELECT
  ref_table_fqn,
  SUM(count_job) AS ref_count
FROM
  rec
GROUP BY
  ref_table_fqn
ORDER BY
  ref_count desc
```

### 確認

結果の参照回数は同じになるはずです。

※ 注意点として、BigQuery がキャッシュに保存された結果を利用する場合、テーブルはスキャンされず、referenced_tables 列の値は空配列になります。そのため、キャッシュヒットしたクエリジョブは参照回数に含まれていません。

https://cloud.google.com/bigquery/docs/cached-results?hl=ja#console
