---
title: "Datastream for BigQueryでパーティション分割テーブルにストリーミングする方法メモ"
emoji: "👀"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Datastream", "BigQuery"]
published: true
---

# Datastream for BigQuery でストリーミング連携する際、パーティション分割テーブルを指定できない。

Datastream のコンソール画面からパーティションの設定は出来ませんでした。

## 試した方法

### 1. 最初にパーティション分割テーブルを作成しておいて、そこにストリーミングする

最初にパーティション分割テーブルを同じ名前で用意しておいて

```bash
bq mk --table \
--schema ./schema.json \
--time_partitioning_field <field name> \
--require_partition_filter \
<project_id:dataset.table>
```

上のコマンドでパーティション分割テーブルを作成後、ストリームを開始してみるが、以下のエラーが出る。

```text
Discarded 1265 unsupported events for BigQuery destination: <table>, with reason code: BIGQUERY_UNSUPPORTED_PRIMARY_KEY_CHANGE, details: Failed to write to BigQuery due to an unsupported primary key change: adding primary keys to existing tables is not supported..
```

以下の記事を参考に、
https://medium.com/google-cloud/configure-streams-in-datastream-with-predefined-tables-in-bigquery-for-postgresql-as-source-528340f7989b

この SQL を実行してみたがエラー、、

```bash
bq query --use_legacy_sql=false '
CREATE OR REPLACE TABLE  `project_id.dataset.table`
  (
  id INTEGER,
  ...
  datastream_metadata STRUCT<uuid STRING, source_timestamp INT64>,
    PRIMARY KEY (id) NOT ENFORCED)
PARTITION BY <partitioning field name>
CLUSTER BY <clustering field name>
OPTIONS(max_staleness = INTERVAL 15 MINUTE);
'
#  BigQuery error in query operation: Error processing job '': Incompatible table partitioning specification. Expected partitioning specification  clustering(id), but input partitioning specification is interval(type:day,field:<partitioning field name>) clustering(<clustering field name>)
```

⇒ id 列とパーティション列とクラスタリング列の指定が間違っているぽいが、よく分からない。。

### 2. ストリーム作成後に update してパーティション化を試みる

既存のテーブルのスキーマを取得

```bash
bq show \
--schema \
--format=prettyjson \
project_id:dataset.table > schema.json
```

既存テーブルのスキーマを指定して update してみる

```bash
bq update --table --schema ./schema.json --time_partitioning_field <field name> --require_partition_filter <project_id:dataset.table>
#  BigQuery error in update operation: Cannot convert non partitioned table to partitioned table.
```

⇒ 上のようなエラーが発生。後からパーティション分割テーブルに変更することはできない!

### 3. ストリーム作成後に、既存のテーブルを一旦 GCS にコピーして、別名でパーティション分割テーブルを作成、その後データを戻してからリネームする

この記事を参考にすると、
https://medium.com/google-cloud/how-to-modify-bigquery-table-definition-at-no-costs-2c59a1073cbb

BigQuery 内での SQL だけでも出来るが、フルスキャンが発生してコストがかかる。そこで GCS を経由することでフルスキャンを避けてノーコストでいける！

試してみる。

```bash
export MY_BUCKET=<bucket name>
export PROJECT_NAME=<project name>
export DATASET=<dataset name>
export TABLE=<table name>

---
# Create a new Google Cloud Storage (GCS) bucket
gsutil mb -l asia-northeast1 -p ${PROJECT_NAME}  gs://${MY_BUCKET}

---
# Dump the content of the table to the bucket
bq extract \
--destination_format NEWLINE_DELIMITED_JSON \
--print_header=true \
${PROJECT_NAME}:${DATASET}.${TABLE}  gs://${MY_BUCKET}/${TABLE}*
# It is important to provide wildcard * at the end of the filename, because it is not possible to extract from BQ to GCS table of size bigger than 1GB. If we specify *, bq extract will split the exported data to multiple files.

---
# Export the schema of the original table. It will be used in the next step.
bq show \
--format=prettyjson \
${PROJECT_NAME}:${DATASET}.${TABLE} \
| jq '.schema.fields' > schema_${TABLE}.json

---
# Load the data to the new BQ table which is partitioned hourly and it's schema matches the original table.
bq load \
--source_format=NEWLINE_DELIMITED_JSON \
--time_partitioning_type=DAY \
--time_partitioning_field=<partitioning field name> \
--clustering_fields <clustering field name> \
${PROJECT_NAME}:${DATASET}.${TABLE}_partitioned \
gs://${MY_BUCKET}/${TABLE}* ./schema_${TABLE}.json
# Note, there is a limitation to the bq load, that a single job can load at most 15 TB. If our data is bigger, we need to split the payload to multiple load jobs.

---
# Switch tables. Remove the original one
bq rm ${PROJECT_NAME}:${DATASET}.${TABLE} && \
bq query --use_legacy_sql=false "ALTER TABLE ${DATASET}.${TABLE}_partitioned RENAME TO ${TABLE};"

# Clean up. Delete the bucket to ensure that you do not pay for storage costs
gsutil -m rm gs://${MY_BUCKET}
```

⇒ 上記実行後、ロギングを確認すると、次のような Warning が出て上手くいっていない。。

```text
BIGQUERY_UNSUPPORTED_PRIMARY_KEY_CHANGE, details: Failed to write to BigQuery due to an unsupported primary key change: adding primary keys to existing tables is not supported
```

やはり後からパーティション分割テーブルにしても、上手くストリーミングできないようだ。。

(追記)
この公式ページにも一旦ストリームを停止してからテーブルを作成して、データをロードするという、上で試した方法が書いてあるが、
https://cloud.google.com/datastream/docs/best-practices-stream-data#partition-replica-datasets
Datastream for BigQuery(preview)だと、上手くいかなかった。。
少なくとも現状は、Datastream -> GCS -> pubsub -> Dataflow -> BigQuery の Google 提供テンプレートを使う場合に限られるみたい？

## 解決した方法

下記の イシュートラッカー を見ると、上記 3.の方法は、「Datastream の CDC では」対応できないらしい。

> however this approach won't work for existing Datastream sourced tables **since there wouldn't be a \_CHANGE_SEQUENCE_NUMBER field which is required to correctly apply UPSERT operations in the correct order**. So the only option would be to pre-create the table with partitioning/clustering/primary keys before starting the Datastream stream like the below DDL SQL sample query.、

イシュートラッカー
https://issuetracker.google.com/issues/250938168

上記イシュートラッカーを見ると、以下の DDL をしてからストリームすればいいと書いてある。よく見ると、**Primarykey と、Clustering に同じカラムを指定することがマスト**のようだ。

> CLUSTER BY
> Primary_key_field #This must be an exact match of the specified primary key fields

これを試してみる

```bash
bq query --use_legacy_sql=false "CREATE OR REPLACE TABLE ${DATASET}.${TABLE} (
   id INTEGER PRIMARY KEY NOT ENFORCED,
   ...
   datastream_metadata STRUCT<uuid STRING, source_timestamp INT64> )
PARTITION BY
 <partitioning field name>
CLUSTER BY
  id
OPTIONS(max_staleness = INTERVAL 15 MINUTE);
"
```

⇒ これで上手くいった!
