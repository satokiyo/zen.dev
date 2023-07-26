---
title: "Google Cloud Professional Cloud Security Engineer試験受験メモ"
emoji: "📕"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["GCP", "certificate", ]
published: true
---

# 勉強内容QA(※自分用メモ)

- # GCPのプロジェクトの定義を簡潔にいえ

    プロジェクトは課金される対象で、内部に複数〜5個のネットワークを持つもの

    []()

    ![image.png](/images/20221104_professional-cloud-security-engineer/image.png)

- # VPCとは？

    > A VPC network is a **global resource** that consists of a **list of regional virtual subnetworks (subnets) in data centers**, all connected by a global wide area network (WAN). VPC networks are logically isolated from each other in Google Cloud.
    > 

    ⇒ リージョナルのデータセンターがVPCのサブネットに対応し、その集合体のグローバルネットワークが一つの論理的なVPCを構成している。

    - VPCのsubnetはautoモードでregionごとに作られる
    - VM作成時のNetworkInterfaceはVPC(の中のサブネット)を選択できる。マシンにネットワークをくっつける感じ？
- # VPC Network Peeringとは? 同じpeeringでも違うサービスを指しているものは何？また、SharedVPCとの違いは？

    ## VPC Peering

    []()

    - vpc network peeringはVPCを共有する仕組み。GCPに接続する方法の一つであるdirect/carrier peeringとは別！後者のピアリングは、BGPの経路をGCPのルータと交換し、直接ルートを設定する。なのでexternalIPのみで、プライベートアドレス空間へのアクセスはできない。
        - Direct Peering can only access external IP addresses.
    - VPC PeeringはVPCを共有するためのもので、プライベートアドレスアクセスだが、オンプレからのアクセスはできない！プロジェクト間での閉じたネットワークを構築する。

    ![image.png](/images/20221104_professional-cloud-security-engineer/image1.png)

    - VPC network peering can be configured for different VPC networks **within and across organizations**.
    - VPC peeringは複数プロジェクトを繋げられ、内部トラフィックなので、VPNなどのように外部トラフィックを使うより高速！

        []()

        ![image.png](/images/20221104_professional-cloud-security-engineer/image2.png)

        しかもegressに課金されるので、内部トラフィックはコストが安い！

    - DNSでは名前解決できない

        Compute Engine internal DNS names created in a network are not accessible to peered networks. The IP address of the VM should be used to reach the VM instances in peered network.

        ⇒ Internal DNSは各VPC毎に付属するメタサーバの一種なはずなので、別のVPCからはアクセスできないのでは？

        - you cannot use a tag or service account from one peered network in the other peered network

        （追記）DNSピアリングゾーンを作成することで、Producer DNS ゾーンの名前をConsumer DNS ゾーンから参照できる。（[DNSピアリングとは？VPCピアリングとの関係性と違いは何か？](https://zenn.dev/satokiyo/articles/20221104_professional-cloud-security-engineer#DNSピアリングとは？VPCピアリングとの関係性と違いは何か？限定公開ゾーン、クロスプロジェクトバインディングゾーンとの使い分けは？)）


    - peeringはk8sEngineでも使われる。

        ⇒ クラスターを作ると、そのマスターノードがVPCネットワークとpeeringする！


    ## shared vpc

    []()

    web serviceとかでhost pjとservice pjで分け中央で管理するようなとき

    ![image.png](/images/20221104_professional-cloud-security-engineer/image3.png)

    - 各service pjとはプライベート通信できる
    - host 側でsubnetを分ける
    - 中央で管理

        ⇔ peeringはそれぞれで管理


    ## shared vpc vs vpc peering

    []()

    vpc peering wont allow connecting on-premise resources.

    ![image.png](/images/20221104_professional-cloud-security-engineer/image4.png)

    ※ VPC Peeringにはいわゆる**2-hop制限**があり推移的ピアリングは出来ない。つまり1:1の双方向のみ。3つ以上のVPCを共有する場合、フルメッシュでピアリングコネクションを作成する必要がある。⇔*共有 VPC なら、複数のプロジェクトで VPC を共有し、管理機能をホスト プロジェクトに維持したまま、他のプロジェクトは、共有 VPC 内の IP での VM 作成のみに制限できる。*

    *※ shared VPCはプロジェクト間のみ。組織間や、プロジェクト内のサブネット間の共有にはvpc peeringを使う！*

    - SharedVPCでは、ネットワーク管理とコンピューティングリソース管理を切り分けたい場合に有効。アプリや開発インフラ担当者にネットワーク変更までして欲しくない場合などに検討。
- # ADFSとは？

    Active Directory Federation Services

    Federation：連携、連合

    ADFSはSSO環境を提供するもの。ActiveDirectoryの機能の一つ。ADFSは利用者の認証を行い、それを各システムに伝達する　IdP：Identity Provider　として振る舞う。

    ADFSと各サービスは利用者の識別情報と認証状態などを通知するtokenとを交換し、パスワードなどの秘密の情報の登録や照合などはIdP（ADFS）側が集中的に管理する。

    トークンの形式や伝達方式などはWS-Federationや[SAML](https://e-words.jp/w/SAML.html)、[OpenID Connect](https://e-words.jp/w/OpenID.html#Section_OpenIDConnect)などの標準的な規格を利用する。

    > In order to be able to keep using the existing identity management system, identities need to be synchronized between AD and GCP IAM. To do so google provides a tool called **Cloud Directory Sync**. This tool will read all identities in AD and replicate those within GCP.
    > 

    > Once the identities have been replicated then it's possible to apply IAM permissions on the groups. After that you will configure SAML so google can act as a service provider and either your **ADFS** or other third party tools like Ping or Okta will act as the identity provider. This way you effectively delegate the authentication from Google to something that is under your control.
    > 

    ※Cloud Directory Syncは一方向のみなので、AD/LDAP側を変更し、変更を適宜Cloud Identityへ同期する。直接Cloud Identityを編集すると、食い違いが発生する。

- # LDAPとは？

    LDAP（Lightweight Directory Access Protocol）は、Active Directoryのようなディレクトリサービスに　アクセスするためのプロトコル。クライアントはTCPポート番号389を使用してLDAPサーバに接続を行い属性（個人名や部署名）で構成するエントリ（関連属性のまとまり）の検索、追加、削除の操作をする。

    ※LDAPS：LDAP over SSL/TLS

- # SAMLとはどこで使われるか？OAuth、OIDCとの違いを簡潔に説明せよ。

    シングル・サインオン(SSO)を実現する方法として、SAMLとOAuthとがある。互いに代替するというより補完し合うイメージ。例えばMicrosoft環境ではSAMLがアクセス権を付与し、OAuthがスコープを設定してリソースを保護する。OAuthとSAMLはどちらも、相互運用を奨励し標準化するためのプロトコル。ユーザー名/パスワードが増加し続けて重要リソースへのアクセスが妨げられる事態を回避

    - SAML(Security Assertion Markup Language)は「認証」に対応するプロトコル。ユーザー固有になる傾向がある。毎朝、仕事を始める際にコンピューターにログインするときには、SAMLが使用されるケースが多い。SAML認証が完了すると、ユーザーは、企業のイントラネット、Microsoft Office、ブラウザなどのツールスイート全体にアクセスできるようになる。SAMLを使用することにより、ユーザーは1つのデジタル署名でこれらのリソースをすべて利用できる。

    ※SAMLはSSOだけでなくMFAとかリスクベース認証など、様々な認証サービスを提供する

    ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled.png)

    - OAuth(Open Authorization)は「認可(承認)」に対応するプロトコル。アプリケーション固有になる傾向がある

    [SAMLとOAuthの違い | IT管理クラウド](https://i.moneyforward.com/resources/saml_sso)

    ### SAMLによるSSOの仕組み

    様々なベンダが、XML形式のマークアップ言語によるSAMLプロトコルに対応したIDasS(Identity As A Service)サービスを提供している。

    - 認証情報を提供する側を「IdP（Identity Provider）」

        ⇒ GCPのCloud Identity、okta、Microsoft® Azure Active Directory (Azure AD)、VMware Workspace One...etc

    - 認証情報を利用する側を「SP（Service Provider）」

        ⇒ ユーザーが利用するクラウド含むアプリ、サービス

        ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled1.png)


    ## OpenID Connect

    SAMLと同じくSSOの認証プロトコル。IdPはSAMLだけでなく、OIDCプロトコルにも対応している場合がある。しかし、OpenID ConnectはOAuthを拡張した規格であり、OAuthと一緒に利用されて、FaceboookやTwitterなどのSNS認証部分を担うような使われ方が多い。

    ⇔ SAMLは非常に複雑な権限管理を行うことができ、Active Directoryの機能の一つであるADFS（Active Directory Fereration Service）やOktaなどIDPサービスで主に用いられる

    ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled2.png)

- # SSOプロファイルとSAMLプロファイルの違いは？SAMLプロファイルの構成と、SPへの事前登録について説明せよ。

    ### SSOプロファイルとSAMLプロファイル

    SSOの実現手段としてSAMLが使われる。SSO を使用するには、Cloud Identity または Google Workspace のユーザー アカウントとそれに対応する外部 IdP の ID が必要になる。必要なユーザー/グループ/組織にSSOプロファイルを（IdP毎に）作成し、それを有効化するためにSAMLプロファイルを作成する。

    > シングル サインオン（SSO）を使用するように Cloud Identity または Google Workspace のアカウントを構成できます。SSO を有効にすると、ユーザーが Google サービスにアクセスする際にパスワードの入力を求めるメッセージが表示されません。代わりに、外部 ID プロバイダ（IdP）にリダイレクトされます。（**SP Initiated SSO**）
    > 

    ネットワークマッピング、ネットワークマスクを使ってSSOユーザーを制限できる

    > Users with an IP address in the range specified for the Network masks can continue using SSO, while users with IP addresses not in the range of the Network masks must use a password-based login. For example, you can use the Network masks to allow desktop users to use SSO and mobile users to use a password-based login.
    > 

    SAML SSOの流れ（SP Initiated SSO）

    ![https://cdn-ak.f.st-hatena.com/images/fotolife/c/cybozuinsideout/20180821/20180821170728.png](https://cdn-ak.f.st-hatena.com/images/fotolife/c/cybozuinsideout/20180821/20180821170728.png)

    ※認証のシーケンスがSPへのアクセスから始まるSSOを、**SP Initiated SSO**と呼ぶ

    ※SPからリダイレクト経由ではなく、IdPから直接SPへ行く場合（4→8）**IdP initiated SSO**

    ### SAMLプロファイルの構成

    SAMLは複数のコンポーネントで構成され、組み合わせにより様々なユースケースに対応できる。信頼関係が確立された組織間でID・認証・属性・認可の情報（＝SAMLアサーション）を伝達する。SAMLアサーションはBindingsによってProtocolsとBINDされる。

    ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled3.png)

    [SAML Tech OverView SAML Architectureメモ - pikesaku's blog](https://pikesaku.hatenablog.com/entry/2022/04/10/084631)

    ### SPへの事前登録（GCPをSPとする場合）

    SAMLでSSOを実現するためには、事前にIdPとSPの間で信頼関係を構築しておく必要があり、サードパーティのIdP毎にSSOプロファイルを作成する（かつユーザー/グループ/組織に割り当てる）。メタデータの読み込みや、公開鍵の登録などで実現する。

    - ApigeeへのIdPの事前登録の例

        Use **openssl** to generate public and private keys. 

        Store the public key in an X.509 certificate, and encrypt using RSA or DSA for SAML


    逆にGCPをIdPとする場合の流れは？

- # デジタル署名、証明書チェーン、X.509について完結に説明せよ

    ### デジタル署名

    「**秘密鍵**を用いて生成された**署名**を**公開鍵**で**検証**することにより」、「データが改竄されていないこと」や「秘密鍵の保持者が確かに署名したこと」を確認する

    流れ

    1. 秘密鍵と公開鍵のペアを作る。
    2. 相手に送りたいデータを秘密鍵を用いて署名に変換し、データ＋署名を相手に送る。→これってデータのハッシュを秘密鍵で暗号化すれば、それはメッセージダイジェスト！つまりデジタル署名って改ざん検知とかに使うメッセージダイジェストのことか！？受取り側では公開鍵で復号したデータのハッシュ値と、自分で計算したハッシュを比較して改竄されていないか確認できる。
    3. 何らかの方法で相手に公開鍵を渡す。
    4. 相手は公開鍵を用いて署名を検証する。

        ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled4.png)


    ### 証明書チェーン

    その公開鍵が本物かどうか第三者が証明書を作成する

    1. 証明書のデータは、証明対象となる公開鍵＋その公開鍵に対応する秘密鍵を持っている人の情報＋証明書の発行者（自分）の情報
    2. この証明書の内容を保証するため、デジタル署名をする。
    3. そのために、デジタル署名用の秘密鍵と公開鍵のペアを作成
    4. それから、秘密鍵を用いてデジタル署名をおこなう。これで証明書の完成
    5. 公開鍵を直接渡す代わりに、その公開鍵を含み、その出所を証明する証明書を渡す。

        ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled5.png)

    6. これにより、元々欲しかった公開鍵（図中の「A の公開鍵」）は証明付きで入手できる。しかし、証明書のデジタル署名を検証するための公開鍵（図中の「B の公開鍵」）が必要になってしまう。。。。これでは際限がなく思えるが、公開鍵の証明書を公開鍵の主体者本人が作成することで終結する。デジタル署名を付ける際に使う秘密鍵は、証明対象の公開鍵とペアの秘密鍵を使う。このように、証明対象となる公開鍵とペアになっている秘密鍵を用いて署名することを、**自己署名**と言い、自己署名によって作成された証明書を**自己署名証明書**と言う
    7. 自己署名証明書は起点となる証明書なので、信頼済みの証明書としてあらかじめ持っておく必要があります。

        ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled6.png)

    8. これらの証明書は鎖のように繋がっている。このように連なった証明書群全体を**証明書チェーン**（certificate chain）と呼びます。
    9. そして、起点となる自己署名証明書を**ルート証明書**（root certificate）、中間にある証明書を**中間証明書**（intermediate certificate）と呼びます。中間証明書の数は 2 以上になりえます。

    [図解 X.509 証明書 - Qiita](https://qiita.com/TakahikoKawasaki/items/4c35ac38c52978805c69)

    ### X.509証明書

    証明書の構造は [RFC 5280](https://tools.ietf.org/html/rfc5280)
     という技術文書で定義されています。X.509 証明書という名前は、同技術文書のタイトル「Internet X.509 Public Key Infrastructure Certificate and Certificate Revocation List (CRL) Profile」から来ています。

    ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled7.png)

- # 公開鍵暗号と共通鍵暗号の暗号化アルゴリズムの代表例を挙げよ

    ![screenshot-www.infraexpert.com-2022.08.05-12_38_22.png](/images/20221104_professional-cloud-security-engineer/screenshot-www.infraexpert.com-2022.08.05-12_38_22.png)

- # リソース階層とポリシーの関係性を言え
    - ポリシー＝ロール＋ユーザー

    []()

    ![image.png](/images/20221104_professional-cloud-security-engineer/image5.png)

    - リソース階層にポリシー(=ユーザーやSAとロール)をくっ付けて設定し、継承させる
    - GCPのリソース階層にはワークスペースメンバーとかGmailメンバーも追加できる！

        []()

        ![image.png](/images/20221104_professional-cloud-security-engineer/image6.png)

- # Cloud IAMのcustom rolesのetag、--stage flagとは？

    ### --stage flag

    --stage flagをENABLEにしたりDISABLEにできるし、custom rolesをdeleteすると、stageがDeletedになる。Roleを新しいものに置き換えた時に古いものをDEPRECATEDのstageに設定することも推奨される。一旦deleteした後にundeleteコマンドで復活させると、--stageタグがもとに戻っている。

    ※ [キーのバージョン](https://www.notion.so/f609f89cda7d43b6824d6a45040523c6) と類似。

    ### etag

    > if two owners for a project try to make conflicting changes to a role at the same time, some changes could fail.
    > 

    > Cloud IAM solves this problem using an `etag` property in custom roles. This property is used to verify if the custom role has changed since the last request. When you make a request to Cloud IAM with an etag value, Cloud IAM compares the etag value in the request with the existing etag value associated with the custom role. It writes the change only if the etag values match.
    > 
- # Dynamic Groupとは?

    > 動的グループは、メンバークエリや、役職や勤務地などの従業員属性のクエリを使用して自動的に管理される Google グループです。たとえば、メンバークエリは「組織内でテクニカル ライターの役割を持つすべてのユーザー」などになります。
    > 

    > In Dynamic Groups, users are automatically managed and added based on Identity
    attributes, such as department.
    > 

    [動的グループの概要 | Cloud Identity | Google Cloud](https://cloud.google.com/identity/docs/concepts/overview-dynamic-groups?hl=ja)

- # Lienとは？

    「リーエン」は、単純なミスでプロジェクトが消えないようにするためのプロジェクト保護用の設定のこと

    例）組織レベルのポリシー制約で、compute.restrictXpnProjectLienRemovalを有効にするとユーザーが誤って削除しないように強制できる。(xpn：SharedVPCのこと。CrossProjectNetwork)


- # GCSのIAMパーミッションはどのレベルまで？

    bucket level まで。オブジェクト毎には設定できないらしい。

    → 細かいアクセス制御にはACLを使う。が、推奨はされない。

    ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled8.png)

- # ドメイン全体への移譲とは？

    > in order to be able to access user's google drive accounts on user's behalf we need to use wide domain delegation. In order to make this work the steps would be the following:
    > 
    > 
    > 1) Enable Gmail API at the project level in GCP: we need to do this to access google drive.
    > 
    > 2) Create a service account
    > 
    > 3) Grant domain access to the account and enable g suite domain-wide delegation
    > 
    > 4) Include the code to use the API (e.g using python) in our App Engine application.
    > 
- # Google Cloud のロードバランサの種類と使い分けについて説明せよ。プロキシ型とパススルー型は何が違うか？IAPとの関係について完結に述べよ。

    参考：[https://www.topgate.co.jp/google-cloud-load-balancer#i-5](https://www.topgate.co.jp/google-cloud-load-balancer#i-5)

    - 全ての要素を一枚で図示しると以下のようになる。

        ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled9.png)


    - ツリー形式で図示すると下記

        ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled10.png)

    - internalロードバランサーはリージョナルのみ
    - 内部プロキシ型のLBは、OSSのenvoy proxy がベースになっている
    - Googleのアンドロメダのブログポスト読め
    - 外部 HTTP（S）負荷分散と内部 HTTP（S）負荷分散では、バックエンドに手を入れず、ロードバランサーでインテリジェントなルーティングを実現できる。これにより、簡単な A/B テストやカナリアリリース、再試行、外れ値検出、サーキットブレーカーetc.を行うことが可能。

    ### プロキシ型とパススルー型について。

    []()

    - 左がプロキシ型、右がパススルー型

        ![image.png](/images/20221104_professional-cloud-security-engineer/image7.png)

    - ロードバランサーには、プロキシ型とパススルー型という分類がある。プロキシ型はクライアントから届いたリクエストをロードバランサーで受け取り、そのロードバランサーが別のセッションとしてバックエンドに通信を行う。そのため、ロードバランサーにリクエストが届く前後で送信元と送信先が変わる。

        ⇒ プロトコルの変換が可能！

    - 一方、パススルー型はクライアントから届いたリクエストをそのままバックエンドに届ける。そのため、ロードバランサーにリクエストが届く前後で送信元と送信先が変わることはない。

    ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled11.png)

    ### IAP(Identity-Aware Proxy)との関係について

    アプリケーションに認証を追加する場合、本来はアプリケーション自体に手を加える必要がある。 Identity-Aware Proxy （IAP）を使うことで認証部分をロードバランサーで完結でき、認証が終わったリクエストのみをバックエンドに送ることが可能。

    認証には、 Google アカウントや OAuth 、 SAML 、 OIDC などの一般的な認証プロトコルを網羅していて、既存の認証 DB をそのまま利用して認証できる点も大きなメリット。

    ⇒ IAPも、Cloud Armorみたいに、LBにつく！

    ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled12.png)

- # SSLロードバランサーのデフォルトのSSLポリシーは？

    SSL load balancers have three pre-configured profile:

    - **COMPATIBLE.** Allows the broadest set of clients, including clients that support only out-of-date SSL features, to negotiate SSL with the load balancer.
    - **MODERN.** Supports a wide set of SSL features, allowing modern clients to negotiate SSL.
    - **RESTRICTED.** Supports a reduced set of SSL features, intended to meet stricter compliance requirements.

    If no SSL policy is set, your load balancer will use the default SSL policy, which is equivalent to one that uses a COMPATIBLE profile with a minimum TLS version of TLS 1.0.

- # TCP proxy/TCPUDPロードバランサーの違い？
    - TCP Proxy Load Balancing is implemented on GFEs that are distributed globally. If you choose the Premium Tier of Network Service Tiers, a TCP proxy load balancer is **global**. In Premium Tier, you can deploy backends in multiple regions, and the load balancer automatically directs user traffic to the closest region that has capacity. TCP Proxy Load Balancing is intended for TCP traffic on specific well-known ports, such as port 25 for Simple Mail Transfer Protocol (SMTP) or 995 (POP3).
    - TCP/UDP network load balancer is **regional** not global.
- # IAP TCP 転送とは？メリットは？

    外部 IP アドレスを持たない、またはインターネット経由の直接アクセスを許可しない VM インスタンスへIAPを介してssh接続とかをする方法

    - ファイヤーウォールルールを対象の非公開VPCに設定し、IP 範囲 `35.235.240.0/20` からの上り（内向き）トラフィックを許可する
    - この範囲には、IAP が TCP 転送に使用するすべての IP アドレスが含まれています。
    - IAP TCP 転送を使用してアクセス可能にするすべてのポートへの接続を許可します。たとえば、SSH のポート `22` と RDP のポート `3389` です。

    **メリット**は、IAPを使えば踏み台サーバが不要になること！

    ⇔ 逆に外部IPを持たないVMがEgressアクセスするには、

    1. NATゲートウェイを使う
    2. Private Google Accessを使う(Google API のみ)という方法がある

    [Using IAP for TCP forwarding | Identity-Aware Proxy | Google Cloud](https://cloud.google.com/iap/docs/using-tcp-forwarding)

- # VPNの実装方式の種類を整理せよ。SSLとIPSecの違い、VPNとIAPの違いを述べよ。Cloud VPNの特徴は？

    ### VPNの分類

    1. 使用する回線によって分類
        - インターネットVPN
        - IP-VPN(通信事業者のアクセス回線を使用)
    2. プロトコルで分類
        - SSL-VPN
        - IPSec-VPN
        - PPTP-VPN
        - L2TP-VPN
        - など。

    ![IMG_7541.jpg](/images/20221104_professional-cloud-security-engineer/IMG_7541.jpg)

    ### IPSec VPN vs SSL VPN

    - ネットワーク丸ごとか、ポート毎か
    - 実現するセキュリティレベルは同じくらい
    - IPSecは専用の機器がいるので、コスト高い。が、高速。IPSecはトランスポート層のTCPやUDPのヘッダが見えないのでファイヤーウォールルールを設定できない
    - SSLはソケット全体でないので、細かい設定ができる。デメリットは基本的にwebベースアプリケーションでないと、導入が面倒。SSL-VPNはhttpsを利用したVPN、https-VPNとも言えそう？

    ### IAPとの違い

    本質的な違い

    - VPNは社内ネットワーク全体を制御(=境界制御)。一度パスワード漏洩して侵入されると危険性高い。
    - IAPはIAMと連携しているので、アプリ単位で細かく認証、認可できる。侵入されても攻撃が他のアプリに及ばない。

    類似点

    - とはいえIAPも技術的にはSSL-VPNと類似。以下の記事で書いてあるが、SSL over WebSocketが実体らしい。

        > Cloud IAP は簡単に言うと Google Cloud (旧称 GCP) が提供する**フルマネージドのリバースプロキシ**です。フルマネージドですので、利用者は IAP を構築したり運用・保守する必要はありません。
        > 
    - IAPのコネクタとか、VPNのサーバをクラウド側で管理してくれる、Managed VPNのイメージに近いかも。Cloud IAPはGoogleが管理してくれているVPNサーバのようなもので、背後でIAMと連携している。リバースプロキシが、IPではなくアプリケーションレイヤーで動作して、細かく制御するのだ。

    ### Cloud VPNについて

    - Cloud Routerと一緒に使うことで、Dynamic routingしてくれる。

        []()

        ![image.png](/images/20221104_professional-cloud-security-engineer/image8.png)

    - 新しく追加されたネットワークは自動的に通知(アドバタイズ)され、静的IPの管理は不要

        []()

        ![image.png](/images/20221104_professional-cloud-security-engineer/image9.png)

    - デフォルトのルート アドバタイズ=リージョナル
        - Cloud Router は、基本的にリージョナル。
        - デフォルトでマルチリージョンのVPCに一つのCloud Routerが対応するのではなくて、その中の特定リージョンのサブネットに対して一つのCloud Routerが対応する(**リージョン動的ルーティングモード**)
    - グローバルルーティング
        - 設定を変えてグローバルリージョン、つまりVPCのサブネット全体のルートをアドバタイズする**グローバル動的ルーティングモード**にすることもできる。

    > Cloud Router によって、ルーターが構成されているリージョンまたは Virtual Private Cloud（VPC）ネットワーク全体でサブネットが動的にアドバタイズされて、学習済みルートが伝播されます。
    > 

    > VPC ネットワーク内の Cloud Router がリージョンかグローバルかは、VPC ネットワークの動的ルーティング モードによって異なります。VPC ネットワークを作成または編集するときに、動的ルーティング モードをリージョンまたはグローバルに設定できます。
    > 

    [動的ルーティング モードを設定する | Cloud Router | Google Cloud](https://cloud.google.com/network-connectivity/docs/router/how-to/configuring-routing-mode?hl=ja)

    ※ **アドバタイズする**

    ネットワーク制御分野の用語。Cloud Router の場合、隣接するネットワークのルータに対象（サブネットや外部 IP アドレス）への経路情報を伝達することを指す。

    [GCP IAP tunnel を HTTP プロキシを通して利用する場合の注意点](https://www.qoosky.io/techs/fd7e826326)

    [PPTP - ネットワーク入門サイト](https://beginners-network.com/vpn_pptp.html)

    [IPsec vs. SSL VPN: Comparing speed, security risks and technology](https://www.techtarget.com/searchsecurity/tip/IPSec-VPN-vs-SSL-VPN-Comparing-respective-VPN-security-risks)

- # GCPにおけるDNSとメタデータサーバについて説明せよ。
    - ~~各VMは~~各VPCはそれぞれメタデータサーバーを持っており、それがDNSresolverとしても働く。ローカルリソースの名前解決の問い合わせに応える。ローカルリソース以外はGoogleのパブリックDNSにルーティングする。
        - ExternalIPアドレスはGoogleのCloudDNSやGoogle以外のDNSサービスに登録する必要がある。内部DNSだけでなく。
        - internalIPはVMがマストで持つ。External IPはオプションで、一時的。

            internalIPはVMのOSが自分で知っているが、externalは知らない！外側からマッピングするのだ！

    - DNSサービスを持つのは、各VMではなくて、VPCネットワークらしい

        > VPC networks have an internal DNS service that allows you to address instances by their DNS names instead of their internal IP addresses. When an internal DNS query is made with the instance hostname, it resolves to the primary interface (nic0) of the instance.
        > 

        ⇒ VPCに属するすべてのVMインスタンスを管理する**メタサーバ**サービスがあって、それがDNSサービスもしている感じ？そのVPCに属しているVMの名前解決クエリが来たら応答する？で、複数NICをもつVMがある場合、NIC０のドメインへ名前解決されるぽい。

    - VPCの**プライベートGoogle Access**を有効にしておけば、BQとかGCSなどGoogleのAPIに内部からアクセスできる！

        ⇔ 普通のインターネット接続はNATゲートウェイ設定しないとダメ。

        - Cloud functionとかCloud Runとかは外部IPを持ってるから、Google APIでBQとかGCSにアクセスできる。
    - メタデータサーバーのIPは、169.254.169.254で固定。なので、InternalDNSでもmetadata.google.internalで名前解決できる。

        ※このアドレスレンジは、TCP IAP転送で、外部IPを持たない非公開VPCに踏み台無しでアクセスするような時に、ファイヤーウォールで許可しておくレンジ。要するにメタデータサーバー(それか近くのレンジのサーバー)経由でIAP接続されるはず。

    - デフォルトのVPCを削除すると、新たに自分でVPCを作らない限り、新たなVMは作れない！つまり本来VPCの中にリソースを作るのであって、デフォルトでは見えなくなっているのだ。その見えないものの中にメタデータサーバなどもある。
- # Cloud DNSにおける、転送ゾーン、ピアリングゾーン、マネージド逆引き参照ゾーン、プロジェクト間バインディングゾーンについて、それぞれ簡単に説明せよ。

    ### マネージド ゾーン

    - Cloud DNS では、マネージド ゾーンは **DNS ゾーン**をモデル化するリソース

        ⇒ GoogleマネージドなDNSゾーン

    - プロジェクトには複数のマネージド ゾーンを含めることができる
    - マネージド ゾーン内のすべてのレコードは GCPマネージドなネームサーバー上でホストされ、そのゾーンに対するDNSクエリに応答する。

    ※以下は全てマネージドゾーン

    ### 一般公開ゾーン

    - インターネットに公開されるDNSゾーン
    - Cloud DNS には、クエリの発信元に関係なく、一般公開ゾーンに関するクエリに応答する一般公開された権威ネームサーバーがある

    ### 限定公開ゾーン

    - 承認した 1 つ以上の Virtual Private Cloud（VPC）ネットワークによってのみクエリできる DNS レコードのコンテナ。
    - 基になる DNS データを公共のインターネットにさらすことなく、仮想マシン（VM）、ロードバランサ、その他の Google Cloud リソースのカスタム ドメイン名を管理できる。
    - 限定公開ゾーンは、それが定義されている**同じプロジェクト内のVPCネットワークからのみ**クエリできる。⇔ 他のプロジェクトの限定公開マネージド ゾーンにホストされているレコードをクエリする必要がある場合は、DNS ピアリングを使用する。

    ### 転送ゾーン

    - そのゾーンに対するリクエストを転送先の IP アドレスに送信する Cloud DNS 限定公開マネージド ゾーン

    ### ピアリング ゾーン

    - **他プロジェクトのVPC ネットワークの名前解決順序に従う** Cloud DNS 限定公開マネージド ゾーン
    - データは、名前解決順序に従ってプロデューサー VPC ネットワークから取得される。
    - コンシューマーVPCネットワークはプロデューサーVPCネットワークからルックアップする。

    ### マネージド逆引き参照ゾーン

    - Compute Engine の DNS データに対して PTR 参照を実行できる特別な属性（＝PTRレコード）を持った限定公開DNSゾーン
        - リバースルックアップ：逆参照。IPアドレス→ドメイン名の変換。DNS権威（コンテンツ）サーバーが参照するゾーンファイル内で、A（AAAA）レコードの逆にあたるPTRレコードを使う。
    - A reverse lookup private zone helps you create PTR (pointer) records.
    PTR records help translating IP addresses to domain names, which is not the
    requirement.

    ### プロジェクト間（クロスプロジェクト）バインディングゾーン

    - 共有VPCにおいて、各サービス プロジェクトが、自身のサブネットのDNS 名前空間所有権を保持できるDNSゾーン。責任範囲の分離と自律性が高まる。

        ⇔ 一般的な共有 VPC 設定では、サービス プロジェクトが仮想マシン（VM）アプリケーションまたはサービスの所有権を持っているが、VPC ネットワークとネットワーク インフラストラクチャの所有権はホスト プロジェクトが所有する。


    > A cross-project binding zone allows you to manage the ownership of
    DNS zones between a shared VPC and the VPCs consuming the resources,
    > 

    次の図は、DNS ピアリングを使用した一般的な共有 VPC 設定を示しています。

    ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled13.png)

    次の図は、プロジェクト間のバインディングを使用した設定を示しています。

    ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled14.png)

    [Key terms | Cloud DNS | Google Cloud](https://cloud.google.com/dns/docs/key-terms)


- # DNSピアリングとは？VPCピアリングとの関係性と違いは何か？限定公開ゾーン、クロスプロジェクトバインディングゾーンとの使い分けは？

    ### DNSピアリング

    A DNS peering zone creates a producer-consumer bridge between two
    VPCs. The consumer VPC can then perform lookups in the producer VPC network,
    including records hosted inside a Compute Engine instance. Use DNSSEC to
    authorize requests and protect from exfiltration.

    > DNS ピアリングを提供するには、**Cloud DNS ピアリング ゾーン**を作成し、そのゾーンの名前空間のレコードが利用可能な VPC ネットワークで DNS ルックアップを行うように構成する必要があります。
    > 

    ※ **他のプロジェクトの**限定公開マネージド ゾーンにホストされているDNSレコードをもつCloud DNSコンテンツサーバーにクエリする必要がある場合は、**DNS ピアリング**（ピアリングゾーン）を使用する。⇔ 一方、**同じプロジェクト内の**VPCネットワークからのみクエリする場合、**限定公開ゾーン**を使う。

    ※ 共有VPCにおいて、各サービス プロジェクトが、自身のサブネットのDNS 名前空間所有権を保持できるDNSゾーンは**クロスプロジェクトバインディングゾーン**。責任範囲の分離と自律性が高まる。⇔ 一般的な共有 VPC 設定では、DNSピアリングでピアリングゾーンを作成もできるが、DNSピアリングだとVPC ネットワークとネットワーク インフラの所有権はサービス プロジェクトではなくホスト プロジェクトが所有する。

    ### VPCピアリングとの関係性

    > • DNS ピアリングと [VPC ネットワーク ピアリング](https://cloud.google.com/vpc/docs/vpc-peering)は異なるサービスです。DNS ピアリングは VPC ネットワーク ピアリングと組み合わせて使用できますが、VPC ネットワーク ピアリングは DNS ピアリングに必須ではありません。
    > 

    ⇒ VPCピアリングをしなくても、DNSピアリングはできる。

    [DNS zones overview | Google Cloud](https://cloud.google.com/dns/docs/zones/zones-overview#peering_zones)

    ### ※DNS Forwardingとの違い

    オンプレとのハイブリッドネットワークではお互いにDNSフォワーディングする「ハイブリッドアプローチ」が推奨されているが、DNSピアリングはVPC内部の話。以下の図が分かりやすい。

    ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled15.png)

    [Cloud DNS の転送、ピアリング、限定公開ゾーンについて | Google Cloud Blog](https://cloud.google.com/blog/ja/products/networking/cloud-forwarding-peering-and-zones)


- # ハイブリッドネットワークでDNS resolutionが実行される場所の推奨方法は？異なるGCP環境の場合はどうするか？

    **Use a hybrid approach with two authoritative DNS systems**

    ⇒ ハイブリッドアプローチ

    > *Google-recommended practice is to use a hybrid approach with two authoritative DNS systems. Authoritative DNS resolution for your private Google Cloud environment is done by Cloud DNS. Authoritative DNS resolution for on-premises resources is hosted by existing DNS servers on-premises.*
    > 

    ⇒ DNSコンテンツサーバー(=権威DNSサーバー)をCloudとOn Premにおいて、互いにフォワーディングする。

    ※ 異なるGCP環境のDNSはフォワーディングできない。

    > Cloud DNS cannot manage interorganizations DNS querys.
    > 

    その場合、VPNで二つの環境を接続して、DNSフォワーディングとゾーン転送の設定をする必要がある。

    [※ **他のプロジェクトの**限定公開マネージド ゾーンにホストされているDNSレコードをもつCloud DNSコンテンツサーバーにクエリする必要がある場合は、**DNS ピアリング**（ピアリングゾーン）を使用する。⇔ 一方、**同じプロジェクト内の**VPCネットワークからのみクエリする場合、**限定公開ゾーン**を使う。](https://zenn.dev/satokiyo/articles/20221104_professional-cloud-security-engineer#**他のプロジェクトの**限定公開マネージド-ゾーンにホストされているDNSレコードをもつCloud-DNSコンテンツサーバーにクエリする必要がある場合は、**DNS-ピアリング**（ピアリングゾーン）を使用する。⇔-一方、**同じプロジェクト内の**VPCネットワークからのみクエリする場合、**限定公開ゾーン**を使う。)

    ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled37.png)

    [Best practices for Cloud DNS | Google Cloud](https://cloud.google.com/dns/docs/best-practices#choose_where_dns_resolution_is_performed)

- # Router vs Gateway?

    ゲートウェイは、異なるネットワーク同士を中継する仕組みの総称。その1つとして、IPアドレスを判別してネットワークを中継するルーターがある。

    VPNゲートウェイを使うときに、Cloud　Routerも一緒に使っている。要するにL3レベルのルーティングにRouterが必要で、それ以上の層のVPN通信の出入り口にはVPNゲートウェイが必要。

    ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled16.png)

- # Cloud Router

    ## **Cloud Router**

    Cloud Routerはスタティックとダイナミックルーティングに対応。

    - Dynamic Routing

        ダイナミックルーティングを使うには、BGP設定が必要。ルーター同士でBGPに従い、ネットワークの追加削除などのトポロジー変化を自動でアドバタイズし、静的アドレスの管理とかが不要になる。

        - アドバタイズする

            ネットワーク制御分野の用語。Cloud Router の場合、隣接するネットワークのルータに対象（サブネットや外部 IP アドレス）への経路情報を伝達することを指す。


        経路制御のための代表的なプロトコルがBGP。BGP で GCP 内外のネットワークとルーティングするためのサービスが Cloud Router。Cloud Routerと外部のルータなりゲートウェイの間でBGPセッションがなされ、各AS内部のルート情報が交換されることで、ほかのASへのアクセスを獲得できる。

        新しく追加されたネットワークは自動的に通知(アドバタイズ)される

        []()

        ![image.png](/images/20221104_professional-cloud-security-engineer/image9.png)

    - Static Routing

        BGPが不要なルーティング

        > Policy-based and Route-based routing are the possible routing options in Cloud VPN that does not require BGP.
        > 

        ⇔ "Dynamic"  requires BGP


    ### Cloud Routerデフォルトのルート アドバタイズ

    Cloud Router は、基本的にリージョナル。

    ⇒ デフォルトでマルチリージョンのVPCに一つのCloud Routerが対応するのではなくて、その中の特定リージョンのサブネットに対して一つのCloud Routerが対応する(**リージョン動的ルーティングモード**)。設定を変えてグローバルリージョン、つまりVPCのサブネット全体のルートをアドバタイズする**グローバル動的ルーティングモード**にすることもできる。

    > Cloud Router によって、ルーターが構成されているリージョンまたは Virtual Private Cloud（VPC）ネットワーク全体でサブネットが動的にアドバタイズされて、学習済みルートが伝播されます。
    > 

    > VPC ネットワーク内の Cloud Router がリージョンかグローバルかは、VPC ネットワークの動的ルーティング モードによって異なります。VPC ネットワークを作成または編集するときに、動的ルーティング モードをリージョンまたはグローバルに設定できます。
    > 

    [動的ルーティング モードを設定する | Cloud Router | Google Cloud](https://cloud.google.com/network-connectivity/docs/router/how-to/configuring-routing-mode?hl=ja)

- # WAFとは？Firewallとの違いは何？

    WAF（Web Application Firewall）は、Webアプリケーションの脆弱性を突いた攻撃へ対するセキュリティ対策のひとつ。Webアプリへのアクセスを「シグネチャ」（アクセスのパターンを記録しているもの）を用いて照合し、攻撃を検知、通信可否の判断を行う。

    ファイアウォール（Firewall）は、ネットワークレベルでの対策であり、IP:ポート番号でアクセスを制限するソフトウェアおよびハードウェアのこと。社内でのみ使用する情報システムへの外部からのアクセスを制限することは可能だが、外部へ公開する必要のあるWebアプリケーションに制限を掛けることはできないので、WAFの範疇となる。

- # Google Front Endと、Cloud Armorについて簡潔に説明せよ。

    ### GFE（Google Front End）

    以下の全体を指すらしい

    1. GCPのPoP （Point Of Presence）：各リージョンのデータセンターの入り口
    2. ユーザーリクエスト(外部インターネットから着信する HTTP(S)、TCP、TLS プロキシのトラフィック)は、PoPの中のロードバランサーに向かい、一番近いPoPへ入る
    3. トラフィックをロードバランサで終端し、DDoS 攻撃対策を提供(→L7レベル、**Cloud Armor**)して、Google Cloud サービス自体へのトラフィックをルーティングおよび負荷分散(over Google's global network to the closest backend that has sufficient capacity available.)

         ⇒ CloudArmorも、LBと同じくエッジPOPにある

        > Google Cloud プロキシベース外部ロードバランサはすべて、Google の本番環境インフラストラクチャの一部である Google Front End（GFE）から DDoS 保護を自動的に継承します。
        > 

    ### Cloud Armor

    - Google Cloud Armorは、ロードバランサーの付加機能として利用する。
    - DDoS保護＋WAF。レイヤ7属性のリクエストをレイヤ7フィルタリングやスクラブによりブロックする。
        - DoS

            TWO ways that Google Cloud helps mitigate the risk of DDoS for its customers.

            1. **Internal capacity many times that of any traffic load we can anticipate.** → 大規模DoS攻撃の負荷も簡単に吸収してしまう。
            2. **State-of-the-art physical security for hardware and servers.**

    - 外部 HTTP(S) ロードバランサ、TCP プロキシ ロードバランサ、または SSL プロキシ ロードバランサの背後にあるバックエンド サービスにのみ使用できる。負荷分散スキームはexternalである必要。
    - プレビューモードを使うとルールを適用しなくても、その影響をプレビューが可能。

    ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled.jpeg)

- # Google Cloud におけるデータ転送時の暗号化について、プロトコルと実装に使われるのは？

    ### BoringSSL(実装ライブラリ)

    Googleにおける、転送時のデータ暗号化で使われているライブラリ。GoogleFrontEndにおけるTLS暗号化プロトコルの実装に使われる。 Google が維持管理する TLS プロトコルのオープンソース実装であり、OpenSSL から分岐したもの。

    内部 HTTP(S) 負荷分散は、Google の BoringSSL ライブラリを使用。Google は、FIPS-2 準拠モードで内部 HTTP(S) 負荷分散のための Envoy プロキシを構築。

    ⇔ HTTP(S) 負荷分散と SSL プロキシ負荷分散は Google の BoringCrypto ライブラリを使用する

    > BoringSSL as a whole is not FIPS validated. However, there is a core library (called BoringCrypto) that has been FIPS validated.
    > 

    ※ **FIPS**（Federal Information Processing Standard：米国連邦情報処理規格）**140-2**は、暗号化ハードウェアの有効性を検証するためのベンチマーク。製品がFIPS 140-2認定の場合、その製品が米国政府とカナダ政府によってテストされ、正式に検証されていることを示す。

    ⇒ Boring SSLのうち、FIPS-2準拠のコアモジュールはBoring Cryptoと呼ばれる。顧客転送中やデータセンター間、保存中データなどはBoringCryptoでFIPS-2準拠モジュールで暗号化されるが、ローカルSSDストレージなどは非対応なので、独自の暗号化を提供する必要がある。

    ### TLS/ALTS( プロトコル)

    **ALTS**(Application Layer Transport Security)という暗号化プロトコルもあり、こちらもBoringSSLで実装される。 ALTSは相互認証/暗号化によりRPCをカプセル化するプロトコル。Google Cloud サービスの場合、RPC はデフォルトで ALTS を使用して保護される。

    > Google’s Application Layer Transport Security (**ALTS**) is a mutual authentication and transport encryption system developed by Google and typically used for securing Remote Procedure Call (RPC) communications within Google’s infrastructure. ALTS is similar in concept to mutually authenticated TLS but has been designed and optimized to meet the needs of Google’s datacenter environments.
    > 

    ※ **remote procedure call** (**RPC**) is when a computer program causes a procedure (subroutine) to execute in a different address space (commonly on another computer on a shared network), which is coded as if it were a normal (local) procedure call, without the programmer explicitly coding the details for the remote interaction.

    ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled17.png)

    ALTS には相互 TLS に似た安全な **handshake** プロトコルがある。ALTS を使用して通信しようとする 2 つのサービスは、機密情報を送信する前に、この handshake プロトコルを使用して通信パラメータを認証およびネゴシエートする。

    ![https://cloud.google.com/static/images/security/alts-handshake.png?hl=ja](https://cloud.google.com/static/images/security/alts-handshake.png?hl=ja)

    [Google Cloud での転送データの暗号化 | ドキュメント](https://cloud.google.com/docs/security/encryption-in-transit?hl=ja)

- # API Throttling and Rate Limiting: What’s the Difference?

    throttlingはサーバー(API)への負荷を制限する目的、API rate limitingは個人による集中アクセスを制限する目的。

    ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled18.png)

- # タグとラベル、ファイヤーウォールルールについて説明せよ。

    ### (ネットワーク)タグ

    - VPC内の特定のVMインスタンス群にファイヤーウォールルールを簡単に適用できるもの。

        Network tags are used by networks to identify which VM instances are subject to certain firewall rules and network routes.

    - ファイヤウォールルールはタグとサービスアカウントにもつけられる！
        - サービスアカウント間でファイヤーウォールルールを設定すれば、タグ間とは違って、スコープを設定できるので、スコープで認可された通信のみを許可できる。
        - サービスアカウントへのアクセスが必要になるので、IAMロールと組み合わせて特定の承認ユーザーだけのアクセスを許可するようにできる。

        ![image.png](/images/20221104_professional-cloud-security-engineer/image10.png)


    []()

    ### ラベル

    - ラベルは、GCPのBilling情報にマーキングして、BQやDataStudioで見るときに便利
    - リソース階層を設定するときにも「ラベル」を使うと便利

        ![image.png](/images/20221104_professional-cloud-security-engineer/image11.png)


    ### ファイヤウォールルール

    []()

    - デフォルトのファイヤーウォールルールでは、インバウンドは全てブロック、アウトバウンドは全て許可

        ![image.png](/images/20221104_professional-cloud-security-engineer/image12.png)


    - デフォルト(暗黙)のファイヤーウォールのログは出力されない。ログが欲しければpriority65500で同じルールを作成してログを有効にする必要がある。(VMのログを有効化しても意味ないので、VPCのログを有効にする)

    > The traffic is not matching the expected ingress rule, thus it will fall to the IMPLICIT DENY INGRESS RULE which is never logged. Ingress packets are sampled after ingress firewall rules. If an ingress firewall rule denies inbound packets, those packets are not sampled by VPC Flow Logs.
    > 

    ⇒ VPCの全trafficを見るためには、以下二つのログを有効にする必要あり

    1. VPC Flow logs

        VPC Flow logs captures samples of the traffic flowing in and out of the subnet

    2. Firewall logs

        Firewall logs shows traffic (allowed or denied) that has matched a firewall rule


    - Network Admin/Security Role、ファイヤーウォールルールを設定できるのは、、
        - **Network Admin:** Permissions to create, modify, and delete networking resources, except for firewall rules and SSL certificates.
        - **Security Admin:** Permissions to create, modify, and delete firewall rules and SSL certificates.
    - egress firewall ruleを設定できるインスタンスは？

        There are **only two google services that allow to filter egress traffic and those are Google Compute Engine and Kubernetes Engine**.  Regarding App Engine and Cloud functions, ingress rules are available but egress ones are not, so it's not a valid option. Cloud storage doesn't not allow to apply firewall rules.

    - hostnameでファイヤーウォールルールを設定できるか？

        ⇒ 出来ない。

        > When specifying a source for an ingress rule or a destination for an egress rule by address, you can only use an IPv4 address or IPv4 block in CIDR notation. Therefore is not possible to allow the traffic to a hostname.
        > 
- # 外部IPを持たないVMがEgressアクセスする方法を二つ挙げ、それぞれ説明せよ。

    ### NAT Gateway vs Private Google Access

    - Google API へのアクセスの場合、Private Google Access を使う。

        > VM instances that have no external IP addresses can use **Private Google Access** to reach external IP addresses of Google APIs and services. By default, Private Google Access is disabled on a VPC network
        > 

        ⇒ VPCのサブネットの設定でPrivate Google Access をOnにする（VPCレベルではenableにできない！）。それによりそのサブネットのVMはexternal IP を持たずとも、GCSとかにアクセスできる！ただし、Cloud NATを設定しないとインターネットにはアクセスできない。apt updateとかもできない。。

        ※ **VPC Service Control との違い**

        - 利用するIPアドレスが違う。[private.googleapis.com](http://private.googleapis.com/) を使うのがPrivate Google Access、 [restricted.googleapis.com](http://restricted.googleapis.com/) を使うのがVPC Service Control
        - アクセスできる API の種類も違う。restricted.googleapis.comではサポートされるAPIが限定される。

        ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled19.png)

        [限定公開の Google アクセスの仕組みと手順をきっちり解説 - G-gen Tech Blog](https://blog.g-gen.co.jp/entry/private-google-access-explained#privategoogleapiscom--restrictedgoogleapiscom-%E3%81%AE%E9%81%95%E3%81%84)

    - Google API 以外の公開アドレスへのアクセスにはNATゲートウェイが必要
        - プライベートのサブネットにデプロイしたVMインスタンスから外のネットワークに接続して、必要なものをダウンロードする、などの場合、NATゲートウェイを作るが、その際にはCloud Routerをサブネットごとに設置する必要がある。

            > Instead, you will setup the Cloud NAT service to allow these VM instances to make outbound requests in order to install Apache Web server and PHP when they are launched. You create a **Cloud Router** for each managed instance group, one in **us-central1** and one in the **europe-west1** region, which you configure in the next task.
            > 

    ⇔ 逆に、外部IPを持たない非公開VPCのVMへSSHなどをする場合、IP 範囲 35.235.240.0/20 からの上り（内向き）トラフィックを許可し、IAP TCP転送を使う。

    ⇒ 外から非公開VPC内部のINTERNAL IPへTCPアクセスするのがIAP TCP転送

    ※ ＶＭから非公開VPC内部のINTERNAL IPへアクセスするのはPrivate Service Access

    [Private Service Accessとは？例を挙げて説明せよ。Private Google Accessとの違いは？](https://www.notion.so/Private-Service-Access-Private-Google-Access-17022c2142454da0b8c72e7f26cb3ca6) 

- # Private Service Accessとは？例を挙げて説明せよ。Private Google Accessとの違いは？

    例：CloudSQL

    > You require access to Cloud SQL instances from VPC instances with private IPs. Google and third parties (known as service producers) offer services with internal IP addresses hosted in an underlying VPC network. Cloud SQL is one of those Google services.
    > 

    > Private service access lets you create private connections between your VPC network and the underlying Google service producers' VPC network.
    > 

    > To use private service access, you must activate the service networking API in the project, then create a private connection to a service producer.
    > 

    ### Private Google Accessとの違い

    > Private Google Access is not the same as private service access. Private Google access allows VM instances with internal IPs to reach the EXTERNAL IP addresses of Google APIs and Services.
    > 

    ⇒ Googleサービスの外部APIに（非公開VPC内部のVMから）アクセスするのがPrivate Google Access 

    ⇔ VPCのINTERNAL IPへ（VMから）アクセスするのがPrivate Service Access。

    ⇔ GCPのサーバレス環境からVPCへアクセスするのがサーバレスVPCアクセス。

    [AppEngineやCloudRun/FunctionsなどからVPCへアクセスする方法は？](https://www.notion.so/AppEngine-CloudRun-Functions-VPC-e916ca12f54b4708a59ba0c69448af22) 

- # AppEngineやCloudRun/FunctionsなどからVPCへアクセスする方法は？

    **サーバーレスVPCアクセス**を使う。**VPC接続コネクタ**を通してサーバーレス環境とVPCネットワークのトラフィックを処理する。サーバーレス VPC アクセスを構成すると、サーバーレス環境で、内部 DNS と内部 IP アドレス（RFC 1918 および RFC 6598 で定義）を使用して VPC ネットワークにリクエストを送信でき、レスポンスも内部ネットワークを使用する。

    [Serverless VPC Access | Google Cloud](https://cloud.google.com/vpc/docs/serverless-vpc-access)

    ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled20.png)

    例）App Engineでは、顧客のVPCネットワークに特定の静的IPでアクセスして、そこにファイヤーウォールを設定することが多い。App Engineでは下り（外向き）制御で、サーバーレス VPC アクセスと Cloud NAT を使用して、安定性のある静的 IP アドレスを構成している。

    > C. Correct! App Engine uses a fixed set of NAT and health check IP address ranges that must be permitted into the VPC. Because the charges must be incurred by the credit analysis team, you need to create the connector on the client side.
    > 
- # VPC サービスコントロールが守るものは？どのように設定するか？Bridgeとは？Private Google Accessとの違いは？

    ### APIを守る

    - VPC外にあるサービスを制御する、と勘違いされがちだが、実際には各種APIを制御する。あくまでAPIを制御するので、GCEへのSSHやRDPといった直接アクセスは制御できない。
    - セキュリティー境界を作成し、境界内の各種Google Cloud APIへのアクセスをIPだけでなく、ユーザーや位置、デバイス、時間帯など様々な方法で制御できる。

        ![image.png](/images/20221104_professional-cloud-security-engineer/image13.png)


    ### 設定方法

    - **Access Context Manager**で**アクセスレベル**を定義し、サービス境界から参照することでアクセス制御する。(初期から提供されていた機能。API毎に異なるアクセスレベルを利用したい場合はプロジェクトを分離し、別々のサービス境界で管理する必要があった)
    - API毎により細かく制御する場合は**Ingress Policy**を使用する。
    - 境界内のクライアントやリソースから境界外へのアクセスはできない。その問題を解決するには**Egress Policy**を設定し、接続される側ではIngress Policy を設定する必要あり。

        ![IMG_7545.jpg](/images/20221104_professional-cloud-security-engineer/IMG_7545.jpg)


    Google Cloud エンタープライズIT基盤構築ガイドp247ページ

    ### Bridgeとは

    VPC Service Controls help define scope perimeter and protect a VPC from unauthorized access. Two VPC Service Control perimeters can be interconnected with the help of a bridge. A bridge is bidirectional in communication, but not transitive. This means that if Project A and B have their perimeters bridged, and if Project B and C also have a bridge, Project A will not automatically be bridged to Project C.

    [ブリッジを使用して境界を越えて共有する | VPC Service Controls | Google Cloud](https://cloud.google.com/vpc-service-controls/docs/share-across-perimeters?hl=ja)

    [VPC Service Controlsを分かりやすく解説 - G-gen Tech Blog](https://blog.g-gen.co.jp/entry/vpc-service-controls-explained#VPC-Service-Controls-%E3%81%A8%E3%81%AF)

    ### **VPC Service Control と Private Google Accessの違い**

    - 利用するIPアドレスが違う。[private.googleapis.com](http://private.googleapis.com/) を使うのがPrivate Google Access、 [restricted.googleapis.com](http://restricted.googleapis.com/) を使うのがVPC Service Control
    - アクセスできる API の種類も違う。restricted.googleapis.comではサポートされるAPIが限定される。
    - Private Google Accessは外部IPを持たないインスタンスでもGoogleのサービスAPI（外部IP）にアクセスできるようにする仕組み

    ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled19.png)

    [限定公開の Google アクセスの仕組みと手順をきっちり解説 - G-gen Tech Blog](https://blog.g-gen.co.jp/entry/private-google-access-explained#privategoogleapiscom--restrictedgoogleapiscom-%E3%81%AE%E9%81%95%E3%81%84)

- # SOCKS proxyとは？HTTP proxy、NATとの違いを説明せよ。

    プライベートネットワーク内のコンピュータが外部と通信する技術として NATとプロキシがある。プロキシのうち、主にWebで利用するのがHTTPプロキシ、メールなどTCP/IP全般を対象とするのがSOCKSプロキシ。

    - NATは透過性がある（＝グローバルIPを持っていないことを意識しなくていい。IP パケットのプライベートアドレスを NAT 装置が書き換えるだけなので、LAN内のコンピュータは先方のアドレスとポートだけ分かればいい）
    - ⇔ プロキシは透過性がない（=明示的にSOCKSサーバーを指定し、SOCKSサーバーが先方と通信する）

    [NAT をやめて、透過 SOCKS プロキシを導入した - Cybozu Inside Out | サイボウズエンジニアのブログ](https://blog.cybozu.io/entry/2016/03/14/130000)

- # セキュリティ境界、target filtering、subnet isolationについて説明せよ。セキュリティ境界とサービス境界の違い、セキュリティ境界とAccessContextManagerによる制御の直感的違いを一言で言うと？

    ### Security perimiter

    a security perimiter is what you create when you implement a firewall using egress rules to block outbound traffic. In thise case you can use the firewall rules to block all external communications so information will never leave the VPC.

    ⇒ サービス境界とは違う！サービス境界はAPIを保護する境界 ⇔ 基本的にセキュリティ境界はアウトバウンドの情報漏洩を遮断するものらしい。

    ### target filetering

    fire wallがターゲットのVMを絞り込むこと。tag or service accountを使う。後者は**subnet isolation**という。

    > Summary:
    VPCs allow secure communication between resources. The specific rules for resource communication should be added to the firewall. Firewalls can use target filtering with the help of tags or subnet isolation. **Subnet isolation** with the help of service accounts is the recommended method for this situation.
    > 

    ### セキュリティ境界とAccessContextManagerによる制御の違い

    > Compromised code: Access Context Manager is more focused on checking that certain requirements are met before granting users access to the resources, but will be useless for stopping malicious code inside GCP trying to connect to the outside to leak information.
    > 

    ⇒ セキュリティ境界はアウトバウンドへの情報送信を遮断する。ACMはインバウンドに付加的な認証条件を追加する。

    [Best practices and reference architectures for VPC design | Cloud Architecture Center | Google Cloud](https://cloud.google.com/architecture/best-practices-vpc-design#isolate-vms-service-accounts)

- # IAPとAccessContextManagerを比較せよ。
    - BeyondCorpはいろんな技術の組み合わせであり、Identity-Aware Proxy (IAP)やAccess Context Managerがその中の主要な構成要素
        - BeyondCorp とは

            BeyondCorp は、Google が実装したゼロトラスト モデル。

            信頼されないネットワークから VPN を使わずにすべての従業員が作業できるようにするためのエンタープライズ向けセキュリティモデル。ネットワーク境界で行っていたアクセス制御をユーザー単位で行うことで、従来のように VPN を介さなくても実質的にどこからでも安全に作業できる。

            - BeyondCorpはいろんな技術の組み合わせであり、**Identity-Aware Proxy (IAP)**や**Access Context Manager**がその中の主要な構成要素

            BeyondCorp では、シングル サインオン、アクセス制御ポリシー、プロキシへのアクセス、ユーザーおよびデバイスベースの認証と承認が可能。BeyondCorp の原則

            - 接続しているネットワークによって、サービスへのアクセス可否が左右されることはない
            - サービスへのアクセス権は、ユーザーとデバイスからのコンテキスト情報に基づいて付与される
            - サービスへのアクセスを認証、認可、暗号化する必要がある
    - AccessContextManagerでアクセスレベルを作成でき、IAP で保護されたリソースにIAM conditionでアクセスレベルを指定して適用させる。またリクエストのコンテキスト（デバイスの種類、ユーザー ID など）に基づいてアクセスを許可。
    - IAP(バックエンドリソース保護)とかVPCサービスコントロール(API保護)が認証レイヤを追加する仕組みで、IAM条件(IAM conditions)としてアクセスレベルを指定できる。
    - たとえば、High_Level というアクセスレベルを作成して、高い権限を持つユーザーの少人数のグループからのリクエストを許可したり、リクエストを許可する IP 範囲など、信頼できるより一般的なグループを特定し、Medium_Level というアクセスレベルを作成して、これらのリクエストを許可する。

    > Cloud Identity Aware proxy allows to control access to cloud-based and on-premises applications and VMs running on Google Cloud and also verify user identity and use context to determine if a user should be granted access. This effectively implements a zero-trust access model that also supports multi factor authentication.
    > 

    [アクセスレベルの作成と適用 | BeyondCorp Enterprise | Google Cloud](https://cloud.google.com/beyondcorp-enterprise/docs/access-levels?hl=ja)

    ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled21.png)

- # VMメタデータの使い方？

    Use VM metadata to read the current machine’s IP address and use a startup script to add access to Cloud SQL. Store Cloud SQL’s connection string, username, and password in Secret Manager.

    ⇒ プロジェクトのメタデータは使えない。

    [About VM metadata | Compute Engine Documentation | Google Cloud](https://cloud.google.com/compute/docs/metadata/overview#vm_metadata_uses)

- # Confidential VM/Shielded VMの共通点と違いを述べよ。

    **Confidential VM**：メモリー上のデータも個別の暗号鍵で暗号化する。

    > Summary:
    Confidential VMs use AMD’s Secure Encrypted Virtualization, which keeps data encrypted in RAM. They can be managed using Customer-Supplied or Customer-Managed Encryption Keys. These instances contain dedicated AES engines that encrypt data as it flows out of sockets and decrypt data when it is read.
    > 

    **Shielded VM**：VMインスタンスの検証可能な整合性を提供する。

    > インスタンスがブートレベルまたはカーネルレベルのマルウェアやルートキットによって改ざんされていないことを確認できます。 Shielded VM の整合性検証機能は、次の機能を使用して実現されています。
    > 
    > - セキュアブート
    > - vTPM対応のメジャード ブート
    > - 整合性モニタリング

    ### Confidential VM/Shielded VMの違い

    - Confidential VMはメモリー上のデータも個別の暗号鍵で暗号化すること、Shielded VMはセキュアブートに対応すること。

        ※ **セキュアブート**：ブートプロセス中に起動した各コンポーネントにデジタル署名が付けられ、この署名が UEFI BIOS に内蔵された信頼済み証明書のセットと照合されて検証され、正当なものしか起動しない。従来のBIOSに代わるファームウェア⇔OS間の通信仕様を定めた標準規格**UEFI**（Unified Extensible Firmware Interface）ブートマネージャーが提供する機能。

        （設定例）

        Prepare a shell script. Add the command gcloud compute instances stop with the Node.js instance name

        ⇒ You need to stop the Compute Engine instance before creating the image.

         Set up certificates for secure boot. Add gcloud compute images
        create, and specify the Compute Engine instance’s persistent disk and zone and the certificate files

        ⇒ Secure boot requires setting up certificates to establish trust between platform, firmware, and OS.

         Add gcloud compute images add-iam-policy-binding and specify the ‘development’ group.

        ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled22.png)

        [UEFIとは - IT用語辞典](https://e-words.jp/w/UEFI.html#:~:text=UEFI%E3%80%90UnifiedExtensibleFirmwareInterface,%E3%81%AEBIOS%E3%81%AB%E4%BB%A3%E3%82%8F%E3%82%8B%E3%82%82%E3%81%AE%E3%80%82)

        ![image.png](/images/20221104_professional-cloud-security-engineer/image14.png)


    ### Confidential VM/Shielded VMの共通点

    1. SEV

        Confidential VM or Shielded VMsは、AMD Secure Encrypted Virtualization（**SEV**）を搭載した AMD EPYC プロセッサを使用するホストで実行される。

    2. 整合性モニタリング（と、それに使われるvTPM対応のメジャード ブート測定値）
        - A way to determine whether a VM instance's boot sequence has changed
        - Virtual Trusted Platform Module (**vTPM**)を有効にすることができるConfidential VM or Shielded VMで整合性モニタリングを使える。
            - **TPM**

                > Trusted Platform Module とは セキュアな暗号プロセッサの国際規格です。暗号鍵をデバイス内に持つことでセキュアな暗号プロセッサを実現しています。
                > 

                > TPMは通常ハードウェアとして実装されますが、ソフトウェアの実装もあります。TPMの要は暗号鍵がデバイスの中にあること。
                > 
            - **vTPM**

                > 仮想 Trusted Platform Module (vTPM) は、物理的な Trusted Platform Module 2.0 チップをソフトウェアにしたものです。
                > 

                > vTPM は、ランダムな番号の生成、証明、キーの生成など、ハードウェア ベースのセキュリティ関連の機能を提供します。vTPM を仮想マシンに追加すると、ゲスト OS はプライベート キーを作成して、保管できるようになります。これらのキーは、ゲスト OS 自体には公開されません。そのため、仮想マシン攻撃の対象領域が狭められます。通常、ゲスト OS の侵害が起きると機密情報が侵害されますが、ゲスト OS で vTPM を有効にしておくと、このリスクを大幅に低減できます。これらのキーは、ゲスト OS が暗号化または署名の目的にのみ使用できます。
                > 

                [仮想 Trusted Platform Module の概要](https://docs.vmware.com/jp/VMware-vSphere/7.0/com.vmware.vsphere.security.doc/GUID-6F811A7A-D58B-47B4-84B4-73391D55C268.html)

        - vTPMはブート時～後続のイベントのすべてをハッシュ化して保存する（**メジャーブート**）。最初のブート時のハッシュがベースライン（baseline policy）として使われ、以後の各リブートのハッシュと比較され、変更点を検知する。

            ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled23.png)

        - ブート時のログ（Launch Attestation）はロギングでsevLaunchAttestationReportEventとして整合性検証イベントが整合性レポートに出力される。

        > When restarting, Confidential VMs generate a unique log called **Launch Attestation**. Cloud Logging can be used to filter the logs and collect **sevLaunchAttestationReportEvent**.
        > 

        [Cloud Monitoring を使用したインスタンスの検証 | Confidential VMs | Google Cloud](https://cloud.google.com/compute/confidential-vm/docs/monitoring?hl=ja#about_launch_attestation_report_events)


    ### シールドされたGKEノードとの関係

    > シールドされた GKE ノードは、Compute Engine の [Shielded VM](https://cloud.google.com/security/shielded-cloud/shielded-vm) 上に構築されます。シールドされた GKE ノードがないと、攻撃者は Pod の脆弱性を悪用し、ブートストラップ認証情報を抜き取ってクラスタ内のノードになりすますことで、クラスタのシークレットにアクセスできます。シールドされた GKE ノードを有効にすると、GKE コントロール プレーンは暗号を使用して、次の内容を確認します。
    > 
    > - クラスタ内のすべてのノードが、Google のデータセンター内で実行されている仮想マシンであること。
    > - すべてのノードが、クラスタにプロビジョニングされた[マネージド インスタンス グループ（MIG）](https://cloud.google.com/compute/docs/instance-groups#managed_instance_groups)の一部であること。
    > - kubelet が、それが実行されているノードの証明書をプロビジョニングしていること。
    > 
    > [](https://cloud.google.com/kubernetes-engine/docs/how-to/shielded-gke-nodes)
    > 
- # Binary AuthorizationとContainer Analysis

    コンテナイメージにメモを添付する仕組みを**アテステーション**という。登録されているコンテナイメージが正式に認証されているものかをチェックするためにコンテナーイメージにアテステーションを追加する。信頼できる機関によるイメージへの署名を必須にして、デプロイ時にその署名を検証できる。

    > これらのメモ、つまり**証明書**は、イメージについての説明です。証明書は完全に構成可能ですが、一般的な例は次のとおりです。
    > 
    > - アプリが単体テストに合格した。
    > - アプリが品質保証（QA）チームによって検証された。
    > - アプリがスキャンされ、脆弱性が検出されなかった。
    - Binary Authorization policy

        **Binary Authorizationポリシー**を使用して、クラスター内にアテステーションがないコンテナーのデプロイメントをブロックし、いわゆる「野良イメージ」の本番環境へのデプロイメントを防ぐことができる。

        ⇒ Binary Authorizationpolicyの一つとして、コンテナイメージの脆弱性スキャンに合格したか？のメタデータを参照したりすることもできるのだろう。ポリシーに従ったチェックポイントにすべて合格すると、証明書、つまりアテステーションが与えられる。

        [Cloud Build と GKE を使用した Binary Authorization の実装 | Cloud アーキテクチャ センター | Google Cloud](https://cloud.googles.ltd/architecture/binary-auth-with-cloud-build-and-gke?hl=ja)

        ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled24.png)

    - Container Analysis と脆弱性スキャン

        Container Analysis は、既知のセキュリティの脆弱性または **CVE** についてコンテナ イメージスキャンとメタデータ ストレージを提供する。スキャン サービスは、Artifact Registry と Container Registry 内のイメージに対して脆弱性スキャンを実行してから生成されたメタデータを保存し、API を介して利用できるようにする。メタデータ ストレージには、脆弱性スキャン、他のクラウド サービス、サードパーティ プロバイダなど、さまざまなソースからの情報を保存できる。イメージに重大度スコアが 5 を超える CVE が含まれていない場合、そのイメージは重大な CVE がないことが証明され、自動的にステージングにデプロイされる。スコアが 5 を超えると、中程度から重大な脆弱性があることを示され、証明もデプロイもされない。

        - CVE

            共通脆弱性識別子CVE(Common Vulnerabilities and Exposures)


        ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled25.png)

- # Compute Engine imageとは？

    > Summary:
    Compute Engine images provide reusability and ease of redeployment. Images can be built from a persistent disk or its snapshot or from an existing image. This existing image could be in a project or Cloud Storage. Shielded VMs leverage the image reusability only if firmware is UEFI-compliant, and you can enable secure boot in images.
    Shell scripts and Cloud Build can be used to automate the image creation process if the task is small and does not require a complete CI/CD pipeline. Before creating the image, ensure that the instance is stopped.
    > 
- # 複数のNICを持つVM作成について

    GCPだと、VPCにNICが対応するらしく、複数のNICをVMに持たせるには、あらかじめ対応する別々のVPCを作っておく必要があるっぽい

    > In a multiple interface instance, every interface gets a route for the subnet that it is in. In addition, the instance gets a single default route that is associated with the primary interface eth0. Unless manually configured otherwise, any traffic leaving an instance for any destination other than a directly connected subnet will leave the instance via the default route on eth0.
    > 

    The maximum number of NICs per instance is 8

    [複数のネットワーク インターフェースを持つ VM を作成する | VPC | Google Cloud](https://cloud.google.com/vpc/docs/create-use-multiple-interfaces?hl=ja)

- # 個人管理のGoogleアカウントと、クラウドサービスで使うGoogleアカウントの違いは？Cloud Identityを一言でいうと？

    Goolgeアカウントには個人で管理するものと、WorkspaceやCloud Identityなどのサービスで管理するアカウントの二種類がある。

    WorkspaceやCloud Identityを利用することで、管理者によるGoogleアカウントのライフサイクル管理(作成・停止・削除)が可能となる。また、二要素認証やパスワードポリシーの適用、監査ログの取得、Access Context Managerを利用したアクセス元IPやデバイスの制御も可能。個人管理のGoogleアカウントは個人でしか管理できない。

    ### Cloud Identityを一言でいうと

    WorkspaceのID管理機能のみを提供するIDaaS(ID as a Service)である。

    ![IMG_7542.jpg](/images/20221104_professional-cloud-security-engineer/IMG_7542.jpg)

    - CloudIdentityにワークスペースアカウントはいらない

        []()

        ドメインを一つ決めることが必要。メールアドレスを登録する。

        ![image.png](/images/20221104_professional-cloud-security-engineer/image15.png)


    Google Cloud エンタープライズIT基盤構築ガイドp230ページ

- # サービスアカウントの利用方法4つを説明せよ。サービスアカウントは管理負荷が高いが、三種類の認証情報の種類を挙げ、使い分けを簡潔に説明せよ。

    以下の４つ。リソースに関連付ける場合というのは、サービスアカウントキーを準備したりしなくても、単にリソースに関連付けるだけ。GCPに構築したサービスは作成したサービスアカウントをアタッチするだけ。キー管理は不要。

    ![IMG_7543.jpg](/images/20221104_professional-cloud-security-engineer/IMG_7543.jpg)

    ![IMG_7544.jpg](/images/20221104_professional-cloud-security-engineer/IMG_7544.jpg)

    Google Cloud エンタープライズIT基盤構築ガイドp232ページ

    ### 3種類の認証情報の種類

    1. APIキー

        一番単純で、プリンシパルは識別せず、アプリケーションのみを識別する。

        例えば、そのAPIキーを持っていたら、誰でもGCSの特定のオブジェクトにアクセスできる、など。

    2. OAuth 2.0クライアント認証

        認証時にGoogleアカウントが必要になる、プリンシパルがUser accounts(人間によるアクセス)を想定した認証。

    3. サービスアカウントキー

        認証時にサービスアカウントと紐づけられたサービスアカウント キーが必要になる、プリンシパルがService accounts(人間以外からのアクセス)を想定した認証。認証情報に個人のGoogleアカウントを必要としないので、**本番環境**のシステムやCI/CDのような共有しているものに対して使える。


    ### 使い分け戦略

    - APIキーはさておき、OAuth 2.0クライアント認証とサービスアカウントキー、開発時はどちらでも良い。サービスアカウントキーを使うなら、本番環境。その際はリソースに関連付けられるサービスアカウントやWorkloadIdentityが使えないことを確認の上、キーの管理をしっかりするなど万全を期す。
    - application default loginでOAuth認証できるので、サービスアカウントを作るまでもない場合は楽
    - サービスアカウント はIAMロールで権限をコントロールできる。それ以外は開発者個人のGoogleアカウントを使ってOAuth 2.0クライアント認証を使ってもよい。OAuth scopesは、IAM roleより以前のレガシーな方法
    - Unlike users, service accounts can't authenticate by signing in with a password or with single sign-on (SSO)

        ⇒ OAuthは一応、ユーザー認証しているので、サービスアカウントよりは安全という前提らしい？

        - サービスアカウント vs OAuth

            > ユーザーデータにアクセスする際には、サービス アカウントではなく（プリンシパルの移行を実行している可能性あるため）、[OAuth 同意フロー](https://cloud.google.com/docs/authentication/end-user)を使用してエンドユーザーの同意をリクエストします。その後、アプリケーションがエンドユーザー ID で処理を行うことができるようにします。サービス アカウントの代わりに OAuth を使用すると、次のことができるようになります。
            > 

            > ユーザーは、アプリケーションにアクセス権を付与しようとしているリソースを確認し、自身の同意または拒否を明示的に表明できます。
            > 

            > ユーザーは随時、[[アカウント情報](https://myaccount.google.com/permissions)] ページで同意を取り消すことができます。
            > 

            > すべてのユーザーのデータに対して無制限のアクセス権を付与されたサービス アカウントは必要ありません。
            > 

            > アプリケーションにエンドユーザー認証情報の使用を許可することで、Google Cloud APIs に対する権限チェックを延期します。これにより、コーディング エラーが原因でユーザーがアクセスすることを許可しないようにする必要があるデータが、誤って公開されてしまうリスク（[混乱した使節に関する問題](https://www.wikipedia.org/wiki/Confused_deputy_problem)）を低減できます。
            > 
    - 開発中にサービス アカウントを使用しない

        日常業務で Google Cloud CLI、`gsutil`、`terraform` などのツールを使用する場合があります。これらのツールの実行でサービス アカウントを使用しないでください。代わりに、`gcloud auth login`（gcloud CLI と `gsutil`の場合）または `gcloud auth application-default login`（`terraform` などのサードパーティ ツールの場合）を実行して、ツールがユーザーの認証情報を使用することを許可します。

        Google Cloud にデプロイする予定のアプリケーションの開発とデバッグにも、同様の方法を使用できます。デプロイ後、アプリケーションでサービス アカウントが必要になる場合がありますが、ローカル ワークステーションで実行する場合は、個人用の認証情報を使用できます。

        アプリケーションで個人の認証情報とサービス アカウント認証情報の両方をサポートするには、[Cloud クライアント ライブラリ](https://cloud.google.com/apis/docs/cloud-client-libraries)を使用して[認証情報を自動的に検索](https://cloud.google.com/docs/authentication/production#automatically)します。


    [APIキー、OAuthクライアントID、サービスアカウントキーの違い:Google APIs - 無粋な日々に](https://messefor.hatenablog.com/entry/2020/10/08/080414#3%E3%81%A4%E3%81%AE%E8%AA%8D%E8%A8%BC%E6%83%85%E5%A0%B1%E3%81%AF%E6%83%B3%E5%AE%9A%E3%81%95%E3%82%8C%E3%82%8B%E5%88%A9%E7%94%A8%E3%82%B7%E3%83%BC%E3%83%B3%E3%81%8C%E7%95%B0%E3%81%AA%E3%82%8B)

    [Best practices for working with service accounts | IAM Documentation | Google Cloud](https://cloud.google.com/iam/docs/best-practices-service-accounts#choosing_when_to_use_service_accounts)

    [Best practices for managing service account keys | IAM Documentation | Google Cloud](https://cloud.google.com/iam/docs/best-practices-for-managing-service-account-keys)

    - （追記）サービスアカウントでもOAuthでのトークンベースの認証が使われている。

        サービスアカウントキーを使った認証でも、OAuthやJwt、OIDCトークンなどの有効期限の短い認証情報を使用した認証が使える。それによりキーの漏洩リスクが減らせる。

        ※ 認証サーバーからトークンを取得するために、サービスアカウントキーのcredentialが必要になることは、ユーザーアカウントの場合（OAuthクライアントID）と同じ。

        ※ ローカル開発時にOAuth認証（OAuthクライアントID）する場合、ユーザーアカウントを想定しているが、OAuth＝ユーザーアカウント認証の代わりだけではない。**サービスアカウントの認証の手段としてもOAuthを含むトークンでの認証が使われている！**

        [有効期間が短いサービス アカウント認証情報を作成する  |  IAM のドキュメント  |  Google Cloud  サービスアカウントにOAuthをつけられる！独立排他ではないのだ！ベストプラクティス的にはサービスアカウントキーのような長期間有効なものよりもOAuthのトークンの方がいい。](https://www.notion.so/IAM-Google-Cloud-OAuth--55ed156959b143b18e4dd89d6960aac5)

- # WorkloadIdentityとは？Workload Identity 連携とは？

    AWSのIAMなどIdP上のユーザーがサービスアカウントになりすますことで、Google Cloud サービスを操作する。OAuth2.0の仕様に従ってtokenが自動発行される。OIDC＋OAuthでのSSOみたいなもの？

    Workload IdentityはGKE上のpodがサービスアカウントになりすます場合、Workload Identity連携はAWS/Azure/外部IdPからサービスアカウントになりすます場合。

    Google Cloud エンタープライズIT基盤構築ガイドp232ページ

- # ローカル開発環境内でサービス アカウント用の鍵を提供する必要がある場合、Google が推奨する方法に沿って対応する方法は？

    毎日の鍵のローテーション プロセスを導入し、デベロッパーには、毎日新しい鍵をダウンロードできる Cloud Storage バケットを提供する。*この方法なら、管理者が鍵のローテーション プロセスを一元管理することが可能で、鍵の生成をデベロッパーに委任する必要がなく、漏洩が生じる恐れが少ない。*

- # サービスアカウントのキーローテーションが必要なケースは？どうやって自動化するか？

    アプリケーションが GCP 上だけで実行されるのであれば、サービス アカウント キーのローテーションなどは GCP が自動的に行ってくれる。

    ⇔ GCP以外の環境でサービスアカウントを使用する場合、キーの管理が必要にある。

    > Google recommends to use the IAM service account API to automatically rotate your service account keys. You can rotate a key by creating a new key, switching applications to use the new key and then deleting the old key. To do so you need to use the `[serviceAccount.keys.create()](https://cloud.google.com/iam/reference/rest/v1/projects.serviceAccounts.keys/create)`
    and `[serviceAccount.keys.delete()](https://cloud.google.com/iam/reference/rest/v1/projects.serviceAccounts.keys/delete)`
    methods together to automate the rotation.
    > 

    ⇒自動化用のコマンドはないが、自分で自動化するように推奨されているw

- # DLP APIの仮名化3種を比較・説明せよ。また、infoType、Date shifting とは？

    ### 仮名化変換方式

    - Cloud DLP は、匿名化の 3 つの仮名化手法をサポート。
    - 仮名化=トークン化、サロゲート置換。暗号鍵を使う。Crypto。
    - 元の機密値→対応するトークン
    - 可逆なトークン化は、FPE（Format-Preserving-Encryption）と確定的（Deterministic）暗号化。普通のCryptoHashConfigは不可逆 。

    ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled26.png)

    [変換のリファレンス | データ損失防止（DLP）のドキュメント | Google Cloud](https://cloud.google.com/dlp/docs/transformations-reference?hl=ja)

    暗号化キーを残しておけば復元でき、残さなければ復元できない。

    ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled27.png)

    ### infoType

    > Cloud Data Loss Preventionでは、*情報タイプ*（*infoType*）を使用してスキャンする対象を定義します。infoType は、名前、メールアドレス、電話番号、識別番号、クレジット カード番号などの機密データのタイプを表します。
    > 

    > Cloud DLP で定義されている infoType には、それぞれ対応する検出器があります。Cloud DLP では、スキャンの構成に含まれる infoType 検出器を使用して、検査の対象と検査結果の変換方法が決定されます。
    > 
    - Cloud DLP uses built-in and custom infoType detectors to scan images, documents, and text. Custom infoTypes can be dictionaries, regular expressions, or dictionaries extracted from BigQuery or Cloud Storage. Use dictionaries when you want to match a list of words or phrases, and use regular expressions when you want to detect matches based on a regex patte



    [InfoType detector reference | Data Loss Prevention Documentation | Google Cloud](https://cloud.google.com/dlp/docs/infotypes-reference)

    ### Date shifting

    順序と持続時間は保持してシフトさせること。

    [日付シフト | データ損失防止（DLP）のドキュメント | Google Cloud](https://cloud.google.com/dlp/docs/concepts-date-shifting?hl=ja)

- # Cloud Audit Logsの種類と、デフォルトでの有効/無効は？また、ログ表示に必要な権限は？

    ### Cloud Audit Logs（監査ログ）の種類

    下記4種類がある。

    - 管理アクティビティ監査ログ
        - 管理アクティビティ監査ログは常に書き込まれる。構成する、除外する、または無効にすることはできない。Cloud Logging API を無効にしても、管理アクティビティ監査ログは生成される。
        - たとえば、**ユーザーが** VM インスタンスを作成したときや Identity and Access Management 権限を変更したとき
    - システム イベント監査ログ
        - 直接的なユーザーのアクションによってではなく、**Google システムによって**有効化される
        - システム イベント監査ログは常に書き込まれる。構成したり、除外したり、無効にしたりすることはできない。
    - データアクセス監査ログ
        - BigQuery データアクセス監査ログを除き、データアクセス監査ログはデフォルトで無効になっている（データサイズが非常に大きくなる可能性があるため）。BigQuery 以外の Google Cloud サービスのデータアクセス監査ログを書き込むには、明示的に有効にする必要がある。
    - ポリシー拒否監査ログ

    [Cloud Audit Logs の概要 | Cloud Logging | Google Cloud](https://cloud.google.com/logging/docs/audit?hl=ja#data-access)

    ### ログ表示に必要な権限と設定例

    | ロール | リソース | プリンシパル | 説明 |
    | --- | --- | --- | --- |
    | logging.viewer | 組織 | セキュリティ チーム | logging.viewer ロールにより、セキュリティ管理チームは、管理アクティビティ ログを表示できます。 |
    | logging.privateLogViewer | 組織 | セキュリティ チーム | logging.privateLogViewer ロールにより、データアクセス ログを表示できます。 |
    | logging.viewer | フォルダ | デベロッパー チーム | logging.viewer ロールにより、デベロッパー チームは、すべてのデベロッパー プロジェクトが存在するフォルダに格納されているデベロッパー プロジェクトによって生成された管理アクティビティ ログを表示できます。 |
    | logging.privateLogViewer | フォルダ | デベロッパー チーム | logging.privateLogViewer ロールにより、データアクセス ログを表示できます。 |

    [監査関連ジョブ機能の IAM ロール | IAM のドキュメント | Google Cloud](https://cloud.google.com/iam/docs/job-functions/auditing?hl=ja)

    ### 例：Secret Managerのログを確認する方法は？

    Admin activity logs and Data Access Logs are the ones containing secret management related information.

    ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled28.png)

    ※ [Access Transparency logとは？](https://www.notion.so/Access-Transparency-log-b0b6c6ead9c44091b736a9c54c26901e) 

- # Access Transparency logとは？

    アクセスの透明性ログから得られる情報は、Cloud 監査ログから得られる情報とは異なります。Cloud 監査ログには、Google Cloud 組織のメンバーが Google Cloud リソースで行った操作が記録されます。一方、アクセスの透明性ログには、Google の担当者が行った操作が記録されます。


- # 集約されたシンクを使用する方法は？

    > 集約されたシンクを使用するには、Google Cloudの組織またはフォルダーにシンクを作成し、シンクの**includeChildrenパラメータ**をTrueに設定します。そのシンクは、組織またはフォルダーからのログエントリに加えて、含まれているフォルダー、請求先アカウント、またはクラウドプロジェクトからのログエントリを（再帰的に）ルーティングできます。
    > 

    ⇒ ログをほぼリアルタイムで外部SIEMにエクスポート

    - SIEM

        Security Information and Event Management

        数秒で大量のデータを取り込んで解析し、異常な行動を検出するとただちにアラートを送信する機能により、ユーザーはビジネスを保護するためのインサイトをリアルタイムで得ることができる。

- # VPCパケットミラーリングとは？VPCフローログとの違いは？
    - VPCパケットミラーリング
        - 特定インスタンスに出入りするパケット をミラーできる機能。サブネット全体やネットワークタグを指定して、複数のインスタンスをまとめて対象として指定することもできる。
        - Packet Mirroring は指定インスタンスからパケットを複製して **コレクタ宛先**
         (collector destination) に送信
        - パケットミラーリングポリシーでフィルタ作成（プロトコル、CIDR範囲、方向）
    - VPCフローログとの違い

        > VPC フローログにはいわゆる 5 タプル (送信元 IP 、送信元ポート番号、送信先 IP 、送信先ポート番号、プロトコル番号) が含まれる他、時刻、バイト数、 TCP の ACK のレイテンシなどが含まれます。こういった パケットの関連情報が記録されるのであり、 パケットそのものがキャプチャされるのではありません
        > 

        ⇒ ペイロードとヘッダーを含むすべてのトラフィックとパケットデータを検査したい場合、パケットミラーリングを使う


- # Cloud Logging では、Google Cloud 以外のシステムからもログや指標のデータを収集できる。

    Google が提供する Cloud Monitoring エージェントは、AWS EC2 インスタンスにインストール可能。また、オンプレミスのマシンに fluentd や collectd エージェントをインストールして、Cloud Monitoring サービスにデータを書き込める。

    Logging AgentやMonitoring AgentをGCEのlinux/windowsインスタンスにインストールすると、それはfluentdベースのツールで、勝手にLoggingやmonitoringのサービスにログやメトリクスを送信して収集してくれる！GCPじゃなくてもAWSとかオンプレでもいい！

    - Cloud Logging の出し方

        アプリからAPIを叩いてログに入れる。_Defaultバケットにルーティングされるようなシンクになっていて、30日間保存される。pubsubやBigQuery、GCSへのカスタムシンクを作れば制限はなくなる。

        [https://qiita.com/HishiM/items/63b93742c098e1591f77](https://qiita.com/HishiM/items/63b93742c098e1591f77)


    > Cloud Logging の _Required バケットは、管理アクティビティ監査ログとシステム イベント監査ログを取り込んで保存します。_Required バケットやバケット内のログデータは構成できません。 _Default バケットは、デフォルトで有効なデータアクセス監査ログとポリシー拒否監査ログを取り込んで保存します。データアクセス監査ログが _Default バケットに保存されないようにするには、ログを無効にします。ポリシー拒否監査ログが _Default バケットに保存されないようにするには、シンクのフィルタを変更してポリシー拒否監査ログを除外します。
    > 

    [Cloud Audit Logs の概要 | Cloud Logging | Google Cloud](https://cloud.google.com/logging/docs/audit?hl=ja)


- # GCSのストレージクラスのオプションと、最小保存期間を挙げよ。

    ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled29.png)

    [Storage classes | Google Cloud](https://cloud.google.com/storage/docs/storage-classes)

    > Summary:
    Cloud Storage lets you use storage classes that are less expensive than standard storage. These storage classes use low-performance HDDs compared to standard SDDs. The cost-performance trade-off lets you build low-cost, resilient applications that still have the fastest read access and lowest latency in the cloud space. Cloud Storage object lifecycle rules let you change storage classes or set expiration rules to further reduce storage costs.
    > 
- # SCCとForseti Securityについて概観して比較せよ。これらは一言でいうとどんな用途に使えるサービスか？

    ### 一言でいうと

    SCCやForsetiは**CSPM用途**に使えるソリューションといえる

    - CSPM

        > クラウドの設定ミスによる情報漏洩に対して有効なソリューションとして注目されているのがCSPM（Cloud Security Posture Management : クラウドセキュリティ態勢管理）です。
        > 

        > CSPMは、IaaSやPaaSといったパブリッククラウドに対してAPI連携により、クラウド側の設定を自動的に確認し、セキュリティの設定ミスや各種ガイドライン等への違反が無いかを継続してチェックすることができます。また、IaaS/PaaSを利用する際のベストプラクティスをチェックルールとしてあらかじめ用意しており、ユーザへより安全な利用方法を提示してくれます。
        > 

        [CSPMとは？クラウドの設定ミス防止ソリューション｜選定で失敗しない３つのポイント](https://www.nri-secure.co.jp/blog/preventing-cloud-configuration-mistakes-with-cspm)


    ### Cloud Security Command Center

    > Security Command Center（以下SCC）は、Google Cloudの組織配下のプロジェクトにおいて、セキュリティリスクのある設定や、脆弱性（アプリも含む）を見つけてくれるサービスです。 見つけた結果を表示するダッシュボード機能もあります。 なお、SCCは[組織](https://cloud.google.com/resource-manager/docs/creating-managing-organization/?hl=JA)に対して設定するサービスのため、プロジェクト単体では使用できません。
    > 

    > 無料のスタンダード ティアと有料のプレミアム ティアがあり、スタンダードでは一部機能のみ使用できます。
    > 

    | 機能（サービス）名 | 機能概要 | スタンダード | プレミア |
    | --- | --- | --- | --- |
    | Security Health Analytics | 公開FWなど、Google Cloud の脆弱性と構成ミスをに検出 | 一部利用可（公開FWなど一部の設定検知のみ） | 利用可（CISなど各種基準に対する準拠チェックも含む） |
    | Web Security Scanner | アプリケーションの脆弱性スキャン | 一部利用可（公開 URL と IPをスキャン） | 利用可（アプリ脆弱性を含めスキャン） |
    | Event Threat Detection | アカウントへの不正アクセスなど各種イベントを検知 | 利用不可 | 利用可 |
    | Container Threat Detection | コンテナへの攻撃を検知 | 利用不可 | 利用可 |
    - Web Security Scanner

        > [Web Security Scanner](https://cloud.google.com/security-command-center/docs/concepts-web-security-scanner-overview) で App Engine アプリケーションをスキャンして脆弱性を検出します。Web Security Scanner は、App Engine、Google Kubernetes Engine（GKE）、Compute Engine の各ウェブ アプリケーションにおけるセキュリティの脆弱性を特定します。
        > 

        > このサービスは、アプリケーションをクロールして、開始 URL の範囲内にあるすべてのリンクをたどり、できる限り多くのユーザー入力とイベント ハンドラを実行しようとします。クロス サイト スクリプティング（XSS）、Flash インジェクション、混合コンテンツ（HTTPS 内の HTTP）、更新されていない / 安全ではないライブラリなど、4 つのよくある脆弱性に対して自動的にスキャンし、脅威を検出します。
        > 


    > これらの基本4サービスのほか、以下の3つも統合されたサービスとして、検知内容をSCC上で確認できるようになっています。スタンダードでも利用可能です。
    > 

    | 統合されたサービス名 | 機能概要 |
    | --- | --- |
    | Anomaly Detection | 仮想マシン（VM）のセキュリティ異常（漏洩された認証情報やコイン マイニングなど）を検知 |
    | Cloud Armor | DDoSやXSSなどの攻撃を保護 |
    | Data Loss Prevention | 機密性の高いデータを検出、分類、保護 |

    [Security Command Centerを使用してGoogle Cloud内のセキュリティイベントを検知する - NRIネットコムBlog](https://tech.nri-net.com/entry/gcp-scc-notification)

    [Security sources | Security Command Center | Google Cloud](https://cloud.google.com/security-command-center/docs/concepts-security-sources#threats)

    ### Forseti Security

    > Forseti は、適切なセキュリティ管理が GCP 全体に行き渡っているという自信と安心感をセキュリティ チームに与えることを目標として作られたオープンソースのツールキットです。Forseti には次のような有用なセキュリティ ツールが含まれています。
    > 
    - Inventory : 既存の GCP リソースを可視化します。
    - Scanner : GCP リソース全体のアクセス制御ポリシーが適切かどうかをチェックします。
    - Enforcer : GCP リソースに対する問題のあるアクセスを取り除きます。
    - Explain : GCP リソースに対して誰がどのようなアクセス権限を持つかを分析します。

    [Spotify と Google が共同開発 : オープンソースの GCP セキュリティ ツール Forseti Security | Google Cloud Blog](https://cloud.google.com/blog/ja/products/gcp/with-forseti-spotify-and-google-release-gcp-security-tools-to-open-source-community15)

    ### SCCとForsetiの違い

    ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled30.png)

    > can have a historical record of what was running in Google Cloud Platform at any point in time.
    > 
    > 
    > Security Command Center will only scan resources once a day while forseti can scan them as frequently as you establish. 
    > 
    > Also Cloud Security Command Center only includes projects in an active state, while Forseti Inventory includes projects all possible states.
    > 

    ⇒ ForsetiはSecurity Command Centerにconnectもでき、あらゆる時点の全履歴レコードを保持している！

    ⇔ Security Command Centerは一日一回スキャンするのみ。

- # Network Intelligence Center vs Security Command Center

    ### Security Command Center（SCC）

    Security Health Analytics、Web Security Scanner、サードパーティー製品連携（Forseti, Splunk..etc）、アクセス管理、Event Threat Detection、Container Threat Detection、 継続的エクスポート

    ### Network Intelligence Center

    ネットワークトポロジー、接続テスト、パフォーマンスダッシュボード、ファイアウォールインサイト

    - ファイヤーウォールインサイト

        Network Intelligence Centerのモジュールの一つ。**指標レポートとインサイト レポート**を提供する。この 2 つのレポートには、VPC ネットワークでのファイアウォールの使用状況と、さまざまなファイアウォール ルールが与える影響についての情報が含まれる。

        構成誤り発見、緩すぎるルールの修正、特定のルールヒット数、ほかのルールで隠されているシャドウルールの検出、など。

        [ファイアウォール インサイトを使用したファイアウォール ルールの管理 | Google Cloud Blog](https://cloud.google.com/blog/ja/products/identity-security/eliminate-firewall-misconfigurations-with-firewall-insights)

- # Secret Manager vs Hashicorp Vault
    - Secret Manager

        Secret Manager helps save confidential details such as passwords and URLs. You can provide access to secrets using Cloud IAM. Secret Manager lets organizations share configured secrets instead of confidential information with developers. 

    - Hashicorp Vault

        **Hashicorp Vault** is the best option for secure storage with automatic, scheduled secrets rotation. Cloud Key Management Service does **not** support automatic rotation of **asymmetric keys.**

        ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled31.png)

- # CSEKはGCSとGCEのみで使えるサービス！BigQueryとかでは使えない。

    CSEKではGCS or GCEのデータを使うときに顧客自身がAPI callと一緒に鍵を渡す。つまり結局GCPに鍵は渡る。が、Googleはそれをメモリ上でのみ使い、storageには書き込まない。

    > CSEK are not supported in BigQuery at the time of writing and are only available for Cloud Storage and Compute Engine services
    > 

    ⇒ BigQueryの場合、CMEKを検討する。

    ### キーのバージョン

    Each key created in Cloud KMS holds a key version, and each key version holds a state.

    1. *Pending generation* (`PENDING_GENERATION`)

        (Applies to asymmetric keys only.) This key version is still being generated. It may not be used, enabled, disabled, or destroyed yet. Cloud Key Management Service will automatically change the state to enabled as soon as the version is ready.

    2. *Enabled* (`ENABLED`)

        The key version is ready for use.

    3. *Disabled* (`DISABLED`)

        This key version may not be used, but the key material is still available, and the version can be placed back into the enabled state.

    4. ***Scheduled for destruction*** (`DESTROY_SCHEDULED`)

        This key version is scheduled for destruction, and will be destroyed soon. **It can be placed back into the disabled state.**

    5. *Destroyed* (`DESTROYED`)

        This key version is destroyed, **and the key material is no longer stored in Cloud KMS**. If the key version was used for asymmetric or symmetric encryption, any ciphertext encrypted with this version is not recoverable. If the key version was used for digital signing, new signatures cannot be created. Additionally, for all asymmetric key versions, the public key is no longer available for download. A key version may not leave the destroyed state once entered.


    ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled32.png)

- # Gsuiteは ○○ application?

    GSuite is provided by google as a **SaaS** application. The following picture shows the shared responsibility model for SaaS apps provided by GCP:

    ![https://img-c.udemycdn.com/redactor/raw/test_question_description/2021-01-23_09-36-48-8c55739b0561ddecab7400d2321ef926.png](https://img-c.udemycdn.com/redactor/raw/test_question_description/2021-01-23_09-36-48-8c55739b0561ddecab7400d2321ef926.png)

    Network security is provided out of the box by google in both PaaS and SaaS models, so It's not necessary for the customers to configure anything related to network security for GSuite.

    > GSuite is provided by google as a SaaS application.
    > 

    ⇒ Gsuites のようなsaasでは、ネットワークセキュリティはGoogleの責任範囲

- # 仮想アプライアンスとは？

    アプライアンス：ネットワーク上で特定の機能を提供する専用の機器

    **仮想アプライアンス**：仮想化技術を用いて、アプライアンス機能が稼働する環境を即座に構成できるようにしたもの。[仮想マシン](https://e-words.jp/w/VM.html)（VM）の[イメージファイル](https://e-words.jp/w/%E3%83%87%E3%82%A3%E3%82%B9%E3%82%AF%E3%82%A4%E3%83%A1%E3%83%BC%E3%82%B8.html)などとして提供される。

    例）CiscoルータのVMWareのイメージ、NGFWのイメージ

- # NGFWとは？

    **次世代ファイアウォール 【next generation firewall】 NGFW**

    従来のファイアウォールは、通信相手のIPアドレス、送信元や宛先の[ポート番号](https://e-words.jp/w/%E3%83%9D%E3%83%BC%E3%83%88%E7%95%AA%E5%8F%B7.html)、[TCP](https://e-words.jp/w/TCP.html)の通信状態に矛盾がないか（[ステートフルパケットインスペクション](https://e-words.jp/w/%E3%82%B9%E3%83%86%E3%83%BC%E3%83%88%E3%83%95%E3%83%AB%E3%83%91%E3%82%B1%E3%83%83%E3%83%88%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%9A%E3%82%AF%E3%82%B7%E3%83%A7%E3%83%B3.html)）などを元に通信の許可や拒否を判断するのが一般的だった。

    次世代ファイアウォールはこれに加え、[アプリケーション層](https://e-words.jp/w/%E3%82%A2%E3%83%97%E3%83%AA%E3%82%B1%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3%E5%B1%A4.html)（HTTPなど）の通信内容を解析（[ディープパケットインスペクション](https://e-words.jp/w/%E3%83%87%E3%82%A3%E3%83%BC%E3%83%97%E3%83%91%E3%82%B1%E3%83%83%E3%83%88%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%9A%E3%82%AF%E3%82%B7%E3%83%A7%E3%83%B3.html)）し、どのアプリケーションが通信を試みているのかを識別したり、外部からの不審なアクセスを探知（[IDS](https://e-words.jp/w/IDS.html)/[IPS](https://e-words.jp/w/IPS.html)：侵入検知/防止システム）し、可否の判断に加えることができる。

    [次世代ファイアウォールとは - IT用語辞典](https://e-words.jp/w/%E6%AC%A1%E4%B8%96%E4%BB%A3%E3%83%95%E3%82%A1%E3%82%A4%E3%82%A2%E3%82%A6%E3%82%A9%E3%83%BC%E3%83%AB.html)

- # Cloud Healthcare API

    **HIPAA**（Health Insurance Portability and Accountability Act）は「医療保険の携行性と責任に関する法律」と訳され、「保護対象保険情報（**PHI：Protected health information**）」を扱う企業に物理的、デジタル上で、および手続き上でのセキュリティー対策を講じ、それに従うことを規定しています。

    > The Cloud Healthcare API has a de-identification module to redact patient information and is already HIPAA-compliant. You can then use Dataflow to read the information from source and write into a target bucket with anonymization for further analysis.
    > 

    > Summary:
    The Cloud Healthcare API and the Google Cloud Healthcare Data Protection Toolkit can be used to maintain HIPAA compliance for data storage, application development, data analysis, and machine learning. The Google Cloud Healthcare Data Protection Toolkit helps you set up HIPAA-compliant architecture using an infrastructure-as-a-code script (IaaS). The Cloud Healthcare API is a fully managed HIPAA-compliant service that contains a de-identification module, along with security built around location and privacy.
    > 
- # ISO27017とは？

    ### ISO27001

    「情報セキュリティ全般に関するマネジメントシステム規格」

    ISO 27001 outlines and provides the requirements for an information security management system (ISMS), specifies a set of best practices, and details the security controls that can help manage information risks but it's not specific to cloud

    ### ISO27017

    「クラウドサービスに関する情報セキュリティ管理策のガイドライン規格」

    ### ISO27018

    「パブリッククラウドにおける個人情報保護体制」

    ISO 27018 relates to one of the most critical components of cloud privacy: the protection of personally identifiable information (PII)

- # SLA、SLO、RPO、RTOについてそれぞれ簡潔に説明せよ。

    ### SLA

    SLAとは「Service Level Agreement」の略で、**「サービス品質保証」を意味する。**

    サービスを提供する事業者がサービスの契約者に対し、サービス内容を保証するための契約。サービスの契約書では、付属資料として扱われることが多い。

    SLA is the entire agreement that specifies what service is to be provided, how it is supported, times, locations, costs, performance, penalties, and responsibilities of the parties involved. 

    ### SLO

    SLOs are specific, measurable characteristics of the SLA, such as availability, throughput, frequency, response time, or quality. 

    **An SLA can contain many SLOs**.

    ### RTO

    RTO(Recovery Time Objective：目標復旧時間)

    ### RPO

    RPO(Recovery Point Objective：目標復旧ポイント)

    失われるデータの最大許容量の測定値

    ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled33.png)

    ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled34.png)

- # PCI DSS scopeをreduceするプラクティスは？

    Payment Card Industry Data Security Standard（**PCI DSS**）

    > *PCI DSS は、PCI Security Standards Council で採択された一連のネットワーク セキュリティおよびビジネス上のベスト プラクティス ガイドラインによって構成され、お客様の決済カード情報を保護するための「最小限のセキュリティ基準」が定められています*
    > 

    [PCI Data Security Standard compliance | Cloud Architecture Center | Google Cloud](https://cloud.google.com/architecture/pci-dss-compliance-in-gcp#setting_up_your_payment-processing_environment)

    the recommendation is to segregate cardholder data environment into a separate project. That way you can implement all required measures to be compliant with PCI-DSS just where those are required and you will avoid mixing highly secure environments with less secure ones. This will effectively reduce the attack surface for payment systems.  Google also recommends that in its official documentation:

    This section describes how to set up your payment-processing environment. Setup includes the following:

    - **Creating a new Google Cloud account to isolate your payment-processing environment from your production environment.**
    - Restricting access to your environment.
    - Setting up your virtual resources.
    - Designing the base Linux image that you will use to set up your app servers.
    - Implementing a secure package management solution.
- # Forensic investigations tools？

    > Summary:
    When you create a GKE cluster, Cloud Logging is enabled by default. Both Google Cloud and the Kubernetes ecosystem provide a range of tools for forensic investigations and audit. Cloud Logging, Docker-explorer, and Kubectl Sysdig Capture plus Sysdig Inspect provide forensic mechanisms. Use Docker-explorer for offline containers, and use Kubectl Sysdig Capture to trigger system events. Cloud Logging stores Firewall rules but not data access rules by default.
    > 

    ### フォレンジック（forensic）

    直訳すると「法廷の」という意味。言い換えると「鑑識」。鑑識とは、交通事故や刑事事件が起きた際に、筆跡・指紋・血痕などの遺留物を鑑定した捜査に役立てるための作業で、この言葉をデジタル分野に置き換えたのが、（デジタル）フォレンジック。不正アクセスやその他のサイバー攻撃によって被害を受けた企業や個人が、法的証拠を押さえるために実施するデジタル的な鑑識のこと。

    ### Docker-explorer

    This project helps a forensics analyst explore offline Docker filesystems.

    ### Sysdig

    ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled35.png)

    ![Untitled](/images/20221104_professional-cloud-security-engineer/Untitled36.png)

- # ファイル整合性監視(FIM)とは？

    file integrity monitoring : FIM

    [Sysdig](https://www.scsk.jp/sp/sysdig/blog/sysdig_secure/post_3.html)

    > ファイルの整合性監視により、機密性の高いファイルに関連するすべてのアクティビティを可視化できます。これは、アクティビティが悪意のある攻撃なのか、計画外の運用アクティビティなのかに関係なく、重要なシステムファイル、ディレクトリ、**不正な変更の改ざんを検出するために使用されます。**
    > 


# 用語

- # Bastion

    踏み台

- # Attestation

    証言、立証、証明

    attestation は、attest という動詞から派生させた名詞。

    attest という動詞が「真実であると断言すること」という意味を持つことからもうかがえるように、法廷で宣誓の下に証言するような場合に用いられる語。

    だから、attestation は「証言」という意味で用いられる方が普通かもしれません。

- # インベントリ

    インベントリ（Inventory）とは、元々「目録」「保有資産」といった意味のinventoryが語源となっており、 LAN上のクライアントPCや接続機器が持つデータを一覧にしたものを指す。「IT資産管理」などの管理システムでは、ソフトウェアやPC、サーバ、ストレージなどのハードウェアやルータやスイッチなどのネットワーク機器、その他ネットワークに接続されている周辺機器のインベントリ情報を自動収集し、資産情報として管理をすることができる。取得するインベントリ情報は、機器の機種、MACアドレス、IPアドレス、CPUの型番やメモリ、ハードディスク容量、利用履歴など、多くの情報を収集、管理する。


- # オリジンサーバー

    オリジナルのコンテンツが存在する Web サーバーのこと。

    自社ページなどを公開する際に、ページを配置したサーバに直接アクセスさせるのではなく WAF や CDN などのサービスを経由させてアクセスさせるネットワーク構成としたときに、WAF や CDN から見た接続先となるサーバをオリジンサーバと呼ぶ。

    CDN を利用した場合、エンドユーザーはオリジンサーバーにアクセスするのではなく、CDNのサーバ（**エッジサーバー**）にアクセスする。

    [オリジンサーバーとはなんですか？](https://support.cdnext.stream.co.jp/hc/ja/articles/360001787832-%E3%82%AA%E3%83%AA%E3%82%B8%E3%83%B3%E3%82%B5%E3%83%BC%E3%83%90%E3%83%BC%E3%81%A8%E3%81%AF%E3%81%AA%E3%82%93%E3%81%A7%E3%81%99%E3%81%8B-)

- # PCI DSS

    Payment Card Industry Data Security Standard（**PCI DSS**）

    > *PCI DSS は、PCI Security Standards Council で採択された一連のネットワーク セキュリティおよびビジネス上のベスト プラクティス ガイドラインによって構成され、お客様の決済カード情報を保護するための「最小限のセキュリティ基準」が定められています*
    > 

    [PCI Data Security Standard compliance | Cloud Architecture Center | Google Cloud](https://cloud.google.com/architecture/pci-dss-compliance-in-gcp#setting_up_your_payment-processing_environment)

- # PII

    personally identifiable information (PII)

- # ephemeral

    一時的な

- # 3-tier

    3層

    web-tier ウェブ層

    Tier は区分という意味もある。

    premium/standard tierとか。

- # ASN

    BGPゲートウェイのAS番号

    対向で設置するみたい

- # SIEM

    Security Information and Event Management

    数秒で大量のデータを取り込んで解析し、異常な行動を検出するとただちにアラートを送信する機能により、ユーザーはビジネスを保護するためのインサイトをリアルタイムで得ることができる。
