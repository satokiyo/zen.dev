---
title: "[読書]自走プログラマー　～Pythonの先輩が教えるプロジェクト開発のベストプラクティス120"
emoji: "📘"
type: "idea"#tech:技術記事/idea:アイデア
topics: [本,Python]
published: true
---

https://www.amazon.co.jp/%E8%87%AA%E8%B5%B0%E3%83%97%E3%83%AD%E3%82%B0%E3%83%A9%E3%83%9E%E3%83%BC-Python%E3%81%AE%E5%85%88%E8%BC%A9%E3%81%8C%E6%95%99%E3%81%88%E3%82%8B%E3%83%97%E3%83%AD%E3%82%B8%E3%82%A7%E3%82%AF%E3%83%88%E9%96%8B%E7%99%BA%E3%81%AE%E3%83%99%E3%82%B9%E3%83%88%E3%83%97%E3%83%A9%E3%82%AF%E3%83%86%E3%82%A3%E3%82%B9120-%E6%B8%85%E6%B0%B4%E5%B7%9D-%E8%B2%B4%E4%B9%8B/dp/4297111977

## 感想

Python での開発のベストプラクティスが実践に即して学べるいい本でした。

個人的には dataclass の使い方やログ、例外のあたりの内容が勉強になりました。

忘れていた知識とか、使えそうなプラクティスを以下にメモします。

### デフォルト引数に更新可能（mutable）な値は指定せず、None を設定する。

```python
def foo(values=None) -> List[str]:
    values = values or []
    values.append("data")
    return values
```

> 引数 values をデフォルトで空のリストにしたい場合に values=[]と書いてはいけません。Python ではデフォルト引数の値は関数（やメソッド）呼び出しのたびに初期化されません。関数をデフォルト引数で呼び出すたびに、リストの値が変わってしまう問題があります。
> pp.33-34

### データメンバが多いクラスは dataclass を使って可読性を上げる。**init**関数を定義する代わりに class メソッドでインスタンスを返す。

⇒ 確かに、**init**()イニシャライザ関数は不要である場合が結構あるので、class メソッドで名前空間付きのコンストラクタを作った方が分かりやすい気がする。

```python
@dataclass
class Config:
    prop1: int
    prop2: int
    ...

    @classmethod
    def from_json( cls, json_path: str) -> Config:
        with open(json_path) as f:
            json_dict = json.loads(f)
            return cls( **json_dict)

```

> \>> 15 インスタンスを作る関数をクラスメソッドにする
> p.60

### 例外を隠蔽しない。スタックトレースを出す。

> エラー発生時に最もわかりやすい出力は、Python の開発者にとっては例外によるトレースバックでしょう。システム例外やプログラム例外が発生した場合は、即座にトレースバックを出力してプログラムをエラー終了させましょう。
> p.273

> 想定外の例外は except 節で捕まえずに、そのまま関数の呼び出し元まで伝搬させましょう
> p.278

### try 節は短く

> try 節のコードはできるだけ短く、1 つの目的に絞って処理を実装しましょう。try 節に複数の処理を書いてしまうと、発生する例外の種類も比例して多くなっていき、except 節でいろいろな例外処理が必要になってしまいます。
> p.276

### 専用 の 例外 クラス で エラー 原因 を 明示する

```python
class MailReceivingError( Exception):
    pretext = ''

    def __init__( self, message, *args):
        if self. pretext:
            message = f"{ self. pretext}: {message}"
        super().__ init__( message, *args)


    class MailConnectionError( MailReceivingError):
        pretext = '接続 エラー'

    class MailAuthError( MailReceivingError):
        pretext = '認証 エラー'

    class MailHeaderError( MailReceivingError):
        pretext = 'メールヘッダーエラー'
```

> p.281

### logger にログをフォーマットしてから渡さない

```python
def main():
    items = load_ items()
    logger. info(" Number of Items: %s", len( items))
```

> ロガーにログメッセージを渡すときは、フォーマットしてはいけません。
>
> Python のロギングは内部的に「メッセージ」と「引数」を分けて管理しているので、分けたままログに残すべきです。logger.log の第一引数がメッセージ、以降はメッセージに渡される値になります。
> p.298

### ロガーはモジュールパス**name**を使って取得し、logging.config.dictConfig.loggers にまとめて設定を書く

```python
import logging
logger = logging. getLogger(__ name__)
```

```python
logging. config. dictConfig({
    ...
    "loggers": {
        "product. views": {},
        "product. management. commands": {},
    }
```

> Python では「.」区切りで「上位」（左側）のロガーが適応されます。
> (…)
> Python のモジュール名にすることでロガーの命名規則を考える必要もなくなります。上位のロガーに影響させない場合は propagate を False にします。設定がない場合は常に上位のロガーに propagate（伝播）していきます。
> p.301

https://docs.python.org/ja/3/howto/logging.html#logging-flow

### ログの先頭にトランザクション ID を入れて、後で grep で取り出せるようにする

> ログファイルをあとで grep したときに目的のログだけ取り出せるように意識しましょう。重要なバッチ処理などであれば、処理ごとに「トランザクション ID」を発行して、ログの先頭に常につけると、あとで問題の追跡調査がしやすくなります（トランザクション ID はデータベースで管理せずとも、処理の開始時に発行した UUID などを常にログ出力するようにしても良いです）。
> p.313

### 一時的な作業ファイル作成には tempfile モジュールを使う

> tempfile.NamedTemporaryFile を使えば、ファイル名の競合を避けて一時的なファイルを作成できます。
> p.421
