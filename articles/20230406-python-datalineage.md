---
title: "Python SDK ライブラリで、指定した Bigquery テーブルのリネージをたどり、最終更新時間を表示する"
emoji: "🦔"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [GCP]
published: false
---

# はじめに

BigQuery のデータリネージ機能を使って関連テーブルを特定し、最終更新時間を表示する Python スクリプトを作ってみました。その過程で調べた内容と合わせてまとめました。

# データリネージ

Dataplex の機能として Data Lineage API がプレビューで提供されている
※プレビュー期間中は無料

リネージを可視化するサードパーティツールはいろいろあるが、構築運用の手間のない GCP のネイティブサービスを使ってみる。
※ 現状、カラムレベルリネージは出来ない(サードパーティーツールでは対応するものもある)

試すためには API 有効化と権限付与が必要
https://cloud.google.com/data-catalog/docs/how-to/lineage-gcp?hl=ja

API

- Data Lineage API
- Data Catalog API

ロール

- roles/datacatalog.viewe
- roles/datalineage.viewer

Data Lineage API を有効化すると、

- リネージグラフの可視化(UI)
- API 経由でのリネージ情報取得(CLI)

などができるようになる。

# クエリで取得する方法

BIGQUERY でテーブルの最終更新タイムスタンプを一覧表示したい場合、<dataset>.\_\_TABLES\_\_が、データセットに含まれるメタデータを管理しているため、以下の SQL でテーブル最終更新日の一覧が取得できる。

```sql:sql
SELECT table_id
     , TIMESTAMP_MILLIS(last_modified_time) AS last_modified
  FROM `<dataset>.__TABLES__`;
```

# 更新タイムスタンプ取得方法

上記のクエリではデータセット単位で情報を取得できる。

一方で、特定のテーブルを指定してそのリネージをたどり、親子関係にあるテーブルを特定して、その最終更新タイムスタンプを表示したい場合、クエリでは取得できない。

この場合、DataCatalog と DataLineage の API や SDK ライブラリ経由で情報を取得することができる。

今回は Python SDK ライブラリを使ってリネージ取得・更新タイムスタンプ表示する方法を試してみました。

API reference
https://cloud.google.com/data-catalog/docs/reference/data-lineage/rest

Python Client
https://cloud.google.com/python/docs/reference/lineage/latest

## 環境準備

以下のページを参考に、検証用の環境を構築します。

https://cloud.google.com/data-catalog/docs/how-to/track-lineage?hl=ja

今回は make コマンドで環境構築できるようにしました。make ターゲットのレシピ内で gcloud コマンドを発行します。

以下のリポジトリにコードがありますので、よければ参考にしてください。
https://github.com/satokiyo/python-bigquery-datalineage

Makefile 内で定義した変数を適当な値に変更し、

```makefile:Makefile
PROJECT_ID:=datalineage-demo
USER_ADDRESS:=<YOUR ADDRESS>
DATASET:=data_lineage_demo
BILLING_ACCOUNT_ID:=<YOUR ACCOUNT_ID>
```

make コマンドで環境を構築します。

```bash:bash
make build-infra

# 以下の処理を実行する
  # デモ用プロジェクト作成
  # 請求先アカウントとの紐づけ（リネージグラフを見るために必要）
  # API有効化
  # IAMロール付与
  # 検証用BigQueryのテーブル作成
```

上のコマンドを実行すると、BigQuery の一般公開データセットからデモ用プロジェクトの BigQuery データセットにテーブルがコピーされ、そのテーブルに対してクエリを発行します。作成されたテーブルを GCP コンソール画面から確認すると、以下のようなリネージが表示されます。

![Untitled](/images/20230406-python-datalineage/datalineage-1.png)

## 指定したテーブルのリネージを表示する関数を実行する

Makefile に定義した変数 FQN で、今回作成したテーブルを指定しています。

```makefile:Makefile
FQN:=bigquery:datalineage-demo.data_lineage_demo.total_green_trips_22_21
```

指定したテーブルの上流/下流のリネージテーブルと、その最終更新タイムスタンプを表示します。

```bash:bash
make run

#  実行されるコマンド
#  poetry run python src/main.py $(PROJECT_NO) $(LOCATION) $(FQN)
```

出力は以下のようになります。FQN で指定したテーブルのリネージから上流の 2 次のつながりまで取得して、最終更新タイムスタンプが表示されています。今回は、下流のリネージが存在しないため、表示されていません。

```bash
start!!
fully_qualified_name: bigquery:datalineage-demo.data_lineage_demo.total_green_trips_22_21
--------------------
upstream source: fully_qualified_name: "bigquery:datalineage-demo.data_lineage_demo.tlc_green_trips_2021"
 (n=1)
create_time: 2023-04-06 17:18:07
update_time: 2023-04-06 17:18:07
--------------------
upstream source: fully_qualified_name: "bigquery:bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2021"
 (n=2)
create_time: 2022-09-14 13:11:36
update_time: 2022-09-14 13:11:36
--------------------
upstream source: fully_qualified_name: "bigquery:datalineage-demo.data_lineage_demo.tlc_green_trips_2022"
 (n=1)
create_time: 2023-04-06 17:18:10
update_time: 2023-04-06 17:18:10
--------------------
upstream source: fully_qualified_name: "bigquery:bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2022"
 (n=2)
create_time: 2022-09-14 13:11:54
update_time: 2022-09-14 13:11:54
```

### 処理の流れ

1. DataLineage SDK の search_links()関数で、指定されたテーブルの fqn から、関連するリンクを取得する。このとき、SearchLinksRequest リクエストのボディに source として fqn を指定すれば、その下流側（downstream 側）のリンクが取得でき、逆に target として fqn を指定すれば、その上流側（upstream 側）のリンクが取得できる。

下の例は upstream 側のリンクを取得する関数の例

```python
def search_upstream_links(
    client: lineage_v1.LineageClient,
    project: str,
    location: str,
    fully_qualified_name: str,
):
    """Retrieve a list of upstream links connected to a specific asset.
    fully_qualified_nameがtargetになるリンク(source-targetのペア)を一覧表示する。
    Links represent the data flow between source (upstream) and target (downstream) assets in transformation pipelines.
    Links are stored in the same project as the Lineage Events that create them.

    Args:
        client (lineage_v1.LineageClient): _description_
        project (str): _description_
        location (str): _description_
        fully_qualified_name (str): _description_
    """
    # Initialize request argument(s)
    target = lineage_v1.EntityReference()
    target.fully_qualified_name = fully_qualified_name
    parent = f"projects/{project}/locations/{location}"

    request = lineage_v1.SearchLinksRequest(
        target=target,
        parent=parent,
    )

    # Make the request
    return client.search_links(request=request)

# Create a client
lineage_client = ClientFactory.get_client("lineage")

# upstream lineage
response = search_upstream_links(
    lineage_client, project, location, fully_qualified_name
)

```

2. 取得したリンクの先のリソースから fqn を取得し、

```python
# Handle the response
for item in response:
    source = item.source

    print("--------------------")
    print(f"upstream source: {source} (n={counter})")

    if not source.fully_qualified_name.startswith("bigquery:"):
        # bigquery以外のsource(ex: spreadsheet...etc.)
        continue

    project, dataset, table = source.fully_qualified_name.split(":")[-1].split(".")

    # 検索条件
    table_name = f"//bigquery.googleapis.com/projects/{project}/datasets/{dataset}/tables/{table}"
```

3. Datacatalog SDK の lookup_entry()関数に渡して、Entry の情報を取得する。取得した Entry オブジェクトの source_system_timestamps 属性に、create_time と update_time があるので、これを表示すればよい。

```python
    def get_resource(client, resource_name: str) -> datacatalog_types.datacatalog.Entry:
        return (datacatalog_types.datacatalog.Entry)(
            client.lookup_entry(request={"linked_resource": resource_name})
        )

    catalog_client = ClientFactory.get_client("catalog")
    resource = get_resource(catalog_client, table_name)

    print(
        f'create_time: {resource.source_system_timestamps.create_time.astimezone(JST).strftime("%Y-%m-%d %H:%M:%S")}'
    )
    print(
        f'update_time: {resource.source_system_timestamps.update_time.astimezone(JST).strftime("%Y-%m-%d %H:%M:%S")}'
    )
```

4. 上記を upstream 側、downstream 側のリンクでそれぞれ再帰的に実行し、n 次のつながりまでのリソースの更新タイムスタンプを表示する

# Lineage API の関連用語メモ

### プロセス

name："projects/{project}/locations/{location}/processes/{process_id}"

データの作成、変換、および移動などの処理の単位(=データパイプライン)。データのソース、変換、およびターゲットを指定して、BigQuery や Dataflow パイプラインなどのジョブををプロセスとして Data Catalog に登録する。

> A process is the definition of a data transformation operation.

### 実行(Run)

name："projects/{project}/locations/{location}/processes/{process_id}/runs/{run_id}"

プロセスの実行単位。BigQuery や Dataflow、Dataproc のようなジョブ実行サービスのジョブの実行インスタンスを表す。ジョブが完了すると、Run に関する情報が Data Catalog に記録される。

> A lineage run represents an execution of a process that creates lineage events.

### リネージイベント

name: "projects/{project}/locations/{location}/processes/{process}/runs/{run_id}/lineageEvents/{lineage_event_id}"

lineage event は特定のジョブの実行における、特定の asset 間でのデータの流れを表現する(source->target)。1 つのジョブ実行には、その中で実行される複数の Lineage event が紐づく

> A lineage event represents an operation on assets. Within the operation, the data flows from the source to the target defined in the links field.

### リンク

リンクの実体はプロジェクト内で保存された lineage event であり、lineage event が記録されると、リンクが作られる。

> Links represent the data flow between source (upstream) and target (downstream) assets in transformation pipelines.
> Links are stored in the same project as the Lineage Events that create them.
> Links are created when LineageEvents record data transformation between related assets.

※ グラフでいうノードに対応するのが asset(source、target)、エッジに対応するのがリンク。
※ リンクはプロセス、ジョブ、Run、lineage event などの情報を保持する。
※ 1 つのプロセス、ジョブ、Run は 1 ～複数のリンクに紐づく。
※ 1 つの lineage event は 1 つのリンクに紐づく。

イメージ図
![Untitled](/images/20230406-python-datalineage/figure-figure.drawio.png)
