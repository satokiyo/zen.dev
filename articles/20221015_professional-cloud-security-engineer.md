---
title: "test"
emoji: "📚"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: []
published: false
---
# Security

- LDAPとは
    
    LDAP（Lightweight Directory Access Protocol）は、Active Directoryのようなディレクトリサービスに　アクセスするためのプロトコル。クライアントはTCPポート番号389を使用してLDAPサーバに接続を行い属性（個人名や部署名）で構成するエントリ（関連属性のまとまり）の検索、追加、削除の操作をします
    

---

- デジタル署名、証明書チェーン、X.509について完結に説明せよ
    
    [図解 X.509 証明書 - Qiita](https://www.notion.so/X-509-Qiita-e38de4aebd354feaa29b47e0cc15041f)
    
    デジタル署名
    
    「**秘密鍵**を用いて生成された**署名**を**公開鍵**で**検証**することにより」、「データが改竄されていないこと」や「秘密鍵の保持者が確かに署名したこと」を確認する
    
    流れ
    
    1. 秘密鍵と公開鍵のペアを作る。
    2. 相手に送りたいデータを秘密鍵を用いて署名に変換し、データ＋署名を相手に送る。→これってデータのハッシュを秘密鍵で暗号化すれば、それはメッセージダイジェスト！つまりデジタル署名って改ざん検知とかに使うメッセージダイジェストのことか！？受取り側では公開鍵で復号したデータのハッシュ値と、自分で計算したハッシュを比較して改竄されていないか確認できる。
    3. 何らかの方法で相手に公開鍵を渡す。
    4. 相手は公開鍵を用いて署名を検証する。
        
        ![Untitled](/images/image1.png)
        
    
    証明書チェーン
    
    その公開鍵が本物かどうか第三者が証明書を作成する
    
    1. 証明書のデータは、証明対象となる公開鍵＋その公開鍵に対応する秘密鍵を持っている人の情報＋証明書の発行者（自分）の情報
    2. この証明書の内容を保証するため、デジタル署名をする。
    3. そのために、デジタル署名用の秘密鍵と公開鍵のペアを作成
    4. それから、秘密鍵を用いてデジタル署名をおこないます。これで証明書の完成です。
    5. 公開鍵を直接渡す代わりに、その公開鍵を含み、その出所を証明する証明書を渡します。
        
        ![Untitled](Security%20518b9659cac843419433812359bcd221/Untitled%201.png)
        
    6. これにより、元々欲しかった公開鍵（図中の「A の公開鍵」）は証明付きで入手でる。しかし、証明書のデジタル署名を検証するための公開鍵（図中の「B の公開鍵」）が必要になってしまう。。。。これでは際限がなく思えるが、公開鍵の証明書を公開鍵の主体者本人が作成することで終結する。デジタル署名を付ける際に使う秘密鍵は、証明対象の公開鍵とペアの秘密鍵を使う。このように、証明対象となる公開鍵とペアになっている秘密鍵を用いて署名することを、**自己署名**と言い、自己署名によって作成された証明書を**自己署名証明書**と言う
    7. 自己署名証明書は起点となる証明書なので、信頼済みの証明書としてあらかじめ持っておく必要があります。
        
        ![Untitled](Security%20518b9659cac843419433812359bcd221/Untitled%202.png)
        
    8. これらの証明書は鎖のように繋がっています。このように連なった証明書群全体を**証明書チェーン**（certificate chain）と呼びます。
    9. そして、起点となる自己署名証明書を**ルート証明書**（root certificate）、中間にある証明書を**中間証明書**（intermediate certificate）と呼びます。中間証明書の数は 2 以上になりえます。
    
    X.509証明書
    
    証明書の構造は [RFC 5280](https://tools.ietf.org/html/rfc5280)
     という技術文書で定義されています。X.509 証明書という名前は、同技術文書のタイトル「Internet X.509 Public Key Infrastructure Certificate and Certificate Revocation List (CRL) Profile」から来ています。
    
    ![Untitled](Security%20518b9659cac843419433812359bcd221/Untitled%203.png)
    

---

- 公開鍵暗号と共通鍵暗号の暗号化アルゴリズムの代表例を挙げよ
    
    ![screenshot-www.infraexpert.com-2022.08.05-12_38_22.png](Security%20518b9659cac843419433812359bcd221/screenshot-www.infraexpert.com-2022.08.05-12_38_22.png)
    

---

- SAMLとはどこで使われるか？OAuth、OIDCとの違いを簡潔に説明せよ。
    
    [https://i.moneyforward.com/resources/saml_sso](https://i.moneyforward.com/resources/saml_sso)
    
    シングル・サインオン(SSO)を実現する方法として、SAMLとOAuthとがある。互いに代替するというより補完し合うイメージ。例えばMicrosoft環境ではSAMLがアクセス権を付与し、OAuthがスコープを設定してリソースを保護する。
    
    OAuthとSAMLはどちらも、相互運用を奨励し標準化するためのプロトコル。ユーザー名/パスワードが増加し続けて重要リソースへのアクセスが妨げられる事態を回避
    
    - SAML(Security Assertion Markup Language)は「認証」に対応するプロトコル。ユーザー固有になる傾向がある。毎朝、仕事を始める際にコンピューターにログインするときには、SAMLが使用されるケースが多い。SAML認証が完了すると、ユーザーは、企業のイントラネット、Microsoft Office、ブラウザなどのツールスイート全体にアクセスできるようになる。SAMLを使用することにより、ユーザーは1つのデジタル署名でこれらのリソースをすべて利用できる。
    
    ※SAMLはSSOだけでなくMFAとかリスクベース認証など、様々な認証サービスを提供する
    
    ![Untitled](Security%20518b9659cac843419433812359bcd221/Untitled%204.png)
    
    - OAuth(Open Authorization)は「認可(承認)」に対応するプロトコル。アプリケーション固有になる傾向がある
    
    ### SAMLによるSSOの仕組み
    
    様々なベンダが、XML形式のマークアップ言語によるSAMLプロトコルに対応したIDasS(Identity As A Service)サービスを提供している。
    
    認証情報を提供する側を「IdP（Identity Provider）」
    
    ⇒ GCPのCloud Identity、okta、Microsoft® Azure Active Directory (Azure AD)、VMware Workspace One...etc
    
    認証情報を利用する側を「SP（Service Provider）」
    
    ⇒ ユーザーが利用するクラウド含むアプリ、サービス
    
    ![Untitled](Security%20518b9659cac843419433812359bcd221/Untitled%205.png)
    
    ### OAuthの仕組み
    
    SAMLのIdPがAuthorizationServerになったようなイメージ？
    
    ## OpenID Connect
    
    SAMLと同じくSSOの認証プロトコル。IdPはSAMLだけでなく、OIDCプロトコルにも対応している場合がある。しかし、OpenID ConnectはOAuthを拡張した規格であり、OAuthと一緒に利用されて、FaceboookやTwitterなどのSNS認証部分を担うような使われ方が多い。
    
    ⇔SAMLは非常に複雑な権限管理を行うことができ、Active Directoryの機能の一つであるADFS（Active Directory Fereration Service）やOktaなどIDPサービスで主に用いられる
    
    ![Untitled](Security%20518b9659cac843419433812359bcd221/Untitled%206.png)
    

---

- ADFSとは？
    
    Active Directory Federation Services
    
    Federation：連携、連合
    
    ADFSはSSO環境を提供するもの。ActiveDirectoryの機能の一つ。ADFSは利用者の認証を行い、それを各システムに伝達する　IdP：Identity Provider　として振る舞う。
    
    ADFSと各サービスは利用者の識別情報と認証状態などを通知するtokenと呼ばれるデータを交換し、パスワードなどの秘密の情報の登録や照合などはIdP（ADFS）側が集中的に管理する。
    
    トークンの形式や伝達方式などはWS-Federationや**[SAML](https://e-words.jp/w/SAML.html)**、**[OpenID Connect](https://e-words.jp/w/OpenID.html#Section_OpenID%20Connect)**などの標準的な規格を利用する。
    
    In order to be able to keep using the existing identity management system, identities need to be synchronized between AD and GCP IAM. To do so google provides a tool called **Cloud Directory Sync**. This tool will read all identities in AD and replicate those within GCP.
    
    Once the identities have been replicated then it's possible to apply IAM permissions on the groups. After that you will configure SAML so google can act as a service provider and either your **ADFS** or other third party tools like Ping or Okta will act as the identity provider. This way you effectively delegate the authentication from Google to something that is under your control.
    
    ※Cloud Directory Syncは一方向のみなので、AD/LDAP側を変更し、変更を適宜Cloud Identityへ同期する。直接Cloud Identityを編集すると、食い違いが発生する。
    

---

- API Throttling and Rate Limiting: What’s the Difference?
    
    throttlingはサーバー(API)への負荷を制限する目的、API rate limitingは個人による集中アクセスを制限する目的。
    
    ![Untitled](Security%20518b9659cac843419433812359bcd221/Untitled%207.png)
    

---

- VPCとは？
    
    A VPC network is a **global resource** that consists of a **list of regional virtual subnetworks (subnets) in data centers**, all connected by a global wide area network (WAN). VPC networks are logically isolated from each other in Google Cloud.
    
    →リージョナルのデータセンターがVPCのサブネットに対応し、その集合体のグローバルネットワークが一つの論理的なVPCを構成している。
    
    - VPCのsubnetはautoモードでregionごとに作られる
    - VM作成時のNetworkInterfaceはVPC(の中のサブネット)を選択できる。マシンにネットワークをくっつける感じ？

---

- VPC Network Peeringとは? 同じpeeringでも違うサービスを指しているものは何？また、SharedVPCとの違いは？
    
    ## VPC Peering
    
    []()
    
    - vpc network peeringはVPCを共有する仕組み。GCPに接続する方法の一つであるdirect/carrier peeringとは別！後者のピアリングは、BGPの経路をGCPのルータと交換し、直接ルートを設定する。なのでexternalIPのみで、プライベートアドレス空間へのアクセスはできない。
        - Direct Peering can only access external IP addresses.
    - VPC PeeringはVPCを共有するためのもので、プライベートアドレスアクセスだが、オンプレからのアクセスはできない！プロジェクト間での閉じたネットワークを構築する。
    
    ![image.png](Security%20518b9659cac843419433812359bcd221/image.png)
    
    - VPC network peering can be configured for different VPC networks **within and across organizations**.
    - VPC peeringは複数プロジェクトを繋げられ、内部トラフィックなので、VPNなどのように外部トラフィックを使うより高速！
        
        []()
        
        ![image.png](Security%20518b9659cac843419433812359bcd221/image%201.png)
        
        しかもegressに課金されるので、内部トラフィックはコストが安い！
        
    - DNSでは名前解決できない
        
        Compute Engine internal DNS names created in a network are not accessible to peered networks. The IP address of the VM should be used to reach the VM instances in peered network.
        
        → Internal DNSは各VPC毎に付属するメタサーバの一種なはずなので、別のVPCからはアクセスできないのでは？
        
        - you cannot use a tag or service account from one peered network in the other peered network
    - peeringはk8sEngineでも使われる！というのは、クラスターを作ると、そのマスターノードがVPCネットワークとpeeringする！
    
    ## shared vpc
    
    []()
    
    web serviceとかでhost pjとservice pjで分け中央で管理するようなとき
    
    ![image.png](Security%20518b9659cac843419433812359bcd221/image%202.png)
    
    - 各service pjとはプライベート通信できる
    - host 側でsubnetを分ける
    - 中央で管理⇔peeringはそれぞれで管理
    
    ## shared vpc vs vpc peering
    
    []()
    
    vpc peering wont allow connecting on-premise resources.
    
    ![image.png](Security%20518b9659cac843419433812359bcd221/image%203.png)
    
    ※ VPC Peeringにはいわゆる**2-hop制限**があり推移的ピアリングは出来ない。つまり1:1の双方向のみ。3つ以上のVPCを共有する場合、フルメッシュでピアリングコネクションを作成する必要がある。⇔*共有 VPC なら、複数のプロジェクトで VPC を共有し、管理機能をホスト プロジェクトに維持したまま、他のプロジェクトは、共有 VPC 内の IP での VM 作成のみに制限できる。*
    

---

- GCPのプロジェクトの定義を簡潔にいえ
    
    プロジェクトは課金される対象で、内部に複数〜5個のネットワークを持つもの
    
    []()
    
    ![image.png](Security%20518b9659cac843419433812359bcd221/image%204.png)
    

---

- リソース階層とポリシーの関係性を言え
    - ポリシー＝ロール＋ユーザー
    
    []()
    
    ![image.png](Security%20518b9659cac843419433812359bcd221/image%205.png)
    
    - リソース階層にポリシー(=ユーザーやSAとロール)をくっ付けて設定し、継承させる
    1. GCPのリソース階層にはワークスペースメンバーとかGmailメンバーも追加できる！
        
        []()
        
        ![image.png](Security%20518b9659cac843419433812359bcd221/image%206.png)
        

---

- タグとラベル、ファイヤーウォールルールについて説明せよ。
    
    ### (ネットワーク)タグ
    
    - VPC内の特定のVMインスタンス群にファイヤーウォールルールを簡単に適用できるもの。
        
        Network tags are used by networks to identify which VM instances are subject to certain firewall rules and network routes.
        
    - ファイヤウォールルールはタグとサービスアカウントにもつけられる！
        - サービスアカウント間でファイヤーウォールルールを設定すれば、タグ間とは違って、スコープを設定できるので、スコープで認可された通信のみを許可できる。
        - サービスアカウントへのアクセスが必要になるので、IAMロールと組み合わせて特定の承認ユーザーだけのアクセスを許可するようにできる。
    
    []()
    
    ![image.png](Security%20518b9659cac843419433812359bcd221/image%207.png)
    
    ### ラベル
    
    - ラベルは、GCPのBilling情報にマーキングして、BQやDataStudioで見るときに便利
    - リソース階層を設定するときにも「ラベル」を使うと便利
        
        ![image.png](Security%20518b9659cac843419433812359bcd221/image%208.png)
        
    
    ### ファイヤウォールルール
    
    []()
    
    - デフォルトのファイヤーウォールルールでは、インバウンドは全てブロック、アウトバウンドは全て許可
    
    ![image.png](Security%20518b9659cac843419433812359bcd221/image%209.png)
    
    - VPCネットワークのファイヤウォールはデフォルトではHTTPは入らない？なのでcurlコマンドは通らないぽい
    - Network Admin/Security Role、ファイヤーウォールルールを設定できるのは、、
        - **Network Admin:** Permissions to create, modify, and delete networking resources, except for firewall rules and SSL certificates.
        - **Security Admin:** Permissions to create, modify, and delete ****firewall rules and SSL certificates.
    
    - egress firewall ruleを設定できるインスタンスは？
        
        There are **only two google services that allow to filter egress traffic and those are Google Compute Engine and Kubernetes Engine**.  Regarding App Engine and Cloud functions, ingress rules are available but egress ones are not, so it's not a valid option. Cloud storage doesn't not allow to apply firewall rules.
        
    - hostnameでファイヤーウォールルールを設定できるか？
        
        →出来ない。When specifying a source for an ingress rule or a destination for an egress rule by address, you can only use an IPv4 address or IPv4 block in CIDR notation. Therefore is not possible to allow the traffic to a hostname.
        

---

- Google Cloud のロードバランサの種類と使い分けについて説明せよ。プロキシ型とパススルー型は何が違うか？IAPとの関係について完結に述べよ。
    
    参考：[https://www.topgate.co.jp/google-cloud-load-balancer#i-5](https://www.topgate.co.jp/google-cloud-load-balancer#i-5)
    
    全ての要素を一枚で図示しると以下のようになる。
    
    ![Untitled](Security%20518b9659cac843419433812359bcd221/Untitled%208.png)
    
    ツリー形式で図示すると下記
    
    ![Untitled](Security%20518b9659cac843419433812359bcd221/Untitled%209.png)
    
    - internalロードバランサーはリージョナルのみ
    - 内部プロキシ型のLBは、OSSのenvoy proxy がベースになっている
    - Googleのアンドロメダのブログポスト読め、らしい
    - 外部 HTTP（S）負荷分散と内部 HTTP（S）負荷分散では、バックエンドに手を入れず、ロードバランサーでインテリジェントなルーティングを実現できる。これにより、簡単な A/B テストやカナリアリリース、再試行、外れ値検出、サーキットブレーカーetc.を行うことが可能。
    
    ### プロキシ型とパススルー型について。
    
    []()
    
    ![image.png](Security%20518b9659cac843419433812359bcd221/image%2010.png)
    
    左がプロキシ型、右がパススルー型
    
    - ロードバランサーには、プロキシ型とパススルー型という分類がある。プロキシ型はクライアントから届いたリクエストをロードバランサーで受け取り、そのロードバランサーが別のセッションとしてバックエンドに通信を行う。そのため、ロードバランサーにリクエストが届く前後で送信元と送信先が変わる。
        - →プロトコルの変換が可能！
        
        ![Untitled](Security%20518b9659cac843419433812359bcd221/Untitled%2010.png)
        
    - 一方、パススルー型はクライアントから届いたリクエストをそのままバックエンドに届ける。そのため、ロードバランサーにリクエストが届く前後で送信元と送信先が変わることはない。
    
    ### IAP(Identity-Aware Proxy)との関係について
    
    アプリケーションに認証を追加する場合、本来はアプリケーション自体に手を加える必要がある。 Identity-Aware Proxy （IAP）を使うことで認証部分をロードバランサーで完結でき、認証が終わったリクエストのみをバックエンドに送ることが可能。
    
    認証には、 Google アカウントや OAuth 、 SAML 、 OIDC などの一般的な認証プロトコルを網羅していて、既存の認証 DB をそのまま利用して認証できる点も大きなメリット。
    
    → IAPも、Cloud Armorみたいに、LBにつく！
    
    ![Untitled](Security%20518b9659cac843419433812359bcd221/Untitled%2011.png)
    

---

- GCPにおけるDNSとメタデータサーバについて説明せよ。
    - ~~各VM~~は各VPCはそれぞれメタデータサーバーを持っており、それがDNSresolverとしても働く。ローカルリソースの名前解決の問い合わせに応える。ローカルリソース以外はGoogleのパブリックDNSにルーティングする。
        - ExternalIPアドレスはGoogleのCloudDNSやGoogle以外のDNSサービスに登録する必要がある。内部DNSだけでなく。
        - internalIPはVMがマストで持つ。External IPはオプションで、一時的。
            
            internalIPはVMのOSが自分で知っているが、externalは知らない！外側からマッピングするのだ！
            
    - DNSサービスを持つのは、各VMではなくて、VPCネットワークらしい
        
        VPC networks have an internal DNS service that allows you to address instances by their DNS names instead of their internal IP addresses. When an internal DNS query is made with the instance hostname, it resolves to the primary interface (nic0) of the instance.
        
        →VPCに属するすべてのVMインスタンスを管理する**メタサーバ**サービスがあって、それがDNSサービスもしている感じ？そのVPCに属しているVMの名前解決クエリが来たら応答する？で、複数NICをもつVMがある場合、NIC０のドメインへ名前解決されるぽい。
        
    - VPCの**プライベートGoogle Access**を有効にしておけば、BQとかGCSに内部からアクセスできる！
        
        ⇔ 普通はNATゲートウェイとか設定しないとダメ。
        
        - Cloud functionとかはきっと外部IPを持ってるのだろう。だからGoogle APIでBQとかGCSにアクセスできる。
    - メタデータサーバーのIPは、169.254.169.254で固定。なので、InternalDNSでもmetadata.google.internalで名前解決できる。
        
        ※このアドレスレンジは、TCP IAP転送で、外部IPを持たない非公開VPCに踏み台無しでアクセスするような時に、ファイヤーウォールで許可しておくレンジ。要するにメタデータサーバー(それか近くのレンジのサーバー)経由でIAP接続されるはず。
        
    - デフォルトのVPCを削除すると、新たに自分でVPCを作らない限り、新たなVMは作れない！つまり本来VPCの中にリソースを作るのであって、デフォルトでは見えなくなっているのだ。その見えないものの中にメタデータサーバなどもある。

---

- IAP TCP 転送とは？メリットは？
    
    外部 IP アドレスを持たない、またはインターネット経由の直接アクセスを許可しない VM インスタンスへIAPを介してssh接続とかをする方法！
    
    - ファイヤーウォールルールを対象の非公開VPCに設定し、IP 範囲 `35.235.240.0/20` からの上り（内向き）トラフィックを許可する
    - この範囲には、IAP が TCP 転送に使用するすべての IP アドレスが含まれています。
    - IAP TCP 転送を使用してアクセス可能にするすべてのポートへの接続を許可します。たとえば、SSH のポート `22` と RDP のポート `3389` です。
    
    **メリット**は、IAPを使えば踏み台サーバが不要になること！
    
    - ⇔ 逆に外部IPを持たないVMがEgressアクセスするには、1.NATゲートウェイを使う、2.Private Google Accessを使う(Google API のみ)という方法がある
    
    [Using IAP for TCP forwarding | Identity-Aware Proxy | Google Cloud](https://cloud.google.com/iap/docs/using-tcp-forwarding)
    

---

- Router vs Gateway?
    
    ゲートウェイは、異なるネットワーク同士を中継する仕組みの総称。その1つとして、IPアドレスを判別してネットワークを中継するルーターがある。
    
    VPNゲートウェイを使うときに、Cloud　Routerも一緒に使っている。要するにL3レベルのルーティングにRouterが必要で、それ以上の層のVPN通信の出入り口にはVPNゲートウェイが必要。
    
    ![Untitled](Security%20518b9659cac843419433812359bcd221/Untitled%2012.png)
    

---

- 外部IPを持たないVMがEgressアクセスする方法を二つ挙げ、それぞれ説明せよ。
    
    ### NAT Gateway vs Private Google Access
    
    - Google API へのアクセスの場合、Private Google Access を使う。
        
        → VM instances that have no external IP addresses can use **Private Google Access** to reach external IP addresses of Google APIs and services. By default, Private Google Access is disabled on a VPC network
        
        → VPCのサブネットの設定でPrivate Google Access をOnにする。それによりそのサブネットのVMはexternal IP を持たずとも、GCSとかにアクセスできる！ただし、Cloud NATを設定しないとインターネットにはアクセスできない。apt updateとかもできない。。
        
        ※**VPC Service Control との違い**
        
        - 利用するIPアドレスが違う。[private.googleapis.com](http://private.googleapis.com/) を使うのがPrivate Google Access、 [restricted.googleapis.com](http://restricted.googleapis.com/) を使うのがVPC Service Control
        - アクセスできる API の種類も違う。restricted.googleapis.comではサポートされるAPIが限定される。
        
        ![Untitled](Security%20518b9659cac843419433812359bcd221/Untitled%2013.png)
        
        [限定公開の Google アクセスの仕組みと手順をきっちり解説 - G-gen Tech Blog](https://blog.g-gen.co.jp/entry/private-google-access-explained#privategoogleapiscom--restrictedgoogleapiscom-%E3%81%AE%E9%81%95%E3%81%84)
        
    - Google API 以外の公開アドレスへのアクセスにはNATゲートウェイが必要
        - → 逆に非公開VMからGoolgeAPIとかでない、外部ネットワークに接続するためにはNATゲートウェイが必要なのだろう。
        - プライベートのサブネットにデプロイしたVMインスタンスから外のネットワークに接続して、必要なものをダウンロードする、などの場合、NATゲートウェイを作るが、その際にはCloud Routerをサブネットごとに設置する必要がある。
            
            **Task 2: Create two NAT configurations using Cloud Router**
            
            The Google Cloud VM backend instances that you setup in Task 3 will not be configured with external IP addresses.
            
            Instead, you will setup the Cloud NAT service to allow these VM instances to make outbound requests in order to install Apache Web server and PHP when they are launched. You create a **Cloud Router** for each managed instance group, one in **us-central1** and one in the **europe-west1** region, which you configure in the next task.
            
    
    ※ 逆に、外部IPを持たない非公開VPCのVMへSSHなどをする場合、IP 範囲 `35.235.240.0/20` からの上り（内向き）トラフィックを許可し、IAP TCP転送を使う
    

---

- VPNの実装方式の種類を整理せよ。SSLとIPSecの違い、VPNとIAPの違いを述べよ。Cloud VPNの特徴は？
    
    ### VPNの分類
    
    VPNを、
    
    1. 使用する回線によって分類
        - インターネットVPN
        - IP-VPN(通信事業者のアクセス回線を使用)
    2. プロトコルで分類
        - SSL-VPN
        - IPSec-VPN
        - PPTP-VPN
        - L2TP-VPN
        - など。
    
    ![IMG_7541.jpg](Security%20518b9659cac843419433812359bcd221/IMG_7541.jpg)
    
    ### IPSec VPN vs SSL VPN
    
    - ネットワーク丸ごとか、ポート毎か
    - 実現するセキュリティレベルは同じくらい
    - IPSecは専用の機器がいる？ので、コスト高い。が、高速。IPSecはトランスポート層のTCPやUDPのヘッダが見えないのでファイヤーウォールルールを設定できない
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
        
        ![image.png](Security%20518b9659cac843419433812359bcd221/image%2011.png)
        
    - 新しく追加されたネットワークは自動的に通知(アドバタイズ)され、静的IPの管理は不要
        
        []()
        
        ![image.png](Security%20518b9659cac843419433812359bcd221/image%2012.png)
        
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
    
    **アドバタイズする**
    
    ネットワーク制御分野の用語。Cloud Router の場合、隣接するネットワークのルータに対象（サブネットや外部 IP アドレス）への経路情報を伝達することを指す。
    
     **例文**
    
    まず `us-west1` リージョンにある Cloud Router が外部のオンプレミス・ネットワークと VPN トンネルを通じてハイブリッド接続している構成であるとします。Cloud Router はデフォルトですべてのサブネットを**アドバタイズしている**ので、`us-west1` のサブネット内の VM はオンプレミス・ネットワークを認識できます。また、サブネット内に Proxy サーバを立て、その外部 IP アドレスを**アドバタイズする**ことによって、オンプレミス・ネットワークは Proxy サーバを認識できます。
    
    [GCP IAP tunnel を HTTP プロキシを通して利用する場合の注意点](https://www.qoosky.io/techs/fd7e826326)
    
    [PPTP - ネットワーク入門サイト](https://beginners-network.com/vpn_pptp.html)
    
    [IPsec vs. SSL VPN: Comparing speed, security risks and technology](https://www.techtarget.com/searchsecurity/tip/IPSec-VPN-vs-SSL-VPN-Comparing-respective-VPN-security-risks)
    

---

- ローカル開発環境内でサービス アカウント用の鍵を提供する必要がある場合、Google が推奨する方法に沿って対応する方法は？
    
    毎日の鍵のローテーション プロセスを導入し、デベロッパーには、毎日新しい鍵をダウンロードできる Cloud Storage バケットを提供する。*この方法なら、管理者が鍵のローテーション プロセスを一元管理することが可能で、鍵の生成をデベロッパーに委任する必要がなく、漏洩が生じる恐れが少ない。*
    

---

- 個人管理のGoogleアカウントと、クラウドサービスで使うGoogleアカウントの違いは？Cloud Identityを一言でいうと？
    
    Goolgeアカウントには個人で管理するものと、WorkspaceやCloud Identityなどのサービスで管理するアカウントの二種類がある。
    
    WorkspaceやCloud Identityを利用することで、管理者によるGoogleアカウントのライフサイクル管理(作成・停止・削除)が可能となる。また、二要素認証やパスワードポリシーの適用、監査ログの取得、Access Context Managerを利用したアクセス元IPやデバイスの制御も可能。個人管理のGoogleアカウントは個人でしか管理できない。
    
    ### Cloud Identityを一言でいうと
    
    WorkspaceのID管理機能のみを提供するIDaaS(ID as a Service)である。
    
    ![IMG_7542.jpg](Security%20518b9659cac843419433812359bcd221/IMG_7542.jpg)
    
    - CloudIdentityにワークスペースアカウントはいらない
        
        []()
        
        ドメインを一つ決めることが必要。メールアドレスを登録する。
        
        ![image.png](Security%20518b9659cac843419433812359bcd221/image%2013.png)
        
    
    Google Cloud エンタープライズIT基盤構築ガイドp230ページ
    

---

- WorkloadIdentityとは？Workload Identity 連携とは？
    
    AWSのIAMなどIdP上のユーザーがサービスアカウントになりすますことで、Google Cloud サービスを操作する。OAuth2.0の仕様に従ってtokenが自動発行される。OIDC＋OAuthでのSSOみたいなもの？
    
    Workload IdentityはGKE上のpodがサービスアカウントになりすます場合、Workload Identity連携はAWS/Azure/外部IdPからサービスアカウントになりすます場合。
    
    Google Cloud エンタープライズIT基盤構築ガイドp232ページ
    

---

- サービスアカウントの利用方法4つを説明せよ。サービスアカウントは管理負荷が高いが、三種類の認証情報の種類を挙げ、使い分けを簡潔に説明せよ。
    
    以下の４つ。リソースに関連付ける場合というのは、サービスアカウントキーとか準備したりしなくても、単にリソースに関連付けるだけでいい？GCFとかデフォルトのサービスアカウントと関連付けられて動いているようなイメージ？
    
    ![IMG_7543.jpg](Security%20518b9659cac843419433812359bcd221/IMG_7543.jpg)
    
    ![IMG_7544.jpg](Security%20518b9659cac843419433812359bcd221/IMG_7544.jpg)
    
    Google Cloud エンタープライズIT基盤構築ガイドp232ページ
    
    ### 3種類の認証情報の種類
    
    1. APIキー
        
        一番単純で、プリンシパルは識別せず、アプリケーションのみを識別する。
        
        例えば、そのAPIキーを持っていたら、誰でもGCSの特定のオブジェクトにアクセスできる、など。
        
    2. OAuth 2.0クライアント認証
        
        認証時にGoogleアカウントが必要になる、プリンシパルがUser accounts(人間によるアクセス)を想定した認証。
        
    3. サービスアカウントキー
        
        認証時にサービスアカウントと紐づけられたサービスアカウント キーが必要になる、プリンシパルがService accounts(人間以外からのアクセス)を想定した認証。認証情報に個人のGoogleアカウントを必要としないので、**本番環境**のシステムやCICDのような共有しているものに対して使えます。
        
    
    使い分け戦略
    
    - APIキーはさておき、OAuth 2.0クライアント認証とサービスアカウントキー、開発時はどちらでも良い。サービスアカウントキーを使うなら、本番環境。その際はリソースに関連付けられるサービスアカウントやWorkloadIdentityが使えないことを確認の上、キーの管理をしっかりするなど万全を期す。
    - application default loginでOAuth認証できるので、サービスアカウントを作るまでもない場合は楽
    - サービスアカウント はIAMロールで権限をコントロールできる。それ以外は開発者個人のGoogleアカウントを使ってOAuth 2.0クライアント認証を使ってもよい。OAuth scopesは、IAM roleより以前のレガシーな方法
    - Unlike users, service accounts can't authenticate by signing in with a password or with single sign-on (SSO) → OAuthは一応、ユーザー認証しているという体なので、サービスアカウントよりは安全という前提らしい？
        - サービスアカウント vs OAuth
            
            ユーザーデータにアクセスする際には、サービス アカウントではなく（プリンシパルの移行を実行している可能性あるため）、[OAuth 同意フロー](https://cloud.google.com/docs/authentication/end-user)を使用してエンドユーザーの同意をリクエストします。その後、アプリケーションがエンドユーザー ID で処理を行うことができるようにします。サービス アカウントの代わりに OAuth を使用すると、次のことができるようになります。
            
            - ユーザーは、アプリケーションにアクセス権を付与しようとしているリソースを確認し、自身の同意または拒否を明示的に表明できます。
            - ユーザーは随時、[[アカウント情報](https://myaccount.google.com/permissions)] ページで同意を取り消すことができます。
            - すべてのユーザーのデータに対して無制限のアクセス権を付与されたサービス アカウントは必要ありません。
            
            アプリケーションにエンドユーザー認証情報の使用を許可することで、Google Cloud APIs に対する権限チェックを延期します。これにより、コーディング エラーが原因でユーザーがアクセスすることを許可しないようにする必要があるデータが、誤って公開されてしまうリスク（[混乱した使節に関する問題](https://www.wikipedia.org/wiki/Confused_deputy_problem)）を低減できます。
            
            ### 開発中にサービス アカウントを使用しない
            
            日常業務で Google Cloud CLI、`gsutil`、`terraform` などのツールを使用する場合があります。これらのツールの実行でサービス アカウントを使用しないでください。代わりに、`gcloud auth login`（gcloud CLI と `gsutil`の場合）または `gcloud auth application-default login`（`terraform` などのサードパーティ ツールの場合）を実行して、ツールがユーザーの認証情報を使用することを許可します。
            
            Google Cloud にデプロイする予定のアプリケーションの開発とデバッグにも、同様の方法を使用できます。デプロイ後、アプリケーションでサービス アカウントが必要になる場合がありますが、ローカル ワークステーションで実行する場合は、個人用の認証情報を使用できます。
            
            アプリケーションで個人の認証情報とサービス アカウント認証情報の両方をサポートするには、[Cloud クライアント ライブラリ](https://cloud.google.com/apis/docs/cloud-client-libraries)を使用して[認証情報を自動的に検索](https://cloud.google.com/docs/authentication/production#automatically)します。
            
            [Best practices for working with service accounts | IAM Documentation | Google Cloud](https://cloud.google.com/iam/docs/best-practices-service-accounts#choosing_when_to_use_service_accounts)
            
    
    [APIキー、OAuthクライアントID、サービスアカウントキーの違い:Google APIs - 無粋な日々に](https://messefor.hatenablog.com/entry/2020/10/08/080414#3%E3%81%A4%E3%81%AE%E8%AA%8D%E8%A8%BC%E6%83%85%E5%A0%B1%E3%81%AF%E6%83%B3%E5%AE%9A%E3%81%95%E3%82%8C%E3%82%8B%E5%88%A9%E7%94%A8%E3%82%B7%E3%83%BC%E3%83%B3%E3%81%8C%E7%95%B0%E3%81%AA%E3%82%8B)
    
    [Best practices for managing service account keys | IAM Documentation | Google Cloud](https://cloud.google.com/iam/docs/best-practices-for-managing-service-account-keys)
    

---

- VPC サービスコントロールが守るものは？どのように設定するか？Bridgeとは？Private Google Accessとの違いは？
    
    ### APIを守る
    
    - VPC外にあるサービスを制御する、と勘違いされがちだが、実際には各種APIを制御する。あくまでAPIを制御するので、GCEへのSSHやRDPといった直接アクセスは制御できない。
    - セキュリティー境界を作成し、境界内の各種Google Cloud APIへのアクセスをIPだけでなく、ユーザーや位置、デバイス、時間帯など様々な方法で制御できる。
        
        ![image.png](Security%20518b9659cac843419433812359bcd221/image%2014.png)
        
    
    ### 設定方法
    
    - **Access Context Manager**で**アクセスレベル**を定義し、サービス境界から参照することでアクセス制御する。(初期から提供されていた機能。API毎に異なるアクセスレベルを利用したい場合はプロジェクトを分離し、別々のサービス境界で管理する必要があった)
    - API毎により細かく制御する場合は**Ingress Policy**を使用する。
    - 境界内のクライアントやリソースから境界外へのアクセスはできない。その問題を解決するには**Egress Policy**を設定し、接続される側ではIngress Policy を設定する必要あり。
        
        ![IMG_7545.jpg](Security%20518b9659cac843419433812359bcd221/IMG_7545.jpg)
        
    
    Google Cloud エンタープライズIT基盤構築ガイドp247ページ
    
    ### Bridgeとは
    
    VPC Service Controls help define scope perimeter and protect a VPC from unauthorized access. Two VPC Service Control perimeters can be interconnected with the help of a bridge. A bridge is bidirectional in communication, but not transitive. This means that if Project A and B have their perimeters bridged, and if Project B and C also have a bridge, Project A will not automatically be bridged to Project C.
    
    [ブリッジを使用して境界を越えて共有する | VPC Service Controls | Google Cloud](https://cloud.google.com/vpc-service-controls/docs/share-across-perimeters?hl=ja)
    
    [VPC Service Controlsを分かりやすく解説 - G-gen Tech Blog](https://blog.g-gen.co.jp/entry/vpc-service-controls-explained#VPC-Service-Controls-%E3%81%A8%E3%81%AF)
    
    ### **VPC Service Control との違い**
    
    - 利用するIPアドレスが違う。[private.googleapis.com](http://private.googleapis.com/) を使うのがPrivate Google Access、 [restricted.googleapis.com](http://restricted.googleapis.com/) を使うのがVPC Service Control
    - アクセスできる API の種類も違う。restricted.googleapis.comではサポートされるAPIが限定される。
    
    ![Untitled](Security%20518b9659cac843419433812359bcd221/Untitled%2013.png)
    
    [限定公開の Google アクセスの仕組みと手順をきっちり解説 - G-gen Tech Blog](https://blog.g-gen.co.jp/entry/private-google-access-explained#privategoogleapiscom--restrictedgoogleapiscom-%E3%81%AE%E9%81%95%E3%81%84)
    

---

- Google Front Endと、Cloud Armorについて簡潔に説明せよ。
    
    ### GFE（Google Front End）
    
    以下の全体を指すらしい
    
    1. GCPのPoP （Point Of Presence）：各リージョンのデータセンターの入り口
    2. ユーザーリクエスト(外部インターネットから着信する HTTP(S)、TCP、TLS プロキシのトラフィック)は、PoPの中のロードバランサーに向かい、一番近いPoPへ入る
    3. トラフィックをロードバランサで終端し、DDoS 攻撃対策を提供(→L7レベル、**Cloud Armor**)して、Google Cloud サービス自体へのトラフィックをルーティングおよび負荷分散(over Google's global network to the closest backend that has sufficient capacity available.)
        
         → CloudArmorも、LBと同じくエッジPOPにある
        
        > Google Cloud プロキシベース外部ロードバランサはすべて、Google の本番環境インフラストラクチャの一部である Google Front End（GFE）から DDoS 保護を自動的に継承します。
        > 
    
    ### Cloud Armor
    
    - Google Cloud Armorは、ロードバランサーの付加機能として利用する。
    - DDoS保護＋WAF。レイヤ7属性のリクエストをレイヤ7フィルタリングやスクラブによりブロックする。
    - 外部 HTTP(S) ロードバランサ、TCP プロキシ ロードバランサ、または SSL プロキシ ロードバランサの背後にあるバックエンド サービスにのみ使用できる。負荷分散スキームはexternalである必要
    - プレビューモードを使うとルールを適用しなくても、その影響をプレビューが可能
    
    - DoS
        
        TWO ways that Google Cloud helps mitigate the risk of DDoS for its customers.
        
        1. **Internal capacity many times that of any traffic load we can anticipate.**→大規模DoS攻撃の負荷も簡単に吸収してしまう。
        2. **State-of-the-art physical security for hardware and servers.**
        
    
    ![Untitled](Security%20518b9659cac843419433812359bcd221/Untitled.jpeg)
    

---

- 仮想アプライアンスとは？
    
    アプライアンス：ネットワーク上で特定の機能を提供する専用の機器
    
    **仮想アプライアンス：**仮想化技術を用いて、アプライアンス機能が稼働する環境を即座に構成できるようにしたもの。**[仮想マシン](https://e-words.jp/w/VM.html)**（VM）の**[イメージファイル](https://e-words.jp/w/%E3%83%87%E3%82%A3%E3%82%B9%E3%82%AF%E3%82%A4%E3%83%A1%E3%83%BC%E3%82%B8.html)**などとして提供される。
    
    例）CiscoルータのVMWareのイメージ、NGFWのイメージ
    

---

- NGFWとは？
    
    ****次世代ファイアウォール 【next generation firewall】 NGFW****
    
    従来のファイアウォールは、通信相手のIPアドレス、送信元や宛先の**[ポート番号](https://e-words.jp/w/%E3%83%9D%E3%83%BC%E3%83%88%E7%95%AA%E5%8F%B7.html)**、**[TCP](https://e-words.jp/w/TCP.html)**の通信状態に矛盾がないか（**[ステートフルパケットインスペクション](https://e-words.jp/w/%E3%82%B9%E3%83%86%E3%83%BC%E3%83%88%E3%83%95%E3%83%AB%E3%83%91%E3%82%B1%E3%83%83%E3%83%88%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%9A%E3%82%AF%E3%82%B7%E3%83%A7%E3%83%B3.html)**）などを元に通信の許可や拒否を判断するのが一般的だった。
    
    次世代ファイアウォールはこれに加え、**[アプリケーション層](https://e-words.jp/w/%E3%82%A2%E3%83%97%E3%83%AA%E3%82%B1%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3%E5%B1%A4.html)**（HTTPなど）の通信内容を解析（**[ディープパケットインスペクション](https://e-words.jp/w/%E3%83%87%E3%82%A3%E3%83%BC%E3%83%97%E3%83%91%E3%82%B1%E3%83%83%E3%83%88%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%9A%E3%82%AF%E3%82%B7%E3%83%A7%E3%83%B3.html)**）し、どのアプリケーションが通信を試みているのかを識別したり、外部からの不審なアクセスを探知（**[IDS](https://e-words.jp/w/IDS.html)**/**[IPS](https://e-words.jp/w/IPS.html)**：侵入検知/防止システム）し、可否の判断に加えることができる。
    
    [次世代ファイアウォールとは - IT用語辞典](https://e-words.jp/w/%E6%AC%A1%E4%B8%96%E4%BB%A3%E3%83%95%E3%82%A1%E3%82%A4%E3%82%A2%E3%82%A6%E3%82%A9%E3%83%BC%E3%83%AB.html)
    

---

- Cloud Audit Logsの種類と、デフォルトでの有効/無効は？また、ログ表示に必要な権限は？
    
    ### 監査ログの種類
    
    Google Cloud Platform(以降、GCP)の監査ログ(Cloud Audit Logs)には下記4種類がある。
    
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
    
    ![Untitled](Security%20518b9659cac843419433812359bcd221/Untitled%2014.png)
    
    ### Access Transparency logとは？
    
    アクセスの透明性ログから得られる情報は、Cloud 監査ログから得られる情報とは異なります。Cloud 監査ログには、Google Cloud 組織のメンバーが Google Cloud リソースで行った操作が記録されます。一方、アクセスの透明性ログには、Google の担当者が行った操作が記録されます。
    

---

- Access Transparency logとは？
    
    アクセスの透明性ログから得られる情報は、Cloud 監査ログから得られる情報とは異なります。Cloud 監査ログには、Google Cloud 組織のメンバーが Google Cloud リソースで行った操作が記録されます。一方、アクセスの透明性ログには、Google の担当者が行った操作が記録されます。
    

---

- Google Cloud におけるデータ転送時の暗号化について、プロトコルと実装に使われるのは？
    
    ### BoringSSL(実装ライブラリ)
    
    Googleにおける、転送時のデータ暗号化で使われているライブラリ。GoogleFrontEndにおけるTLS暗号化プロトコルの実装に使われる。 Google が維持管理する TLS プロトコルのオープンソース実装であり、OpenSSL から分岐したもの。
    
    内部 HTTP(S) 負荷分散は、Google の BoringSSL ライブラリを使用。Google は、FIPS 準拠モードで内部 HTTP(S) 負荷分散のための Envoy プロキシを構築。
    
    ⇔HTTP(S) 負荷分散と SSL プロキシ負荷分散は Google の BoringCrypto ライブラリを使用する
    
    ### TLS/ALTS( プロトコル)
    
    **ALTS(**Application Layer Transport Security)という暗号化プロトコルもあり、こちらもBoringSSLで実装される。 ALTSは相互認証/暗号化によりRPCをカプセル化するプロトコル。Google Cloud サービスの場合、RPC はデフォルトで ALTS を使用して保護される。
    
    Google’s Application Layer Transport Security (**ALTS**) is a mutual authentication and transport encryption system developed by Google and typically used for securing Remote Procedure Call (RPC) communications within Google’s infrastructure. ALTS is similar in concept to mutually authenticated TLS but has been designed and optimized to meet the needs of Google’s datacenter environments.
    
    ※ **remote procedure call** (**RPC**) is when a computer program causes a procedure (subroutine) to execute in a different address space (commonly on another computer on a shared network), which is coded as if it were a normal (local) procedure call, without the programmer explicitly coding the details for the remote interaction.
    
    ![Untitled](Security%20518b9659cac843419433812359bcd221/Untitled%2015.png)
    
    ALTS には相互 TLS に似た安全な **handshake** プロトコルがある。ALTS を使用して通信しようとする 2 つのサービスは、機密情報を送信する前に、この handshake プロトコルを使用して通信パラメータを認証およびネゴシエートする。
    
    ![https://cloud.google.com/static/images/security/alts-handshake.png?hl=ja](https://cloud.google.com/static/images/security/alts-handshake.png?hl=ja)
    
    [Google Cloud での転送データの暗号化 | ドキュメント](https://cloud.google.com/docs/security/encryption-in-transit?hl=ja)
    

---

- SSLロードバランサーのデフォルトのSSLポリシーは？
    
    SSL load balancers have three pre-configured profile:
    
    - **COMPATIBLE.** Allows the broadest set of clients, including clients that support only out-of-date SSL features, to negotiate SSL with the load balancer.
    - **MODERN.** Supports a wide set of SSL features, allowing modern clients to negotiate SSL.
    - **RESTRICTED.** Supports a reduced set of SSL features, intended to meet stricter compliance requirements.
    
    If no SSL policy is set, your load balancer will use the default SSL policy, which is equivalent to one that uses a COMPATIBLE profile with a minimum TLS version of TLS 1.0.
    

---

- BeyondCorp とは
    
    BeyondCorp は、信頼されないネットワークから VPN を使わずにすべての従業員が作業できるようにするためのエンタープライズ向けセキュリティ モデル
    
    Cloud IAP は [BeyondCorp](https://cloud.google.com/beyondcorp/)
     の構成要素
    
    BeyondCorp は、Google が実装したゼロトラスト モデルです。Google での 10 年に及ぶ経験を基に、コミュニティから寄せられた最善のアイデアやベスト プラクティスを加味して構築されました。ネットワーク境界で行っていたアクセス制御をユーザー単位で行うことで、従来のように VPN を介さなくても実質的にどこからでも安全に作業できるようになります。
    
    BeyondCorp のコンポーネント
    
    BeyondCorp では、シングル サインオン、アクセス制御ポリシー、プロキシへのアクセス、ユーザーおよびデバイスベースの認証と承認が可能です。BeyondCorp の原則
    
    - 接続しているネットワークによって、サービスへのアクセス可否が左右されることはない
    - サービスへのアクセス権は、ユーザーとデバイスからのコンテキスト情報に基づいて付与される
    - サービスへのアクセスを認証、認可、暗号化する必要がある
    
    ---
    
- SLAとは？
    
    SLA」とは「Service Level Agreement」の略で、
    
    **「サービス品質保証」を意味します。**
    
    サービスを提供する事業者がサービスの契約者に対し、サービス内容を保証するための契約です。
    
    「サービスレベルアグリーメント」「サービスレベル合意書」とも呼ばれます。
    
    サービスの契約書では、付属資料として扱われることが多いです。
    
    ダウンタイム、可用性99.99etc
    
    SLA is the entire agreement that specifies what service is to be provided, how it is supported, times, locations, costs, performance, penalties, and responsibilities of the parties involved. 
    
    SLOs are specific, measurable characteristics of the SLA, such as availability, throughput, frequency, response time, or quality. 
    
    **An SLA can contain many SLOs**.
    
- RPO、RTO
    
    RTO(Recovery Time Objective：目標復旧時間)
    
    RPO(Recovery Point Objective：目標復旧ポイント)
    
    失われるデータの最大許容量の測定値
    
    RTO and RPO values typically roll up into another metric: the [service level objective](https://wikipedia.org/wiki/Service_level_objective)
     (SLO), which is a key measurable element of an SLA. 
    
    SLA is the entire agreement that specifies what service is to be provided, how it is supported, times, locations, costs, performance, penalties, and responsibilities of the parties involved. 
    
    SLOs are specific, measurable characteristics of the SLA, such as availability, throughput, frequency, response time, or quality. 
    
    **An SLA can contain many SLOs.**
    
    ![Untitled](Security%20518b9659cac843419433812359bcd221/Untitled%2017.png)
    
    ![Untitled](Security%20518b9659cac843419433812359bcd221/Untitled%2018.png)
    

- pub and spoke model
    
    ![Untitled](Security%20518b9659cac843419433812359bcd221/Untitled%2019.png)
    
- 複数のNICを持つVM作成について
    
    [https://cloud.google.com/vpc/docs/create-use-multiple-interfaces?hl=ja](https://cloud.google.com/vpc/docs/create-use-multiple-interfaces?hl=ja)
    
    GCPだと、VPCにNICが対応するらしく、複数のNICをVMに持たせるには、あらかじめ対応する別々のVPCを作っておく必要があるっぽい
    
- 複数NIC
    
    In a multiple interface instance, every interface gets a route for the subnet that it is in. In addition, the instance gets a single default route that is associated with the primary interface eth0. Unless manually configured otherwise, any traffic leaving an instance for any destination other than a directly connected subnet will leave the instance via the default route on eth0.
    
- WAFとは？Firewallとの違いは何？
    
    WAF（Web Application Firewall）は、Webアプリケーションの脆弱性を突いた攻撃へ対するセキュリティ対策のひとつ。Webアプリへのアクセスを「シグネチャ」（アクセスのパターンを記録しているもの）を用いて照合し、攻撃を検知、通信可否の判断を行う。
    
    ファイアウォール（Firewall）は、ネットワークレベルでの対策であり、IP:ポート番号でアクセスを制限するソフトウェアおよびハードウェアのこと。社内でのみ使用する情報システムへの外部からのアクセスを制限することは可能だが、外部へ公開する必要のあるWebアプリケーションに制限を掛けることはできないので、WAFの範疇となる。
    

- Managed instance groups + auto scaling groupみたいなもの？
    
    []()
    
    ![image.png](Security%20518b9659cac843419433812359bcd221/image%2015.png)
    
    Option C is also not correct as even if we assume the application on compute engine will use managed instance groups using deployment manager, **instance templates** are immutable so you will need to create a new instance template to update the VMs.
    
- VPN
    
    []()
    
    ![image.png](Security%20518b9659cac843419433812359bcd221/image%2016.png)
    
    HA VPNゲートウェイなるものもある！単にゲートウェイが二つあるらしい。VPNゲートウェイ飽和問題の尻尾が垣間見える。
    
    VPNはVPNゲートウェイを経由するので、ネットワーク機器のリソース消費が多く、ユーザーが増えると通信が遅くなる？だからHA VPNとかが必要とされるのだろう。
    

- cloud vpn
    
    []()
    
    ![image.png](Security%20518b9659cac843419433812359bcd221/image%2017.png)
    
- global routing with vpn
    
    (Lab)
    
    HA VPN is a regional resource and **cloud router** that by default only sees the routes in the region in which it is deployed. To reach instances in a different region than the cloud router, you need to enable global routing mode for the VPC. This allows the cloud router to see and **advertise** routes from other regions.
    
    1. Open a new Cloud Shell tab and update the **bgp-routing mode** from **vpc-demo** to **GLOBAL**:
    
    `gcloud compute networks update vpc-demo --bgp-routing-mode GLOBAL`
    
- ダイナミックルーティング with cloud router
    
    []()
    
    ![image.png](Security%20518b9659cac843419433812359bcd221/image%2018.png)
    
    Cloud Routerはスタティックとダイナミックルーティングに対応。
    
    ダイナミックルーティングを使うには、BGPの？セッティングをちゃんとする必要がある？
    
    静的アドレスの管理とかが不要になる
    
    ルーター同士でBGPに従い、ネットワークの追加削除などのトポロジー変化を自動でアドバタイズしてくれる。
    
    - Dynamic routing
        
        []()
        
        ![image.png](Security%20518b9659cac843419433812359bcd221/image%2011.png)
        
    - 新しく追加されたネットワークは自動的に通知(アドバタイズ？)される
        
        []()
        
        ![image.png](Security%20518b9659cac843419433812359bcd221/image%2012.png)
        
    - 何故CloudRouter?
        
        []()
        
        ![image.png](Security%20518b9659cac843419433812359bcd221/image%2019.png)
        
    
- Cloud Router
    
    ## **Cloud Router**
    
    インターネットとは、たくさんのネットワーク網を相互通信させる技術とも表現できる。別のネットワークに接続するためにはパケットの宛先を知り、保持しておかなければいけないが、この技術を**経路制御**という。経路制御のための代表的なプロトコルが [BGP](https://ja.wikipedia.org/wiki/Border_Gateway_Protocol)。BGP で GCP 内外のネットワークとルーティングするためのサービスが Cloud Router。
    
    → 要するに Cloud Routerと外部のルータなりゲートウェイの間でBGPセッションがなされ、各AS？内部のルート情報が交換されることで、ほかのASへのアクセスを獲得できる。
    
    ### デフォルトのルート アドバタイズ
    
    Cloud Router は、基本的にリージョナル。
    
    デフォルトでマルチリージョンのVPCに一つのCloud Routerが対応するのではなくて、その中の特定リージョンのサブネットに対して一つのCloud Routerが対応する(**リージョン動的ルーティングモード**)
    
    設定を変えてグローバルリージョン、つまりVPCのサブネット全体のルートをアドバタイズする**グローバル動的ルーティングモード**にすることもできる。
    
    > Cloud Router によって、ルーターが構成されているリージョンまたは Virtual Private Cloud（VPC）ネットワーク全体でサブネットが動的にアドバタイズされて、学習済みルートが伝播されます。
    > 
    
    > VPC ネットワーク内の Cloud Router がリージョンかグローバルかは、VPC ネットワークの動的ルーティング モードによって異なります。VPC ネットワークを作成または編集するときに、動的ルーティング モードをリージョンまたはグローバルに設定できます。
    > 
    
    [動的ルーティング モードを設定する | Cloud Router | Google Cloud](https://cloud.google.com/network-connectivity/docs/router/how-to/configuring-routing-mode?hl=ja)
    
    - **アドバタイズする**
        
        ネットワーク制御分野の用語。Cloud Router の場合、隣接するネットワークのルータに対象（サブネットや外部 IP アドレス）への経路情報を伝達することを指す。
        
         **例文**
        
        まず `us-west1` リージョンにある Cloud Router が外部のオンプレミス・ネットワークと VPN トンネルを通じてハイブリッド接続している構成であるとします。Cloud Router はデフォルトですべてのサブネットを**アドバタイズしている**ので、`us-west1` のサブネット内の VM はオンプレミス・ネットワークを認識できます。また、サブネット内に Proxy サーバを立て、その外部 IP アドレスを**アドバタイズする**ことによって、オンプレミス・ネットワークは Proxy サーバを認識できます。
        
- 使い分け
    
    []()
    
    ![image.png](Security%20518b9659cac843419433812359bcd221/image%2020.png)
    
- 使い分け2
    
    []()
    
    ![image.png](Security%20518b9659cac843419433812359bcd221/image%2021.png)
    
- 選び方
    
    []()
    
    ![image.png](Security%20518b9659cac843419433812359bcd221/image%2022.png)
    
    YouTube とかworkPsCeの場合、ピアリングなのは何故だろう？？
    
    →確か、privateなアドレス空間へアクセスが不要で、Googleのパブリックなアドレスにだけアクセスするから、
    
- クラウドマーケットプレイス
    
    []()
    
    ![image.png](Security%20518b9659cac843419433812359bcd221/image%2023.png)
    
- 間違えた問題VPC flow log
    
    []()
    
    ![image.png](Security%20518b9659cac843419433812359bcd221/image%2024.png)
    
- custom rolesのEtagと—stage flag
    
    —stage flagをENABLEにしたりDISABLEにできるし、custom rolesをdeleteすると、stageがDeletedになる。Roleを新しいものに置き換えた時に古いものをDEPRECATEDのstageに設定することも推奨される。
    
    一旦deleteした後にundeleteコマンドで復活させると、--stageタグがもとに戻っている。
    
    Etag
    
    A common pattern for updating a resource's metadata, such as a custom role, is to read its current state, update the data locally, and then send the modified data for writing. This pattern could cause a conflict if two or more independent processes attempt the sequence simultaneously.
    
    For example, if two owners for a project try to make conflicting changes to a role at the same time, some changes could fail.
    
    Cloud IAM solves this problem using an `etag` property in custom roles. This property is used to verify if the custom role has changed since the last request. When you make a request to Cloud IAM with an etag value, Cloud IAM compares the etag value in the request with the existing etag value associated with the custom role. It writes the change only if the etag values match.
    
- VMの起動スクリプト、ブートディスク？とか指定してスクリプトを準備できる

- Shielded VM
    
    セキュリティーサービスの一種
    
    ブートシーケンス内に仕込まれるルートキットやブートキットを検知する。
    
    [ルートキットはなぜ危険なのか？どのような対策が必要とされるのか? | サイバーセキュリティ情報局](https://eset-info.canon-its.jp/malware_info/special/detail/200630.html)
    
    UEFIとは？
    
    コンピュータ内の各装置を制御する**[ファームウェア](https://e-words.jp/w/%E3%83%95%E3%82%A1%E3%83%BC%E3%83%A0%E3%82%A6%E3%82%A7%E3%82%A2.html)**
    とオペレーティングシステム（OS）の間の通信仕様を定めた標準規格の一つ。従来の**[BIOS](https://e-words.jp/w/BIOS.html)**
    に代わるもの。UEFI対応ファームウェアを指してUEFIと呼ぶこともある。
    
    一台のコンピュータにOSを複数導入して起動時に選択する**[ブートローダ](https://e-words.jp/w/%E3%83%96%E3%83%BC%E3%83%88%E3%83%AD%E3%83%BC%E3%83%80.html)**
    の機能もUEFIブートマネージャとして提供されるようになり、OS側でブートローダを用意する必要がなくなった
    
    OSのデジタル署名を検証して正当なものしか起動しない**セキュアブート**にも対応し、盗難対策として利用できる。
    
    ![Untitled](Security%20518b9659cac843419433812359bcd221/Untitled%2020.png)
    
    [UEFIとは - IT用語辞典](https://e-words.jp/w/UEFI.html#:~:text=UEFI%20%E3%80%90Unified%20Extensible%20Firmware%20Interface,%E3%81%AEBIOS%E3%81%AB%E4%BB%A3%E3%82%8F%E3%82%8B%E3%82%82%E3%81%AE%E3%80%82)
    
    []()
    
    ![image.png](Security%20518b9659cac843419433812359bcd221/image%2025.png)
    
- Confidential VM
    
    メモリー上のデータも個別の暗号鍵で暗号化する。
    
    Confidential VMs use AMD’s Secure Encrypted Virtualization, which keeps data encrypted in RAM. They can be managed using Customer-Supplied or Customer-Managed Encryption Keys. These instances contain dedicated AES engines that encrypt data as it flows out of sockets and decrypt data when it is read.
    When restarting, Confidential VMs generate a unique log called Launch Attestation. Cloud Logging can be used to filter the logs and collect sevLaunchAttestationReportEvent.
    
- HSM
    
    []()
    
    ![image.png](Security%20518b9659cac843419433812359bcd221/image%2026.png)
    
- アプリ脆弱性
    
    []()
    
    ![image.png](Security%20518b9659cac843419433812359bcd221/image%2027.png)
    

---
   
- CSEKはGCSとGCEのみで使えるサービス！BigQueryとかでは使えない。
    
    BigQueryの場合、CMEKを検討する。
    
    CSEK are not supported in BigQuery at the time of writing and are only available for Cloud Storage and Compute Engine services
    
- gsutil rewrite -k gs://$BUCKET_NAME/setup.htmlで鍵をローテートするらしい。別のカギでencryptしたファイルも、ローテートできるぽい。逆に別のカギでencryptしたファイルをローテートしないでダウンロードしようとしても、decrypt_keyに以前のカギを指定しておかないとdecrypt出来ずにエラーになる
    - TCP proxy/TCPUDPロードバランサーの違い？
        
        TCP Proxy Load Balancing is implemented on GFEs that are distributed globally. If you choose the Premium Tier of Network Service Tiers, a TCP proxy load balancer is global. In Premium Tier, you can deploy backends in multiple regions, and the load balancer automatically directs user traffic to the closest region that has capacity. TCP Proxy Load Balancing is intended for TCP traffic on specific well-known ports, such as port 25 for Simple Mail Transfer Protocol (SMTP) or 995 (POP3). Option D is not valid as Cloud CDN is used to optimize content distribution using http(s) traffic. Option C also uses http(s) while we need to use TCP as mail traffic doesn't rely on http(s). Option B is not valid as TCP/UDP network load balancer is regional not global.
        
- CSEKではGCS or GCEのデータを使うときに顧客自身がAPI callと一緒に鍵を渡す。つまり結局GCPに鍵は渡る。が、Googleはそれをメモリ上でのみ使い、storageには書き込まない、とのこと。
- DEKはローカルで生成する！KEKをGCP上で作成し、DEKを暗号化して、データと一緒に保存する。→ CSEKの場合、DEKもKEKもどちらもローカルで生成するはず。DEKを暗号化してデータと一緒に保存するのは同じだが、KEKをAPIコールと一緒に渡すのが異なるのだろう。
    
    ⇔ CSEKのDEKはローカルじゃなくてGoogleで作られる、という解説もある。。どっちが本当なの？→多分、どっちでもいいのでは？
    
    ![Untitled](Security%20518b9659cac843419433812359bcd221/Untitled%2021.png)
    
    DEK should be generated locally and always encrypted at rest. In order to encrypt the DEK you must use KEK, which is generated and stored centrally in KMS. Therefore both the data and the encrypted DEK (using the KEK) should be stored at rest. To encrypt the data using envelope encryption:
    
    - Generate a DEK locally. You could do this with an open source library such as [OpenSSL](https://www.openssl.org/), specifying a cipher type and a password from which to generate the key. You can also specify a salt and digest to use, if desired.
    - Use this DEK locally to encrypt your data.
    - As an example, you could use OpenSSL as shown in the [encrypting the message](https://wiki.openssl.org/index.php/EVP_Symmetric_Encryption_and_Decryption#Encrypting_the_message) example. For best practice, use 256-bit Advanced Encryption Standard (AES-256) cipher in Galois Counter Mode (GCM).
    - Generate a new key in Cloud KMS, or use an existing key, which will act as the KEK. Use this key to encrypt (wrap) the DEK.
    - Store the encrypted data and the wrapped DEK.
    
    Google allows you to provide CSEK for two services: Cloud Storage and Compute Engine. In Cloud Storage if the user supplies a CSEK, that key is used as the KEK for chunk keys and wraps those keys. DEK keys are generated by Google and used to read/write the data to the disk.
    
    ![Untitled](Security%20518b9659cac843419433812359bcd221/Untitled%2022.png)
    

キーのバージョン

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
    

![Untitled](Security%20518b9659cac843419433812359bcd221/Untitled%2023.png)

---

---

- Cloud Security Command Center
    
    Security Command Center（以下SCC）は、Google Cloudの組織配下のプロジェクトにおいて、セキュリティリスクのある設定や、脆弱性（アプリも含む）を見つけてくれるサービスです。 見つけた結果を表示するダッシュボード機能もあります。 なお、SCCは[組織](https://cloud.google.com/resource-manager/docs/creating-managing-organization/?hl=JA)に対して設定するサービスのため、プロジェクト単体では使用できません。
    
    無料のスタンダード ティアと有料のプレミアム ティアがあり、スタンダードでは一部機能のみ使用できます。
    
    | 機能（サービス）名 | 機能概要 | スタンダード | プレミア |
    | --- | --- | --- | --- |
    | Security Health Analytics | 公開FWなど、Google Cloud の脆弱性と構成ミスをに検出 | 一部利用可（公開FWなど一部の設定検知のみ） | 利用可（CISなど各種基準に対する準拠チェックも含む） |
    | Web Security Scanner | アプリケーションの脆弱性スキャン | 一部利用可（公開 URL と IPをスキャン） | 利用可（アプリ脆弱性を含めスキャン） |
    | Event Threat Detection | アカウントへの不正アクセスなど各種イベントを検知 | 利用不可 | 利用可 |
    | Container Threat Detection | コンテナへの攻撃を検知 | 利用不可 | 利用可 |
    
    これらの基本4サービスのほか、以下の3つも統合されたサービスとして、検知内容をSCC上で確認できるようになっています。スタンダードでも利用可能です。
    
    | 統合されたサービス名 | 機能概要 |
    | --- | --- |
    | Anomaly Detection | 仮想マシン（VM）のセキュリティ異常（漏洩された認証情報やコイン マイニングなど）を検知 |
    | Cloud Armor | DDoSやXSSなどの攻撃を保護 |
    | Data Loss Prevention | 機密性の高いデータを検出、分類、保護 |
    
    [Security Command Centerを使用してGoogle Cloud内のセキュリティイベントを検知する - NRIネットコムBlog](https://tech.nri-net.com/entry/gcp-scc-notification)
    
- Network Connectivity Center, Network Intelligence Center,Security Command Center
    - Security Command Center
    Security Health Analytics, Web Security Scanner, サードパーティー製品連携(Forseti, Splunk..etc)、アクセス管理、Event Threat Detection, Container Threat Detection, 継続的エクスポート
    - Network Intelligence Center
    ネットワークトポロジー、接続テスト、パフォーマンスダッシュボード、ファイアウォールインサイト
- Resource Manager
    
    Resource Manager allows to manage your projects centrally and create organizations, folders and projects as well as to manage IAM across your org, but it doesn't provide a historical record of all resources.
    
- ファイヤーウォールインサイト
    
    Network Intelligence Centerのモジュールの一つ。**指標レポートとインサイト レポート**を提供する。この 2 つのレポートには、VPC ネットワークでのファイアウォールの使用状況と、さまざまなファイアウォール ルールが与える影響についての情報が含まれる。
    
    構成誤り発見、緩すぎるルールの修正、特定のルールヒット数、ほかのルールで隠されているシャドウルールの検出、など。
    
    [ファイアウォール インサイトを使用したファイアウォール ルールの管理 | Google Cloud Blog](https://cloud.google.com/blog/ja/products/identity-security/eliminate-firewall-misconfigurations-with-firewall-insights)
    
- Forseti Security
    
    Security Command Centerにconnectもできる。
    
    can have a historical record of what was running in Google Cloud Platform at any point in time.
    
    Security Command Center will only scan resources once a day while forseti can scan them as frequently as you establish. 
    
    Also Cloud Security Command Center only includes projects in an active state, while Forseti Inventory includes projects all possible states.
    
    [Spotify と Google が共同開発 : オープンソースの GCP セキュリティ ツール Forseti Security | Google Cloud Blog](https://cloud.google.com/blog/ja/products/gcp/with-forseti-spotify-and-google-release-gcp-security-tools-to-open-source-community15)
    
- Web Security Scanner
    
    [Web Security Scanner](https://cloud.google.com/security-command-center/docs/concepts-web-security-scanner-overview) で App Engine アプリケーションをスキャンして脆弱性を検出します。Web Security Scanner は、App Engine、Google Kubernetes Engine（GKE）、Compute Engine の各ウェブ アプリケーションにおけるセキュリティの脆弱性を特定します。
    
    このサービスは、アプリケーションをクロールして、開始 URL の範囲内にあるすべてのリンクをたどり、できる限り多くのユーザー入力とイベント ハンドラを実行しようとします。クロス サイト スクリプティング（XSS）、Flash インジェクション、混合コンテンツ（HTTPS 内の HTTP）、更新されていない / 安全ではないライブラリなど、4 つのよくある脆弱性に対して自動的にスキャンし、脅威を検出します。
    
    偽陽性率は非常に低く、早い段階で脅威を特定できます。セキュリティ スキャンの設定、実行、スケジュール、管理もとても簡単です。
    
    ---
    
- CSPM
    
    > クラウドの設定ミスによる情報漏洩に対して有効なソリューションとして注目されているのがCSPM（Cloud Security Posture Management : クラウドセキュリティ態勢管理）です。
    > 
    
    > CSPMは、IaaSやPaaSといったパブリッククラウドに対してAPI連携により、クラウド側の設定を自動的に確認し、セキュリティの設定ミスや各種ガイドライン等への違反が無いかを継続してチェックすることができます。また、IaaS/PaaSを利用する際のベストプラクティスをチェックルールとしてあらかじめ用意しており、ユーザへより安全な利用方法を提示してくれます。
    > 
    
    [CSPMとは？クラウドの設定ミス防止ソリューション｜選定で失敗しない３つのポイント](https://www.nri-secure.co.jp/blog/preventing-cloud-configuration-mistakes-with-cspm)
    
    ⇒ SCCやForsetiはCSPM用途に使えるソリューションといえる
    

---

---

- Cloud Logging では、Google Cloud 以外のシステムからもログや指標のデータを収集できる。
    
    Google が提供する Cloud Monitoring エージェントは、AWS EC2 インスタンスにインストール可能。また、オンプレミスのマシンに fluentd や collectd エージェントをインストールして、Cloud Monitoring サービスにデータを書き込める。
    
    Logging AgentやMonitoring AgentをGCEのlinux/windowsインスタンスにインストールすると、それはfluentdベースのツールで、勝手にLoggingやmonitoringのサービスにログやメトリクスを送信して収集してくれる！GCPじゃなくてもAWSとかオンプレでもいい！
    

---

- DLP APIのdate shifting とは？
    
    [日付シフト | データ損失防止（DLP）のドキュメント | Google Cloud](https://cloud.google.com/dlp/docs/concepts-date-shifting?hl=ja)
    
- Cloud DLP uses built-in and custom infoType detectors to scan images, documents, and text. Custom infoTypes can be dictionaries, regular expressions, or dictionaries extracted from BigQuery or Cloud Storage. Use dictionaries when you want to match a list of words or phrases, and use regular expressions when you want to detect matches based on a regex patte
    
    
- infoType検出器
    
    Cloud Data Loss Preventionでは、*情報タイプ*（*infoType*）を使用してスキャンする対象を定義します。infoType は、名前、メールアドレス、電話番号、識別番号、クレジット カード番号などの機密データのタイプを表します。
    
    Cloud DLP で定義されている infoType には、それぞれ対応する検出器があります。Cloud DLP では、スキャンの構成に含まれる infoType 検出器を使用して、検査の対象と検査結果の変換方法が決定されます。
    
    [InfoType detector reference | Data Loss Prevention Documentation | Google Cloud](https://cloud.google.com/dlp/docs/infotypes-reference)
    
- 仮名化変換方式
    
    
    | 仮名化（入力値を暗号ハッシュで置換） | CryptoHashConfig | 特定のデータ暗号鍵で生成された 32 バイトの 16 進文字列で入力値を置換します。詳細については、仮名化のコンセプトのドキュメントをご覧ください。 |  | ✔ | 文字列か整数 |
    | --- | --- | --- | --- | --- | --- |
    | 仮名化（暗号形式を維持したトークンに置換） | CryptoReplaceFfxFpeConfig | FFX モードのフォーマット保持暗号化（FPE）を使用して、入力値を同じ長さの「トークン」（サロゲート値）に置き換えます。これにより、長さのフォーマット検証が必要なシステムで出力を使用できるようになります。これは、文字列の長さを維持する必要があるレガシー システムで役に立ちます。重要: 入力の長さが異なる場合や、長さが 32 バイトを超える場合は、CryptoDeterministicConfig を使用してください。セキュリティを維持するため、アメリカ国立標準技術研究所では次の上限を設けています。
    • radix^max_size <= 2^128.
    • radix^min_len >= 100入力されたアルファベット空間とサイズを保持する必要がなく、参照整合性を保証するすべてのユースケースで、CryptoDeterministicConfig を使用することをおすすめします。詳細については、仮名化のコンセプトのドキュメントをご覧ください。 | ✔ | ✔ | 文字数上限があり、均一の長さの文字列か整数。アルファベットは 2 文字以上、95 文字以下にする必要があります。 |
    | 仮名化（暗号トークンに置換） | CryptoDeterministicConfig | 合成初期化ベクトルモード（AES-SIV）の AES を使用して、入力値を同じ長さのトークンまたはサロゲート値に置換します。この変換方法では、フォーマット保持トークン化とは異なり、サポートされる文字列セットに制限がなく、同じ入力値の各インスタンスに対して同じトークンが生成され、サロゲート値を使用した元の暗号鍵に基づく再識別が可能です。 | ✔ | ✔ | 任意 |
    
    [変換のリファレンス | データ損失防止（DLP）のドキュメント | Google Cloud](https://cloud.google.com/dlp/docs/transformations-reference?hl=ja)
    

Finally we have crypto based pseudomization: CryptoHashConfig and CryptoReplaceFfxFpeConfig. Since the question states that "the information must be reversible" the only valid option is using CryptoReplaceFfxFpeConfig.

![Untitled](Security%20518b9659cac843419433812359bcd221/Untitled%2024.png)

- 

---

---

- ドメイン全体への移譲とは？
    
    in order to be able to access user's google drive accounts on user's behalf we need to use wide domain delegation. In order to make this work the steps would be the following:
    
    1) Enable Gmail API at the project level in GCP: we need to do this to access google drive.
    
    2) Create a service account
    
    3) Grant domain access to the account and enable g suite domain-wide delegation
    
    4) Include the code to use the API (e.g using python) in our App Engine application.
    
- PCI DSS scopeをreduceするプラクティスは？
    
    Payment Card Industry Data Security Standard（**PCI DSS**）
    
    *PCI DSS は、PCI Security Standards Council で採択された一連のネットワーク セキュリティおよびビジネス上のベスト プラクティス ガイドラインによって構成され、お客様の決済カード情報を保護するための「最小限のセキュリティ基準」が定められています*
    
    [PCI Data Security Standard compliance | Cloud Architecture Center | Google Cloud](https://cloud.google.com/architecture/pci-dss-compliance-in-gcp#setting_up_your_payment-processing_environment)
    
    the recommendation is to segregate cardholder data environment into a separate project. That way you can implement all required measures to be compliant with PCI-DSS just where those are required and you will avoid mixing highly secure environments with less secure ones. This will effectively reduce the attack surface for payment systems.  Google also recommends that in its official documentation:
    
    This section describes how to set up your payment-processing environment. Setup includes the following:
    
    - **Creating a new Google Cloud account to isolate your payment-processing environment from your production environment.**
    - Restricting access to your environment.
    - Setting up your virtual resources.
    - Designing the base Linux image that you will use to set up your app servers.
    - Implementing a secure package management solution.
- ファイル整合性監視(FIM)とは？
    
    file integrity monitoring : FIM
    
    [Sysdig](https://www.scsk.jp/sp/sysdig/blog/sysdig_secure/post_3.html)
    
    ファイルの整合性監視により、機密性の高いファイルに関連するすべてのアクティビティを可視化できます。これは、アクティビティが悪意のある攻撃なのか、計画外の運用アクティビティなのかに関係なく、重要なシステムファイル、ディレクトリ、**不正な変更の改ざんを検出するために使用されます。**
    
    FIMは、[PCI-DSS](https://www.scsk.jp/sp/sysdig/blog/sysdig_secure/kubernetespci.html)
    、[NIST](https://www.scsk.jp/sp/sysdig/blog/sysdig_secure/sysdig_securenist_sp_800-190.html)
    、SOC2、HIPAAなどの多くの[コンテナコンプライアンス規制標準](https://sysdig.com/products/kubernetes-security/container-compliance/)
    、および[CISベンチマーク](https://docs.sysdig.com/en/benchmarks-and-compliance.html?_ga=2.225754202.111087130.1593403743-1175155605.1586396185)
    などのセキュリティのベストプラクティスフレームワークを満たすための中心的な要件となっている。
    
- Secret Manager
    
    Secret Manager helps save confidential details such as passwords and URLs. You can provide access to secrets using Cloud IAM. Secret Manager lets organizations share configured secrets instead of confidential information with developers. 
    
    Cloud KMS is used for storing encryption keys that are either managed by Google or by the customer. Cloud KMS lets you share symmetric and asymmetric keys. Cloud KMS can be used to encrypt/decrypt data, but that will expose critical information to developers in plain text.
    
    Hashicorp Vault is the best option for secure storage with automatic, scheduled secrets rotation. Cloud Key Management Service does not support automatic rotation of asymmetric keys.
    
    ![Untitled](Security%20518b9659cac843419433812359bcd221/Untitled%2025.png)
    
    ---
    

---

- Binary Authorization
    
    Google Kubernetes Engine（GKE）や Cloud Run に信頼できるコンテナ イメージのみをデプロイするためのデプロイ時セキュリティ コントロール
    
    開発プロセス中に信頼できる機関によるイメージへの署名を必須にして、デプロイ時にその署名を検証できる。検証プロセスを適用することで、適切であると認められたイメージのみがビルドとリリースのプロセスに組み込まれる
    
    レジストリなどがマルウェアなどにより乗っ取られている可能性もあるため、登録されているコンテナイメージが正式に認証されているものかをチェックするためにコンテナーイメージにアテステーションを追加する。
    
     Binary Authorizationポリシーを使用して、クラスター内にアテステーションがないコンテナーのデプロイメントをブロックし、いわゆる「野良イメージ」の本番環境へのデプロイメントを防ぐことも検討する。
    
- Binary Authorization for Docker Image
    
    []()
    
    ![image.png](Security%20518b9659cac843419433812359bcd221/image%2028.png)
    

It's not recommended to perform direct changes on containers already working within GKE. Using Puppet or Chef to push out the patch is risky and error-prone, therefore answer A is not correct

Answer B is also not correct, as setting auto-upgrade enable in GKE cluster will update the nodes but not the containers within the pods

(設定によっては、マスターのアップグレード中、 kubectl コマンドなど、操作を一時的に受け付けなくなる。ノードのアップグレードはデフォルトで「自動」に設定されている。マスターがアップグレードされると、ノードのアップグレードがスケジュールされ、一台ずつノードがローリングアップグレードされるのがデフォルトの挙動。)

it's not possible to configure containers to automatically update when a new baseline imageis available in container registry, at least not natively.

→コンテナのイメージは、Google-Managedのbase imageを使うことで、最新パッチが当てられる。ただし、コンテナ化したイメージをランタイム時に自動でアップデートはできない。

Option B is not correct as pod security policies are used to control security sensitive aspects of the pod specification like if any container in a pod can enable privileged mode, if SELinux should be used, etc. but not assigning pods to specific nodes.
Where the **taints** tell pods to go away, and **tolerations** ignore that warning; a **node selector** attracts the pod to a specific type of node. The node selector is the strongest type of **node affinity**; making the pod require a node that matches its selector. This has the effect that if there are no nodes matching the selector, the pod will not be scheduled.

Kubernetesには最初、特定のnodeに特定のpodをscheduleする方法として**node selector**を使う方法があった。(node selectorの他にも特定のnodeに特定のpodをscheduleするための仕組みとしてNode Affinityがある)

しかし後からもっと柔軟にscheduleするためのメカニズムが導入された。

それがTaints とTolerations。

(taintは"汚れ"という意味。tolerationは"容認"という意味。つまり"汚れ"を"容認"できるならscheduleできる仕組み)

[TaintとToleration](https://kubernetes.io/ja/docs/concepts/scheduling-eviction/taint-and-toleration/)

---

- ISO27017
    
    ### ISO27001
    
    「情報セキュリティ全般に関するマネジメントシステム規格」
    
    ISO 27001 outlines and provides the requirements for an information security management system (ISMS), specifies a set of best practices, and details the security controls that can help manage information risks but it's not specific to cloud
    
    ### ISO27017
    
    「クラウドサービスに関する情報セキュリティ管理策のガイドライン規格」
    
    ### ISO27018
    
    「パブリッククラウドにおける個人情報保護体制」
    
    ISO 27018 relates to one of the most critical components of cloud privacy: the protection of personally identifiable information (PII)
    
    ---
    
    ## 用語
    
- Bastion
    
    踏み台
    
- Attestation
    
    証言、立証、証明
    
    attestation は、attest という動詞から派生させた名詞。
    
    attest という動詞が「真実であると断言すること」という意味を持つことからもうかがえるように、法廷で宣誓の下に証言するような場合に用いられる語。
    
    だから、attestation は「証言」という意味で用いられる方が普通かもしれません。
    
- インベントリ
    
    
    | 読み／英語 | いんべんとり / Inventory |
    | --- | --- |
    | 詳細 | インベントリとは、元々「目録」「保有資産」といった意味のinventoryが語源となっており、 LAN上のクライアントPCや接続機器が持つデータを一覧にしたものを指す。「IT資産管理」などの管理システムでは、ソフトウェアやPC、サーバ、ストレージなどのハードウェアやルータやスイッチなどのネットワーク機器、その他ネットワークに接続されている周辺機器のインベントリ情報を自動収集し、資産情報として管理をすることができる。取得するインベントリ情報は、機器の機種、MACアドレス、IPアドレス、CPUの型番やメモリ、ハードディスク容量、利用履歴など、多くの情報を収集、管理する。 |

- CVE
    
    共通脆弱性識別子CVE(Common Vulnerabilities and Exposures)
    
- オリジンサーバー
    
    オリジナルのコンテンツが存在する Web サーバーのことです。
    
    自社ページなどを公開する際に、ページを配置したサーバに直接アクセスさせるのではなく WAF や CDN などのサービスを経由させてアクセスさせるネットワーク構成としたときに、WAF や CDN から見た接続先となるサーバをオリジンサーバと呼びます。
    
    ■接続イメージエンドユーザー → CDN → オリジンサーバー
    
    CDN を利用した場合、エンドユーザーはオリジンサーバーにアクセスするのではなく、CDNのサーバ（エッジサーバー）にアクセスします。
    
    [オリジンサーバーとはなんですか？](https://support.cdnext.stream.co.jp/hc/ja/articles/360001787832-%E3%82%AA%E3%83%AA%E3%82%B8%E3%83%B3%E3%82%B5%E3%83%BC%E3%83%90%E3%83%BC%E3%81%A8%E3%81%AF%E3%81%AA%E3%82%93%E3%81%A7%E3%81%99%E3%81%8B-)
    
- PCI DSS
    
    Payment Card Industry Data Security Standard（**PCI DSS**）
    
    *PCI DSS は、PCI Security Standards Council で採択された一連のネットワーク セキュリティおよびビジネス上のベスト プラクティス ガイドラインによって構成され、お客様の決済カード情報を保護するための「最小限のセキュリティ基準」が定められています*
    
    [PCI Data Security Standard compliance | Cloud Architecture Center | Google Cloud](https://cloud.google.com/architecture/pci-dss-compliance-in-gcp#setting_up_your_payment-processing_environment)
    
- PII
    
    redact personally identifiable information (PII)
    
- ephemeral
    
    一時的な
    
- 3-tier
    
    3層
    
    web-tier ウェブ層
    
    Tier は区分という意味もある。
    
    premium/standard tierとか。
    
- ASN
    
    BGPゲートウェイの？AS番号
    
    対向で設置するみたい
    
- a
- a
- a
- a
- 

Option B is also not correct as rotate option doesn't exist in *gcloud iam service-accounts keys.*

Google recommends to use the IAM service account API to automatically rotate your service account keys. You can rotate a key by creating a new key, switching applications to use the new key and then deleting the old key. To do so you need to use the `[serviceAccount.keys.create()](https://cloud.google.com/iam/reference/rest/v1/projects.serviceAccounts.keys/create)`
and `[serviceAccount.keys.delete()](https://cloud.google.com/iam/reference/rest/v1/projects.serviceAccounts.keys/delete)`
methods together to automate the rotation.

→自動化用のコマンドはないが、自分で自動化するように推奨されている笑

Option D is incorrect as openid connect is used to authenticate users to applications and not to access google cloud console.

Security Command Center is used to gather data about security threats and vulnerabilities in your assets.

GSuite is provided by google as a SaaS application. The following picture shows the shared responsibility model for SaaS apps provided by GCP:

![https://img-c.udemycdn.com/redactor/raw/test_question_description/2021-01-23_09-36-48-8c55739b0561ddecab7400d2321ef926.png](https://img-c.udemycdn.com/redactor/raw/test_question_description/2021-01-23_09-36-48-8c55739b0561ddecab7400d2321ef926.png)

Network security is provided out of the box by google in both PaaS and SaaS models, so It's not necessary for the customers to configure anything related to network security for GSuite.

GCSのIAMパーミッションはbucket level まで。オブジェクト毎には設定できないらしい。

→ ACLを使う？

![Untitled](Security%20518b9659cac843419433812359bcd221/Untitled%2026.png)

