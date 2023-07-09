---
title: "pytest入門"
emoji: "🔖"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["pytest"]
published: true
---

書籍[^1][^2]の内容をベースに公式ドキュメントで捕捉しながら pytest についてまとめてみました。

# 基礎

## pytest の特徴

- テスト 失敗 時 の 表示が分かりやすい。(失敗時の値と期待値との差分の位置までキャレットで表示してくれる。print デバッグや pdb デバッガでのデバッグではここまでは分からない）
- Python 標準の assert を使ってシンプルに書ける
- fixture を使える
- 豊富なプラグインエコシステムを利用可能

## インストール

PyPi からインストール

```bash
pip install pytest
```

```jsx
poetry add -D pytest
```

## テストの準備

### **テストディスカバリ（ test discovery）**

実行 する テスト を 検索 する 部分を**テストディスカバリ**という。
pytest が 検索 するテストは、以下の名前をもつファイル

- test\_<xxx>. py
- <xxx>\_ test. py

### テストを書く

```python:test_sample.py
def func(x):
    return x + 1

def test_answer():
    assert func(3) == 5
```

## テストの実行

```python
pytest
```

ディスカバリに従って、テストが実行される

pytest の 1 つの呼び出しを**テストセッション**と呼び、セッションで実行されるテストがすべて含まれている（場合によっては、それらのテストは複数のディレクトリに分かれていることもある）。

単一のテストメソッドを実行する場合

```python
pytest -v tests/path/to/test/TestSomeClass::test_some_method
```

### 実行時のオプション

以下のいずれかで指定する

- CLI オプション
- 設定ファイル

設定ファイルは pytest.ini、pyproject.toml、tox.ini、setup.cfg など多数あるが、個人的には [pyproject.toml](#pyprojecttoml) にまとめて書くのがおすすめ。

### 書籍内で紹介されているオプション

- -collect-only: ディスカバリを確認するのみ（テスト実行はしない）
- k EXPRESSION: テストメソッドの名前でフィルタする。and/or/not なども使用可。
- m MARKEXPR: マーカーをつけたテストメソッドだけをフィルタして実行する。and/or/not を使用して複数のマーカーを組み合わせ可。
- x, --exitfirst: テストが失敗したらテストセッション全体をそこで中止
- s, --capture=method: テストの実行中に本来ならば標準出力に書き出されるすべての出力を実際に標準出力（stdout）に書き出す
- l, --showlocals: テストが失敗した場合に、そのテストのローカル変数をトレースバックで表示
- -lf, --last-failed: 最後に失敗したテストだけを再実行
- -ff, --failed-first: 最後に失敗したテストから実行
- q, --quiet: 出力情報を少なくする
- -tb=style: 失敗しているテストのトレースバック出力の方法を変更する。
- -durations=N: テストが実行された後に、最も時間がかかった N 個のテスト／セットアップ／ティアダウンを表示。--durations=0 を指定した場合は、最も時間がかかったものから順にすべてのテストを表示。

# pytest のプラグイン（plug-in）

### プラグインとは？

フック関数(慣例として pytest\_の接頭辞で始まる)の集合体。フック関数は pytest の振る舞いを変更するインターフェースとして提供されるので、それを通して好きな機能を実装したプラグインを自作することができる。

https://docs.pytest.org/en/7.1.x/how-to/writing_plugins.html

以下にあるのが、pytest  が提供する well specified hooks

https://docs.pytest.org/en/7.1.x/reference/reference.html#hook-reference

他にも PyPi などで公開されている外部プラグインは pip でインストールできる。

```python
pip install pytest-<plugin_name>
```

インストールしたら自動で適用されるので、以下のようなサイトを参考にしながら、適当に入れて試してみるとよい。

※ pytest-mock, pytest-freezgun, pytest-cov などのプラグインは個人的にもよく使用している。

https://towardsdatascience.com/pytest-plugins-to-love-️-9c71635fbe22

### プラグインの自作

また、conftest.py に自作フック関数を定義することでローカルプラグインを作成することもできる。作成したローカルプラグインは、conftest.py が置かれたディレクトリ以下のテスト実行時に適用される。

書籍内で紹介されていた自作プラグインの例

【例１】テストセッションの出力に”Thanks for running the tests!”と表示するプラグイン

```python:conftest.py
def pytest_report_header():
    return "Thanks for running the tests!"
```

【例２】テストのステータスを変更するプラグイン。F を O に、FAILED を OPPORTUNITY for improvement に変更。

```python:conftest.py
def pytest_report_teststatus(report):
    if report.when == "call" and report.failed:
        return (report.outcome, "O", "OPPORTUNITY for improvement")
```

【例３】コマンドラインオプション--nice を追加して、このオプションが指定された場合にのみステータスの変更が有効になるようにするプラグイン

```python:conftest.py
def pytest_addoption(parser):
    group = parser.getgroup("nice")
    group.addoption("--nice", action="store_true",
              help="nice: turn failures into oppotunities")

def pytest_report_teststatus(report):
    if report.when == "call":
        if report.failed and pytest.config.getoption("nice"):
            return (report.outcome, "O", "OPPORTUNITY for improvement")
```

# pytest のフィクスチャ（fixture）

### **フィクスチャとは？**

フィクスチャは、テスト関数の実行の前後に、pytest によって実行される関数で、セットアップやティアダウン処理を行う。または、関数によって準備されるリソースやデータを指すこともある。

⇒ フィクスチャは本来、依存オブジェクトのこと。DI で注入される依存オブジェクトや、DB やファイルのオブジェクトなどで、毎回固定された値（=fix）であることがフィクスチャ＝ fixture の語源。pytest の文脈では、fixture「関数」によって fixture「オブジェクト」を Arrange する、という意味合いだろう。

以下のテストの４ステップのうち、1．の Arrange ステップをフィクスチャで定義できる。

1. **Arrange**
2. **Act**
3. **Assert**
4. **Cleanup**

Arrange での準備の元でステップ２以降が進むので、テストに文脈を与えるものといえる。（Python での with コンテキストマネージャーに相当）

https://docs.pytest.org/en/7.1.x/explanation/anatomy.html#test-anatomy

フィクスチャを使うことで、テストのロジック（こうしたら（WHEN）こうなる（THEN））とその前提条件（GIVEN）が分離され、テストの見通しがよくなる。

pytest ドキュメントでの定義

> In testing, a [fixture](https://en.wikipedia.org/wiki/Test_fixture#Software) provides a defined, reliable and consistent context for the tests. This could include environment (for example a database configured with known parameters) or content (such as a dataset).

> Fixtures define the steps and data that constitute the *arrange* phase of a test (see [Anatomy of a test](https://docs.pytest.org/en/7.1.x/explanation/anatomy.html#test-anatomy)). In pytest, they are functions you define that serve this purpose. They can also be used to define a test’s *act* phase; this is a powerful technique for designing more complex tests.

### フィクスチャの書き方

フィクスチャは個々のテストファイルにも記述できるが、複数のテストファイルでフィクスチャを共有するには、conftest.py に記述する。

@pytest.fixture() というデコレーターで、その関数がフィクスチャであることを pytest に認識させる。`return`文または`yield`文を使用して、オブジェクトをテスト関数に提供する。

【例】DB セッションオブジェクトを準備して提供するフィクスチャ

```python
@pytest.fixture
def db_session(tmp_path):
    fn = tmp_path / "db.file"
    return connect(fn)
```

※ 上記の例では、tmp_path というフィクスチャを使って、db_session というフィクスチャを定義している。このようにフィクスチャ内で別のフィクスチャを使うこともできる。

詳しくはフィクスチャのドキュメントを参照

https://docs.pytest.org/en/7.1.x/reference/reference.html#fixtures

https://docs.pytest.org/en/7.1.x/reference/fixtures.html#fixture

### フィクスチャの使い方

フィクスチャを使う側のテスト関数は、使いたいフィクスチャをパラメータとして受け取って使用する。

【例】フィクスチャを使用するテスト関数

```python
def test_output(capsys):
    print("hello")
    out, err = capsys.readouterr()
    assert out == "hello"
```

【例】下記のようにデコレータを使うこともできる

```python
@pytest.mark.usefixtures(’capsys’)
def test_output():
    print("hello")
    out, err = capsys.readouterr()
    assert out == "hello"
```

さらに、フィクスチャ関数定義時（conftest.py など）に `autouse`=`True` としておけば、自動的に適用されるので、テスト関数側では何も指定する必要はない。

### **フィクスチャのスコープ**

以下の 4 つのスコープがある。pytest の起動時オプションで—setup-show を使うと、どのフィクスチャがいつ実行されるのかトレースできるので、確認しながら開発するとよい。

1. 関数スコープ (**`function`**): デフォルトのスコープ。各テスト関数は独立してフィクスチャを利用する。
2. クラススコープ (**`class`**): テストクラスの全メソッドがフィクスチャを共有する。
3. モジュールスコープ (**`module`**): モジュール全体でフィクスチャを共有する。
4. セッションスコープ (**`session`**): テストセッション全体でフィクスチャを共有する。重いリソースや初期化処理に使用する。

### **フィクスチャの例**

【例】tmpdir という組み込みフィクスチャを使って、DB 接続用のセッションオブジェクトを提供するフィクスチャ

```python
from my_package.connector.client import get_connection
import pytest

HOST = "0.0.0.0"
DATABASE = "test_db"
TABLE = "test.test"
USER = "user"
PASSWORD = "passw0rd"
PORT = 5432

config = {
    "host": HOST,
    "database": DATABASE,
    "user": USER,
    "password": PASSWORD,
    "port": PORT,
}

@pytest.fixture(scope="session", autouse=True)
def db_init():
    with get_connection(config) as conn:
        cur = conn.cursor()

        # prepare test data
        try:
            cur.execute(
                "INSERT INTO test.test(id2, id3, id4, name, date, memo) VALUES(1, 1, 1, 'test data1', '2023-01-01', 'memo1');"
            )
            cur.execute(
                "INSERT INTO test.test(id2, id3, id4, name, date) VALUES(2, 2, 2, 'test data2', '2023-02-02');"
            )
            cur.execute(
                "INSERT INTO test.test(id2, id3, id4, name, date, memo) VALUES(3, 3, 3, 'test data3', '2023-03-03', 'memo3');"
            )
            cur.execute(
                "INSERT INTO test.test(id2, id3, id4, name, date) VALUES(4, 4, 4, 'test data4', '2023-04-04');"
            )
            cur.execute(
                "INSERT INTO test.test(id2, id3, id4, name, date) VALUES(5, 5, 5, 'test data5', '2023-05-05');"
            )
            conn.commit()

        except Exception:
            raise "fail to initialize test db."

        # ここでテスト実行
        yield

@pytest.fixture(scope="session")
def db_cursor(db_init):
    with get_connection(config) as conn:
        cur = conn.cursor()

        # ここでテスト実行
        yield cur
```

【例】フィクスチャ関数のパラメーター化の例１：DB の種類で fixture をパラメーター化する

```python
from my_package.connector.client import get_connection
from my_package.connector.config import get_config
import pytest

@pytest.fixture(scope="session", params=["mysql", "postgres", "mongo"])
def db_cursor(db_init, request):
    db_type = request.param # パラメーターを受け取る
    config = get_config(db_type)
    with get_connection(config) as conn:
        cur = conn.cursor()

        # ここでテスト実行。パラメーター毎に別のfixtureとして、テスト関数に渡される。
        yield cur

```

【例】フィクスチャ関数のパラメーター化の例２：テストデータをパラメータとして渡す
以下のように@pytest.mark.parametrize('<引数名>', <引数値>) デコレーターを使える。

```python
from datetime import datetime, timedelta

import pytest

testdata = [
    (datetime(2001, 12, 12), datetime(2001, 12, 11), timedelta(1)),
    (datetime(2001, 12, 11), datetime(2001, 12, 12), timedelta(-1)),
]

@pytest.mark.parametrize("a,b,expected", testdata)
def test_timedistance_v0(a, b, expected):
    diff = a - b
    assert diff == expected
```

※ 以下のようにデコレーターをスタックすると、「全組み合わせ」をテストできるので便利

```python
import pytest
@pytest.mark.parametrize("x", [0, 1])
@pytest.mark.parametrize("y", [2, 3])
def test_foo(x, y):
    pass
```

ドキュメント

https://docs.pytest.org/en/6.2.x/parametrize.html

:::message
💡 フィクスチャ関数のパラメーター化は便利な反面、フィクスチャに複数の前提条件(GIVEN)を持たせてテストするので、テストの前提条件と期待値の関連性がデカップリングするために可読性を下げるし、変更が大変になる。使うときは注意が必要。
上の例のような単純な場合はよいが、パラメーターを一見して、そのテストケースが何を確認しようとしているか明瞭な場合以外は、パラメーター化テストはやめたほうがいい。テスト関数の異なる振る舞いやユースケースを確認する場合は、別のテスト関数に分けるのが原則。
:::

【例】フィクスチャ関数のパラメーター化の例３：テストデータをパラメータとして渡す

組み込みフィクスチャ tmpdir_factory を使って Python の Dict オブジェクトからテスト用の json ファイルを作成・保存し、その file path をテスト関数に渡して実行する

```python
BASE_CONFIG = {
    "name": "test",
    "description": "test base",
    "sources": [
        {
            "name": "in",
            "module": "postgres",
            "parameters": {
                "query": "select id, day from test.test;",
                "profile": "test",
            },
        }
    ],
    "sinks": [
        {
            "name": "out",
            "module": "bigquery",
            "input": "in",
            "parameters": {
                "table": "my-prj:test.test",
                "schema": "id:INTEGER,day:DATE",
                "write_disposition": "WRITE_APPEND",
            },
        }
    ],
}

# BASE_CONFIGをjsonファイルとして一時ファイルに保存するフィクスチャ
@pytest.fixture(scope="function")
def base_config_json(tmpdir_factory):
    tmp_dir = tmpdir_factory.mktemp("tmp")
    base_file = tmp_dir.join("config_base.json")
    base_file.write(json.dumps(BASE_CONFIG))
    file_path = str(base_file)

    # ここでテスト実行
    yield file_path

# フィクスチャを使うテスト関数
def test_configs_valid(self, tcase_valid, base_config_json):
    with open(base_config_json, "r+") as f:
        base_conf = json.loads(f.read())
        ...
```

### 組み込みフィクスチャ

他にも便利な組み込みフィクスチャがたくさんある。

※ stdout と stderr の出力をキャプチャする capsys や、時間を固定する freezegun などは個人的にもよく使う。

https://docs.pytest.org/en/latest/reference/fixtures.html#reference-fixtures

# プロジェクトでの構成例

## ディレクトリ構成

### ディレクトリ構成の例

```bash
my_proj/
├── README.md
├── Makefile
├── poetry.lock
├── pyproject.toml
├── src
│   └── my_package
│       ├── __init__.py
│       ├── config.py
│       └── main.py
└── tests
    ├── __init__.py
    ├── conftest.py
    ├── unit
    │   ├── __init__.py
    │   ├── conftest.py
    │   ├── test_xx.py
    │   └── test_yy.py
    └── integration
        ├── __init__.py
        ├── conftest.py
        ├── test_xx.py
        └── test_yy.py

```

## 設定ファイル

### pyproject.toml

プロジェクトの仕様を定義するファイル。パッケージ依存関係や各種ツールの設定をまとめて記述できるので、pytest の設定や起動オプションもこれに記述するのがおすすめ。設定の書き方の例は下にあります。

:::message
💡 pyproject.toml について

> PEP 518 で定義されたビルドシステムとは独立したファイル形式で、あるプロジェクトのビルドシステムが正常に動作するためにインストールされていなければならない Python レベルの依存関係をすべて宣言するという目的のためにそのプロジェクトが提供するものです。

[ビルドシステムの依存関係を宣言する — Python Packaging User Guide](https://packaging.python.org/ja/latest/specifications/declaring-build-dependencies/)
:::

:::message
💡 Poetry について

pyproject.toml の[build-system]セクションに、必要なパッケージの依存関係やインストール時のビルドバックエンドを指定する。デフォルトでは setup.py が使われるが、Poetry を使えば pyproject.toml に依存関係を定義できるので、setup.py や requirements.txt は不要になる。Poetry 以外にも様々なツールの設定を pyproject.toml 一つに集約できる。

```toml
[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api
```

:::

### conftest.py

共有したいフィクスチャを定義するファイル。pytest に起動時に読み込まれ、テストコード全体の前処理が実行される。（ここで定義したフック関数とフィクスチャはローカルプラグイン と見なされ、自動的に適用される。conftest のインポート(import conftest)は不要）

conftest.py を配置したディレクトリ以下の全てのテストに適用されるので、フィクスチャを共有したいスコープに応じて配置する。

例えば、上記のディレクトリ構成で、tests/conftest.py に以下の設定をしておくと、pytest 実行時に-m オプションで、unit テストと integration テストの実行を切り替えることが出来る。

【例】マーカーを動的に付与する自作プラグインの作成

```python:conftest.py
import pytest

def pytest_collection_modifyitems(items):
    for item in items:
        if item.path.parent.stem == "unit":
            item.add_marker(pytest.mark.unit)
        elif item.path.parent.stem == "integration":
            item.add_marker(pytest.mark.integration)
```

【例】-m オプションでテスト実行時に unit テストと integration テストを切り替え

```bash
pytest -m unit # unitテストを実行
pytest -m integration # integrationテストを実行
```

## pyproject.toml ファイルへの設定の記述法

### pytest の設定例

```toml:pyproject.toml
[tool.pytest.ini_options]
# pytestの最低バージョンを要求
minversion = "6.0"
addopts = "-rsxX -l --tb=short --strict-markers -v --ff --pdb --setup-show"
markers = [
    "unit: mark a test as a unit test",
    "integration: mark a test as an integration test",
]
# src/にPATHを通す
pythonpath = ["src/my_package"]
# テストコード自体の検索パス(ディスカバリ)
testpaths = ["tests/"]
# norecursedirsにはテストディスカバリに含めないディレクトリを指定する。
# デフォルトは、'.*'、'build'、'dist'、'CVS'、'_darcs'、'{arch}'、'*.egg'
# '.*' は、仮想環境の名前を'venv'でなく'.venv' にする動機の1つとなる
norecursedirs = ["tests/exclude_dir/"]
```

### tox の設定例（複数の Python バージョンでのテスト）

```toml:pyproject.toml
[tool.tox]
legacy_tox_ini = """
[tox]
envlist = py38,py39,py310
isolated_build = true
# setup.py がなくても実行可能にする。Poetryを使っていてpyproject.tomlで依存管理している場合など。
skipsdist = true

[testenv]
whitelist_externals =
    poetry
    docker-compose
    sleep
deps =
    poetry
    pytest
setenv =
    PYTHONPATH = src/my_package
commands =
    # --no-root: ルートパッケージ (自分のプロジェクト) をインストールしない
    poetry install -v --no-root
    docker-compose -f tests/integration/docker-compose.yml up -d
    sleep 2
    poetry run pytest -m unit
    poetry run pytest -m integration
    docker-compose -f tests/integration/docker-compose.yml down --volumn
"""

```

[^1]: [テスト駆動 Python](https://www.amazon.co.jp/%E3%83%86%E3%82%B9%E3%83%88%E9%A7%86%E5%8B%95Python-%E7%AC%AC2%E7%89%88-Brian-Okken/dp/4798177458)
[^2]: [単体テストの考え方-使い方-Vladimir-Khorikov](https://www.amazon.co.jp/%E5%8D%98%E4%BD%93%E3%83%86%E3%82%B9%E3%83%88%E3%81%AE%E8%80%83%E3%81%88%E6%96%B9-%E4%BD%BF%E3%81%84%E6%96%B9-Vladimir-Khorikov/dp/4839981728/ref=pd_lpo_sccl_2/356-4352961-1046528?pd_rd_w=BwdTK&content-id=amzn1.sym.d769922e-188a-40cc-a180-3315f856e8d6&pf_rd_p=d769922e-188a-40cc-a180-3315f856e8d6&pf_rd_r=GMSAM8Q19M2WAW9P9DV5&pd_rd_wg=rpNDF&pd_rd_r=758e9ed3-651d-4ef1-a4fc-556de7d35cde&pd_rd_i=4839981728&psc=1)
