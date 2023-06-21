---
title: "[読書] Dependency Injection Principles, Practices, and Patterns"
emoji: "📖"
type: "idea" # tech: 技術記事 / idea: アイデア
topics: ["di", "デザインパターン", "OOP", "DDD"]
published: true
---

「Dependency Injection Principles, Practices, and Patterns」の読書メモ
https://www.amazon.co.jp/-/en/Mark-Seemann/dp/161729473X

# 感想

- DDD の理解の前提知識として、かなり役立った。
- DI と関係の深いデザインパターンが頻繁に登場し、具体例が多いので、デザインパターンの復習になったし、使いどころが腹落ちした。
- コアな主張はとてもシンプルで、体系的に書かれていて、一貫していて、（若干冗長なところがあるが）理解しやすい。
- これの翻訳本がないのが不思議

勉強になったポイントを以下にまとめてみた。あとで [Anki アプリ](https://apps.ankiweb.net/)でカードにして覚えるために、質問形式にしてあります。

## DI の定義は？

**定義**：依存性注入（Dependency Injection）は、緩く結合されたコードを開発することを可能にするソフトウェア設計の原則とパターン。

※DI に対してサービスロケータ（汎用の Factory）というイメージがもたれることがあるが、実際は逆で、DI はコードを構造化し、依存関係を命令的要求から宣言的提供に変える。

構造化=インターフェースへのプログラミング＝疎結合を実現する

## DI の目的は？

**DI の目的**
DI は疎結合（loose coupling）を実現するための手法。疎結合はコードの拡張性を高め、拡張性が保守性(maintainability)を実現。

疎結合がもたらすメリット

- Late binding
- Extensibility
- Parallel development
- Maintainability
- Testability

## DI の適用対象は？

DI を使うのは、VOLATILE 依存に対して。DI はそもそも実装を切り替えたい、そのためにわざわざインターフェースに対してプログラミングする。Static な依存について DI を適用しても意味がない。

## DI と関係の深いデザインパターン 4 つ

Decorator, Composite, Adapter, Null Object

※ 本文では Composite パターンはあまり出てこなかったと記憶している。逆に Proxy パターンが多かった。

## DI によってクラスから取り除かれる責務は？

- Object Composition の責務
- Object Lifetime 管理の責務

## DIP とは？DI と DIP との関係は？

**DEPENDENCY INVERSION PRINCIPLE（DIP）**
上位レベルのモジュールは下位レベルのモジュールに依存してはならず、抽象（abstractions）に依存すべきである。

> This principle states that higher-level modules in our applications shouldn’t depend on lower-level modules; instead, modules of both levels should depend on Abstractions.
> ![Untitled](/images/20230621_dependency_injection/0.png)

DIP と DI の関係性：DIP が達成したいこと、DI が手段。

> The relationship between the Dependency Inversion Principle and DI is that the Dependency Inversion Principle prescribes what we would like to accomplish, and DI states how we would like to accomplish it.

## interface と abstract class の違いは？DI ではどちらを使うべき？

- インターフェース
  クラスが実装するメソッド、プロパティ、イベントなどのメンバーのセット。インターフェースは実装の詳細を持たず、単にメンバーの宣言を提供。継承ではなくコンポジションで使う。
- 抽象クラス
  継承前提。派生クラスがオーバーライドして実装を提供する。インターフェースと異なり、抽象クラスは一部の機能を実装する場合がある。

c.f. 基底クラス
派生クラスが継承するクラスのこと。抽象クラスは基底クラスに属することがあるが、インターフェースは基底クラスではない。なぜなら、インターフェースは単なるメンバーの宣言であり、実装を持たないため。
⇒ 抽象クラスでも、実装を全く提供しない場合、Interface といえそう。

DI ではどちらを使うべきか？
⇒ どちらでもよい。

> DI（依存性注入）に関連して言えるのは、どちらを使用しても問題ありません。重要なのは、ある種の抽象化に対してプログラムを行うことです。
> アプリケーションの作成においては通常、以下の理由から抽象クラスよりもインターフェースを好む傾向にあります：
>
> - 抽象クラスは基底クラスとして簡単に誤用される。基底クラスは変更し続け、肥大化してしまう可能性がある（**God Object**）。派生クラスは基底クラスに強く依存しており、基底クラスが不安定な振る舞いを含む場合に問題が発生する。一方、インターフェースは「継承よりもコンポジション」の原則に従わせることができる。

⇒ インターフェースは包含して委譲する。抽象クラスは基底クラスとして継承する。

⇒ Python でいえば、mixin はインターフェースではなくて、階層が 1 つしかないだけの基底クラスの一種といえそう。protocol クラスは Interface にあたりそう。

## 継承よりも包含の原則とは？継承を使った方がよい場面は？

継承はクラス間の強い結びつきを作り出し、変更の伝播や拡張性の問題を引き起こす可能性がある。
一方、コンポジションは**柔軟性**があり、複数のクラスやオブジェクトを組み合わせることができる。また、**変更の影響範囲が限定**され、**拡張性**が高くなる。
クラス間の関係を構築する際に、継承よりもコンポジションを選ぶことで、上記利点を享受できる。

継承を使った方がよい場面
⇒ ライブラリを作成する場合は、継承を使った方がよいかもしれない。

> 再利用可能なライブラリを作成する場合は、後方互換性の問題があるため、抽象クラスの方が意味があるかもしれません。なぜなら、抽象クラスには非抽象メンバーが後から追加できる一方、インターフェースにメンバーを追加することは破壊的な変更となるからです。

※ DI はそのまんま、コンポジション。継承してオーバーライドで差分プログラミングする代わりに、Decorator でインターフェースを Intercept して機能を付加する。何重にもラップして機能追加できるのが Decorator 。

## Composition root とは？それにより実現することは？

**コンポジションルート**
クラスの作成を 1 か所に集約する場所をコンポジションルートと呼ぶ。コンポジションルートは、アプリケーションのエントリーポイントにできるだけ近い場所に配置される（Main メソッドなど）。そこで純粋な DI（Pure DI）を使用するか、DI コンテナに委任することで、アプリケーションを組み立てる。

Composition Root の意義：

- オブジェクトを collaborate する（=mock, intercept,replace …etc）単一の場所を得られる。
  ⇔ Composition root 以外の場所でオブジェクトを作成すると Intercept による振る舞いの調整能力が制限される。

- collaborate の場所をエントリーポイントまで**先延ばし:defer**するほど選択肢が広がる。

## Open/Closed Principle を一言でいうと？分かりやすいイメージで例えると？

**保守性(=変更に対して Close している)と拡張性(拡張に対して Open である)の両立**

> a class should be open for extensibility, but closed for modifcation

OPEN/CLOSED Principle のイメージ
⇒ 電化製品の物理的なソケットとプラグのモデル

- インフラストラクチャ（ソケット）が整備されると、誰でもそれを利用できる（電化製品をプラグイン）（⇒ 拡張に対して Open）。
- 変化するニーズや予期しない要件に対応するためにコードベースやインフラストラクチャの変更を必要としない。新しい要件は既存の他のクラスに変更を加えることなく、新しいクラスの追加のみで事足りる（⇒ 変更に対して Closed）。

## Control Freak アンチパターンと Service Locator アンチパターンとは？その解消法は？

一言でいうと、

- **Control Freak** : DI じゃなくてクラス内で勝手に new

  > **DEFINITION** The Control Freak anti-pattern occurs every time you depend on a Volatile Dependency in any place other than a Composition Root. It’s a violation of the Dependency Inversion Principle.

  ⇒ Composition Root 以外の場所で「new」すると、誰も Intercept できなくなる。結果、オブジェクトのライフタイム管理の責務を負うことを明示的に宣言しているのと同じになる。

- **Service Locator** : DI じゃなくて、グローバルな Factory（サービスロケーター）で勝手自由にオブジェクト取得（＝勝手に new と同じ）

  ⇒ Compsition Root で Static factory を使うのは問題ない。Factory で依存を構築してから Consumer クラスに Inject する。Compsition Root 以外で Factory のような Locator によって依存を取得するのは、Service Locator アンチパターンに該当。

**解消法**：オブジェクトの構築を Compsition Root での DI にする。

## Ambient context アンチパターンを一言でいうと？

Composition Root 以外で使い、かつ volatile dependency を与える Singleton
⇒ 基本的に、Service locator と同じ。複数のサービスを選んで取得できるのが Service locator（例：ファクトリー）で、Logger とか日付みたいな特定のオブジェクトを取得するのが Ambient context

## 4 つのアンチパターンに共通していることは？DI はそれをどう解消するのか？

アンチパターンは全て（VOLATILE・不安定な）依存関係を命令的に要求してしまうこと。そうすることでクラスは ObjectComposition の責務と lifetime 管理の責務を負うことになる。逆に、DI は宣言的に構造化してしまう。

> DI はサービスロケータの反対です。DI はコードを構造化する方法であり、依存関係を命令的に要求する必要がないようにします。代わりに、依存関係を消費者に提供するように要求します。

DI は、クラスから ObjectComposition の責務と lifetime 管理の責務を取り除くので、これらのアンチパターンはなくなり、すべては Compsition Root 側の責務へと変わる。

## Factory は何故「Code Smell」になるのか？どのようにリファクタリングすればよいか？

Factory は不要な依存まで連れてくる。直接の依存をなくしても、背後で推移的に依存している。

> Even worse, the factory always drags along all implementations—even those that aren’t needed!

⇒ 結局のところ、Control Freak アンチパターンは、Factory では解消しない。サービスロケーターも、グローバルのスタティックファクトリのことであり、Compsition Root 以外で使う場合はアンチパターン。

**解１**：Proxy パターンを使ってリファクタリングするのがよい。

- Proxy と Factory では何が違うのか？
  Factory ではインスタンスを new して返すので、呼び出し側でオブジェクトのライフタイム管理の責務が生じる。一方、Proxy では、メソッドが呼ばれた後に内部で new して、メソッドが終わればオブジェクトも消えるので、責務は生じない。

  ⇒ DI によってクラスから取り除かれる二つの責務のうち、Object lifetime の管理の責務がなくなる！8 章でいうところの、**Transient lifestyle** (→ もう一つは Singleton lifestyle)

  ※ 9 章で出てくるが、Proxy は、Intercept として一般化できる。Decorator も、Intercept の一種。

**解２**：Compsition Root で使う分には問題なし

> **NOTE** You might recall from section 6.2 that the use of Abstract Factories should be viewed with suspicion. In this case, however, using Abstract Factory is fine because only the Composition Root makes use of it.

## Proxy, Decorator を一般化する概念は？共通点と違いは？

**Proxy**と**Decorator** は、consumer からの呼び出しの **Intercept** として一般化できる。

> You already saw a bit of this technique in action in listing 8.19, where we used this technique to modify an expensive Dependency’s lifetime by wrapping it in a **Virtual Proxy**. This approach can be generalized, providing you with the ability to **Intercept** a call from a consumer to a service.

⇒ 共通点はどちらもオブジェクトのコンポジションと委譲により、委譲先と同一インターフェースを提供する。Intercept して強化したインターフェースを提供するのが Decorator 、Intercept してオブジェクトのライフサイクル管理をするのが Proxy。どちらも同じインターフェースを提供する。

※ Decorator ではクライアントがオブジェクトのライフサイクルを管理するため、Compsition Root で使うべき。Proxy の場合、Compsition Root 以外の場所で使っても、オブジェクトのライフサイクル管理の責務を気にしなくてよくなる。

c.f. **Adapter**：ラップされたオブジェクトに対しては異なるインターフェースを提供

c.f. **Facade**：実体への緩衝材として機能し、初期化も行うという意味で Proxy と似ているが、同一インターフェースを提供するわけではない。

## Cross-cutting concerns とは？Decorator を使って cross-cutting-concern に対処する例を挙げよ。

**Cross-cutting concerns**は、ソフトウェア開発において、複数のモジュールやコンポーネントにまたがる共通の関心事や機能を指す。これらはアプリケーションに散在・重複しており、複数のモジュールで共有されるため、保守性に影響する。
Proxy パターンや Decorator パターンなどのデザインパターンを使って Intercept し機能追加することで、同一インターフェースでカプセル化を保ちつつ機能付加できる。
例としては

- サーキットブレーカーの追加
- レポーティング機能の追加
- 認証の追加
  など
  ![Untitled](/images/20230621_dependency_injection/1.png)
  ![Untitled](/images/20230621_dependency_injection/2.png)

  **Generic Decorators** という考え方。
  ![Untitled](/images/20230621_dependency_injection/3.png)
