---
title: "BigQuery上のデータ基盤へのE(T)L処理でDigdag+embulkとWorkflows + Dataflowの構成を比較してみた"
emoji: "🔖"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["BigQuery", "embulk", "Digdag", "Dataflow", "ETL", "dbt", "GCP"]
published: true
---

## はじめに

BigQuery 上に新しいデータ基盤を構築する際に、外部からデータ連携する E(T)L について、構成を検討したときのメモ

## 前提

- 旧連携システムでは GCE 上に構築した API サーバーを CloudSchedular と CloudFunction でトリガーし、embulk を使って転送する構成になっている。これをサーバーレスサービス主体で刷新したい。
- GCP 環境に構築する。
- trocco や Fivetran などの SaaS は使わない。
- 将来的にストリーミングにも対応したい。

## 検討した構成

1. Cloud Workflows + Dataflow
2. Digdag + embulk on GKE Autopilot

※ Cloud Run は途中でジョブ停止出来ないことや、最大 1h のタイムアウト制限(呼び出し側で待つ必要があるが、PubSub にしろ Schedular、Workflows、GAS、いずれも先にタイムアウトしてしまう)など、時間のかかるバッチ処理向きではないので除外した。

---

## 比較

### コネクタ・プラグイン

連携先の仕様変化に追従してくれないと後で困ることになる。もしくは簡単に自作できるか？

- embulk

https://plugins.embulk.org/

- Apache beam connector

https://beam.apache.org/documentation/io/connectors/
⇒ ちょっと少ない。Postgres とかないが、JDBC ドライバ経由でアクセスできる。元々 Google が開発したので、GCP のサービスとの連携には困らないのだろう。

trocco や Fivetran などの SaaS や、OSS の Airbyte などと比べると、総じて貧弱に見える。。

### コスト

Digda ＋ embulk は複数ワークロードを実行する際にオートスケールできないので、コストが高くなる可能性がある。

下記の記事では Dataflow を使うことでコスト最適化されたことを紹介している。

https://techblog.zozo.com/entry/data-infrastructure-replacement

> 全てのテーブル連携が完了するまでワーカをスケールインできませんでした

> Dataflow を用いることで、ワーカのスケールアウトが不要になり、約 85％のコスト削減に繋がりました。

サーバレスでオートスケールする Dataflow が有利に見えるが、Digdag を GEK Autopilot 環境で運用＋ Command Executor の機能を使って Worker のリソースを抑えつつ、動的に Task の Pod を作成することでコストを抑えられるみたい。下記記事で紹介されている。

https://techblog.zozo.com/entry/digdag-on-gke-autopilot#Kubernetes%20Command%20Executor%E3%81%AE%E5%88%A9%E7%94%A8

さらに、転送系とジョブ管理系でサーバー(Pod)を分けることで、なんらかの理由で負荷が高くなった時に転送タスクが滞る、といったことがなくなるはず。

ただし、以下のような問題はあるだろう。

1. タスク毎に最適なリソースを定義したマニュフェストを元にジョブを起動できるという話なので、Dataflow のような分散処理とはそもそも違う。巨大なテーブルの転送では Dataflow が有利だろう。
2. ポッドの起動に時間がかかるので、Dataflow に対するパフォーマンス上の優位性は薄くなる。(Dataflow は起動が遅い)

### 運用

- パフォーマンス・安定性

  - Dataflow は起動が遅いので、マイクロバッチは難しそう。それらはストリーミングにするしかない。残りはバッチにする。この点、ほぼ同じコードでストリーミングもバッチも出来るのは便利である。

  - データ読み込みから連携まで並列処理できる Digdag + embulk の方がパフォーマンスには優れるぽいが、前述の Command Executor を使う場合は pod の起動に時間かかるらしいので、結局同じかも。

  - 巨大なテーブルの転送は並列分散処理ができる Dataflow が有利。

  - embulk を採用する場合は、とってきたデータを JSON でダンプするため、ディスク容量が枯渇して転送処理が失敗することもたまにある。

- 監視、リトライ
  Digdag UI の方がやりやすそうではあるが、Dataflow + workflows でも管理画面からジョブの監視や管理が出来る。Dataflow は逐次処理できないが、Workflows を使えばよい。
- サーバー管理 vs サーバーレス
  Dataflow はサーバレスなので管理が楽。
- リソース管理、セキュリティ
  連携の設定ファイルや GCP リソースなど、すべてリポジトリで管理して、CloudBuild で展開する。セキュリティはポリシータグ + DLP API をとりあえず想定。Dataflow では一つのパイプラインの中で DLP API で処理できるので便利。

### 拡張・移植性

- Digdag + embulk はサーバーを管理する必要があるが、k8s で運用すれば移植性は上がる。
- CDC を使ったリアルタイム連携は Datastream が有力だが、DataFlow を経由すれば、バッチと共通化できる。
  ※プレビューの Datastream for Bigquery を使えば Dataflow は不要かも。
- 数千万や数億レコードあるようなテーブルは今のところないが、将来的にそのようなテーブルを連携する場合、分散処理が簡単にできる Dataflow の方が向いているかも。
- 機械学習モデルによる推論とか特徴生成、TFRecord の連携とかは Dataflow のパイプラインの中で出来るので便利。
- リバース ETL のようなデータ活用をしていく場合、Digdag + embulk や Dataflow でなく、OSS の Airbyte とか Saas の torocco とかが向いていそう。

### その他

- 全量洗い替えはソースシステムへの負荷ぎ大きいし、転送サーバーでのメモリも必要だが、転送先 BigQuery テーブルのスキャンは不要。逆に CDC だと逆転する。毎回 BigQuery の全量スキャンが発生する。どっちがコスト安くなるか検討する必要あり。(dbt の Incremental モデルとかでも、毎回全量スキャンしているのだろうか？)
- ETL va ELT
  ETL だとデータ変換処理(T:Transform)の分散化・多言語化で保守が大変になっていく。EL のリトライに比べ、ETL はリトライのコストも高くなる。EL + T に分けて、一旦取り込んだ後に変換用の共通処理基盤を作ったほうが良い。Transform の処理は dbt に集約する。

---

## まとめ

ストリーミングもする予定なので、EL 処理でも Dataflow ＋ Workflows を使う方針にした。サーバー管理しなくていいし、タグでのセキュリティ管理や、機械学習、DLP とか GCP の他のサービスとの相性も良さそうなので。

---

## 終わりに

今回は保留したが、Airbyte もよさそうなのでちょっと調べてみた。今後に期待したい。

https://github.com/airbytehq/airbyte

良さそうな点

- コネクタがとても充実している。

https://docs.airbyte.com/connector-development/?_ga=2.134824561.1243803100.1669727678-99584845.1669727678

- Python、JS などでコネクタ自作もできる。
- GUI ベースで設定が簡単。
- Reverse ETL でも使える。
- dbt と相性よく(内部では dbt で動作している)、自作の dbt の処理を実行することも可能。

気になる点

- GUI ベースで簡単に設定できる反面、コード管理がまだやりにくそう。

https://airbyte.com/tutorials/version-control-airbyte-configurations

- 勢いはあるが未成熟。

他にも、カラムレベルの Lineage を可視化できるツールも探したらたくさんあったので、こちらも後で調査したい。DataHub や Amundsen などのツールが人気ある模様。

https://github.com/datahub-project/datahub
