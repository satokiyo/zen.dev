---
title: "Datastream for BigQueryでパーティション分割テーブルにストリーミングしても、プルーニングが効かない問題"
emoji: "👀"
type: "tech"
topics:
  - "bigquery"
  - "datastream"
  - "dataflow"
  - "streaming"
published: true
---

:::message
2023.1 時点での検証内容です
:::

# Datastream for BigQuery

GCP Datastream の CDC データを、直接 BigQuery にレプリケートしてくれるサービス(2023/1 時点でプレビュー版)

https://cloud.google.com/datastream-for-bigquery

# やりたいこと

Datastream for BigQuery でソース RDB テーブルからターゲット BigQuery テーブルへストリーミングする際、ターゲットのレプリカテーブルをパーティション分割して、クエリでパーティションプルーニングを効かせたい。
⇒ Datastream の設定画面からパーティション分割を指定することは出来なかった。

# Datastream for BigQuery でターゲットのテーブルをパーティション分割テーブルにする方法

#### 以下のような方法を試したが上手くいかず。

1. 最初にパーティション分割テーブルを作成しておいて、そこにストリーミングする
2. ストリーム作成後に、既存のテーブルへのクエリからパーティション分割テーブルを作成する
   ⇒ 1 と 2 の方法では以下のようなエラーが出る

   ```text
   BIGQUERY_UNSUPPORTED_PRIMARY_KEY_CHANGE, details: Failed to write to BigQuery due to an unsupported primary key change: adding primary keys to existing tables is not supported..
   ```

   :::message
   クエリ結果からテーブルを作成すると、フルスキャンが発生してコストがかかる。そこで GCS を経由することでフルスキャンを避けてノーコストでいける。この記事が参考になる
   https://medium.com/google-cloud/how-to-modify-bigquery-table-definition-at-no-costs-2c59a1073cbb
   :::

3. ストリーム作成後に 既存テーブルを update してパーティション化する
   ⇒ 3 の方法では以下のようなエラーが出る。既存テーブルをパーティション分割テーブルにすることは出来ない。

   ```text
   BigQuery error in update operation: Cannot convert non partitioned table to partitioned table.
   ```

#### 下記の イシュートラッカー を見ると、上記の方法は、「Datastream の CDC では」対応できないらしい。

https://issuetracker.google.com/issues/250938168

> however this approach won't work for existing Datastream sourced tables **since there wouldn't be a \_CHANGE_SEQUENCE_NUMBER field which is required to correctly apply UPSERT operations in the correct order**. So the only option would be to pre-create the table with partitioning/clustering/primary keys before starting the Datastream stream like the below DDL SQL sample query.、

よく見ると、以下の DDL をしてからストリームすればいいと書いてある。**Primarykey と、Clustering に同じカラムを指定することがマスト**のようだ。

> CLUSTER BY
> Primary_key_field #This must be an exact match of the specified primary key fields

#### これを試してみる

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

⇒ 作成したパーティション分割テーブルに対してストリーミングを作成。これでパーティション分割されたターゲットのレプリカテーブルに対してデータがインサートされた。

# クエリのパーティションプルーニングが効かない！

パーティション分割テーブルにレプリケートされたので一件落着と思っていたところ、問題が発覚。パーティションに対するフィルタを指定してクエリしてもスキャン量が減らない。。**プルーニングが効いていない**。

クエリの実行詳細を見ると、**DELTA_CDC_TABLE_xxx**とかいうテーブルから読み込んでいる。

Datastream for BigQuery では、パーティション分割テーブルにしてもそのテーブルから直接スキャンしない仕様になっているようだ。(中間テーブルに対する view のようなもの？)

試しにクエリ結果から新しくパーティション分割テーブルを作成してみる。

```
bq query \
    --use_legacy_sql=false \
    --destination_table <dataset>.<table> \
    --time_partitioning_field <field_name> \
    --time_partitioning_type DAY \
    'select field_name from <dataset>.<table>'
```

⇒ 出力されたテーブルへのクエリでもパーティションのプルーニングが効かない。。

# Google 提供の Dataflow テンプレートでストリーミングしたら、パーティション分割テーブルのプルーニングが効くのか検証

Dataflow には Google 提供のテンプレートで Datastream to BigQuery (Stream)がある。

https://cloud.google.com/dataflow/docs/guides/templates/provided-streaming#datastream-to-bigquery

公式ドキュメントにパーティション分割の方法が書いてあるので、この通りに試す ↓

https://cloud.google.com/datastream/docs/best-practices-stream-data#partition-replica-datasets

:::message
この方法は、一旦ストリームを停止してからテーブルを作成してデータをロードするという方法で、上で試した方法と同じ。以下の手順で試したところ、確かにうまく行く。しかし、Datastream for BigQuery だと、上手くいかなかった(上述)ので、Datastream for BigQuery は裏でテンプレートと同じ実装を使っている訳ではないらしい。
:::

#### 変数準備

```bash
export GCS_FILE_PATH=xxx
export TOPIC_NAME=xxx
export SUBSCRIPTION_NAME=xxx
export JOB_NAME=xxx
export PROJECT_ID=xxx
export REGION_NAME=xxx
export GCS_SUBSCRIPTION_NAME=projects/${PROJECT_ID}/subscriptions/${SUBSCRIPTION_NAME}
export BIGQUERY_DATASET_STG=xxx
export BIGQUERY_DATASET=xxx
export BIGQUERY_TABLE=xxx
export BIGQUERY_TABLE_STG=xxx
export VERSION=latest
export INPUT_FILE_FORMAT=avro
export DEADLETTER_QUEUE_DIRECTORY=${GCS_FILE_PATH}-deadletter-queue
```

#### Datastream の CDC を GCS に作成

1. バケットの作成

```
gsutil mb -l asia-northeast1 ${GCS_FILE_PATH}
gsutil mb -l asia-northeast1 ${DEADLETTER_QUEUE_DIRECTORY}
```

以下、GCP コンソールで作成

2. バケットを指定した Connection Profile の作成

3. ストリームの作成

#### Dataflow job の作成

```bash
# GCSのPubSub通知のためのPubSub Topicを作成
gsutil notification create -t ${TOPIC_NAME} -f json ${GCS_FILE_PATH}

# 上で作成したTopicからDataflowが読み出しを行うためのSubscriptionを作成
gcloud pubsub subscriptions create ${SUBSCRIPTION_NAME} --topic=${TOPIC_NAME}

# jobの作成
gcloud beta dataflow flex-template run ${JOB_NAME} \
    --project=${PROJECT_ID} \
    --region=${REGION_NAME} \
    --enable-streaming-engine \
    --template-file-gcs-location=gs://dataflow-templates/${VERSION}/flex/Cloud_Datastream_to_BigQuery \
    --parameters \
inputFilePattern=${GCS_FILE_PATH}/,\
gcsPubSubSubscription=${GCS_SUBSCRIPTION_NAME},\
outputStagingDatasetTemplate=${BIGQUERY_DATASET_STG},\
outputDatasetTemplate=${BIGQUERY_DATASET},\
outputStagingTableNameTemplate=${BIGQUERY_TABLE_STG},\
outputTableNameTemplate=${BIGQUERY_TABLE},\
inputFileFormat=${INPUT_FILE_FORMAT},\
deadLetterQueueDirectory=${DEADLETTER_QUEUE_DIRECTORY}
```

#### CDC データが BigQuery にインサートされたのを確認後、Dataflow ジョブを停止/ドレインし、パーティション分割テーブルに変更する

以下のクエリを実行

```bash
bq query --use_legacy_sql=false "
create table ${PROJECT_ID}.${BIGQUERY_DATASET}.${BIGQUERY_TABLE}_partition_by_key partition by date(field_name)
as SELECT * FROM ${PROJECT_ID}.${BIGQUERY_DATASET}.${BIGQUERY_TABLE}
"

bq query --use_legacy_sql=false "
drop table ${PROJECT_ID}.${BIGQUERY_DATASET}.${BIGQUERY_TABLE};
alter table ${PROJECT_ID}.${BIGQUERY_DATASET}.${BIGQUERY_TABLE}_partition_by_key rename to ${BIGQUERY_TABLE};
"
```

## 検証結果

もう一度 Dataflow ジョブを作成し、プルーニングが効くか確認
⇒ ちゃんとプルーニングが効いていることが確認できた。

# まとめ

- Datastream for BigQuery では、パーティション分割テーブルにストリーミングしてもプルーニングが効かない。
- Dataflow で同等の機能を使える Google 提供のテンプレートでは、パーティション分割テーブルにストリーミングすると、ちゃんとプルーニングが効く。

# その他 Tips

#### Google 提供の Dataflow テンプレートでのストリーミングでスキャン量の激増に注意

デフォルトで 10min 間隔で CDC ステージングテーブルとターゲットレプリカテーブルの MERGE が発生する。バックフィルでの Initial Load で大量のデータがステージングテーブルに保持される場合、二つのテーブルのフルスキャンが 10min おきに発生することになるので注意。
⇒ バックフィル中は MERGE 間隔を長くとり、後でパイプラインを作り直すのがよい。

#### クエリのスキャン量確認クエリ

以下のクエリで特定のテーブルやクエリを指定して確認

```bash
bq query --use_legacy_sql=false "
SELECT
  user_email,
  creation_time,
  query,
  total_bytes_processed AS total_bytes_processed,
  total_bytes_processed / 1024 / 1024 / 1024 /1024 AS total_TB_processed,
  total_bytes_processed / 1024 / 1024 / 1024 /1024 * 6.0 AS Charges_Dollar,
FROM
  region-asia-northeast1.INFORMATION_SCHEMA.JOBS_BY_PROJECT
WHERE
  DATE(creation_time) BETWEEN DATE_ADD(CURRENT_DATE('Asia/Tokyo'), INTERVAL -1 DAY ) AND CURRENT_DATE('Asia/Tokyo')
  AND REGEXP_CONTAINS(query, r'<project_id>.<dataset>.<table>')
  ORDER BY 2 desc
"
```
