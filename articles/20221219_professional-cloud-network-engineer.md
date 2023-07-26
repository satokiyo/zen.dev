---
title: "Professional Cloud Network Engineer 試験受験メモ"
emoji: "📕"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["GCP", "certificate", "NetworkEngineer"]
published: true
---

## 感想

- セキュリティエンジニアの試験にパスしていたので、＋ α で少し勉強すれば余裕じゃん？とか考えていたら、結構難しかった。もうちょっと気合い入れて勉強していたら良かったかも。前提となる知識はある程度共通していても、ネットワークの勉強はちゃんとしておいたほうがいいと思った。
- データエンジニア、セキュリティエンジニアの受験時には時間に余裕があったが、今回の試験はあまり余裕がなかった。英語の問題文が長いので、読むのに時間かかった。
- オンサイト受験の場合、早めに予約しておかないと、いつの間にか空きがなくなるので注意。

## 勉強内容

公式の模擬試験に加え、以下の Udemy の模擬試験を 3 周した。

https://www.udemy.com/share/106vJK3@ULsJVqnIdm4pxdmkn39tX4zrTwGCt3GIL5r2NJ3tULYpAHIoBxB8-tsuvN_6MdYE/

## 勉強内容メモ(QA 式)

---

- CloudCDN のキャッシュコンテンツが圧縮されていない原因は？

  > By default, some web server software will automatically disable compression for requests that include a **Via header**. The presence of a Via header indicates the request was forwarded by a proxy. HTTP proxies such as HTTP(S) load balancing add a Via header to each request as required by the HTTP specification.
  > To enable compression, you may have to override your web server's default configuration to tell it to compress responses even if the request had a Via header.

  ⇒ proxy 経由の(=via ヘッダがある)リクエストに対しては圧縮を解除してしまうサーバーがあるので、設定を変える。

---

- ハイブリッドネットワークで DNS resolution が実行される場所の推奨方法は？異なる GCP 環境の場合はどうするか？
  **Use a hybrid approach with two authoritative DNS systems**
  ⇒ ハイブリッドアプローチ

  > _Google-recommended practice is to use a hybrid approach with two authoritative DNS systems. Authoritative DNS resolution for your private Google Cloud environment is done by Cloud DNS. Authoritative DNS resolution for on-premises resources is hosted by existing DNS servers on-premises._

  ⇒ DNS コンテンツサーバー(=権威 DNS サーバー)を Cloud と On Prem において、互いにフォワーディングする。
  ※ 異なる GCP 環境の DNS はフォワーディングできない。

  > Cloud DNS cannot manage interorganizations DNS querys.

  その場合、VPN で二つの環境を接続して、DNS フォワーディングとゾーン転送の設定をする必要がある。
  **他のプロジェクトの**限定公開マネージド ゾーンにホストされている DNS レコードをもつ Cloud DNS コンテンツサーバーにクエリする必要がある場合は、**DNS ピアリング**を使用する。⇔ 一方、**同じプロジェクト内の**VPC ネットワークからのみクエリする場合、**限定公開ゾーン**を使う。

  ![Untitled](/images/20221219_professional-cloud-network-engineer/Untitled.png)

https://cloud.google.com/dns/docs/best-practices#choose_where_dns_resolution_is_performed

---

- DNS サーバーを大きく二種類に分けると？DNS フォワーディングとはどんな仕組み？
  2 種類の DNS サーバ

  1. DNS キャッシュサーバー＝フルサービスリゾルバ

     他の DNS サーバーに聞きに行く＝**DNS フォワーディング**

     DNS query を別の DNS サーバーに転送すること。

     - c.f. **Zone Transfer ゾーン転送**は DNS コンテンツサーバーの管理するドメイン群(ゾーン情報)をプライマリ → セカンダリ DNS に転送・複製すること。

     ※ DNS forwarding cannot be used to forward between different Google Cloud environments

     ⇒DNS ピアリングを使う

  2. DNS コンテンツサーバー、権威 DNS サーバー
     - 対応表を元に問い合わせに応答する。
     - 知らなければ「知らない」と答える。

https://wa3.i-3-i.info/word12577.html

---

- DNS ピアリングとは？VPC ピアリングとの関係性と違いは何か？限定公開ゾーン、クロスプロジェクトバインディングゾーンとの使い分けは？

  ### DNS ピアリング

  A DNS peering zone creates a producer-consumer bridge between two
  VPCs. The consumer VPC can then perform lookups in the producer VPC network,
  including records hosted inside a Compute Engine instance. Use DNSSEC to
  authorize requests and protect from exfiltration.

  > DNS ピアリングを提供するには、**Cloud DNS ピアリング ゾーン**を作成し、そのゾーンの名前空間のレコードが利用可能な VPC ネットワークで DNS ルックアップを行うように構成する必要があります。

  ※ **他のプロジェクトの**限定公開マネージド ゾーンにホストされている DNS レコードをもつ Cloud DNS コンテンツサーバーにクエリする必要がある場合は、**DNS ピアリング（ピアリングゾーン）**を使用する。⇔ 一方、**同じプロジェクト内の**VPC ネットワークからのみクエリする場合、**限定公開ゾーン**を使う。

  ※ 共有 VPC において、各サービス プロジェクトが、自身のサブネットの DNS 名前空間所有権を保持できる DNS ゾーンは**クロスプロジェクトバインディングゾーン**。責任範囲の分離と自律性が高まる。⇔ 一般的な共有 VPC 設定では、DNS ピアリングでピアリングゾーンを作成もできるが、DNS ピアリングだと VPC ネットワークとネットワーク インフラの所有権はサービス プロジェクトではなくホスト プロジェクトが所有する。

  ### VPC ピアリングとの関係性

  > • DNS ピアリングと  [VPC ネットワーク ピアリング](https://cloud.google.com/vpc/docs/vpc-peering)は異なるサービスです。DNS ピアリングは VPC ネットワーク ピアリングと組み合わせて使用できますが、VPC ネットワーク ピアリングは DNS ピアリングに必須ではありません。

  ⇒ VPC ピアリングをしなくても、DNS ピアリングはできる。

https://cloud.google.com/dns/docs/zones/zones-overview#peering_zones

### ※DNS Forwarding との違い

オンプレとのハイブリッドネットワークではお互いに DNS フォワーディングする「ハイブリッドアプローチ」が推奨されているが、DNS ピアリングは VPC 内部の話。以下の図が分かりやすい。
![Untitled](/images/20221219_professional-cloud-network-engineer/Untitled_shared.png)

https://cloud.google.com/blog/ja/products/networking/cloud-forwarding-peering-and-zones

---

- DNSSEC の概要

  > DNSSEC（Domain Name System Security Extensions）は、ドメイン名のルックアップに対するレスポンスを認証するドメイン ネーム システム（DNS）の機能です。これらのルックアップに対するプライバシー保護は行いませんが、DNS リクエストに対するレスポンスの改ざんや汚染を防ぎます。

  ⇒ ドメインなりすましやポイズニング攻撃から保護する

  ### 有効化

  > ゾーンに対して DNSSEC を有効にしたら、登録事業者で DNSSEC を有効にする必要があります。DNSSEC を有効にするには、ドメインの DS レコードを親ゾーンに作成します

  ⇒ ドメインが DNSSEC 対応であることをリゾルバが認識し、そのデータを検証。ゾーンを管理する DNS キャッシュサーバー（リゾルバ）に DNS クエリが来た際に、リゾルバが DS レコードを認識。

  ### 削除

  > To deactivate DNSSEC, you remove all DS records for your domain from the parent zone so that resolvers no longer try to use DNSSEC to validate your domain data

https://cloud.google.com/dns/docs/dnssec

---

- Cloud DNS に BIND zone file を移行するには？

  ### BIND zone file

  > ゾーンファイルとは、あるゾーンに関する情報がすべて記載されたファイルで、そのドメインの管理者によって作成されます。プライマリとなるコンテンツサーバによって読み込まれ、必要に応じて、セカンダリのネームサーバに転送されます。
  >
  > BIND ファイル・フォーマットは業界推奨のゾーン・ファイル・フォーマットであり、DNS サーバー・ソフトウェアによって広く採用されています。
  >
  > ヘッダには、そのゾーン自体の情報を記載します。ここには、SOA レコードから始まり、そのゾーンのオーソリティを持つネームサーバと、その他追加情報が入ります。
  >
  > 続いて、ゾーンに属するドメイン名のリソースレコードが必要なだけ記載されます。また、このゾーンからさらに委任しているサブドメインに関する情報も記載されます。

  ![Untitled](/images/20221219_professional-cloud-network-engineer/Untitled1.png)

  > この中で、「クラス」にはいくつかの種類が存在しますが、「IN」（Internet） 以外を利用することはまずありません。また、リソースデータはタイプの違いにより複数の値が必要な場合があります。例えば「SOA」なら 7 つの値が、「MX」ならば 2 つの値が必要になります。

  ### Cloud DNS への BIND zone file の移行

  > you can use the `gcloud dns record-sets import`
  >  command to import it into your managed zone. To import record-sets, you use the dns record-sets import command. The `--zone-file-format`
  >  flag tells import to expect a BIND zone formatted file. If you omit this flag, import expects a YAML-formatted records file.

---

- TCP window 制御とは？
  TCP 通信の 3way ハンドシェイク時、TCP ヘッダの**window フィールド**に、自分のメモリが何 Byte の通信を受け入れられるかを提示する。これは TCP ウィンドウサイズ（受信バッファサイズ）という。
  ウィンドウサイズに達するまでは Ack を待たずにデータを送信できる（＝**スライディングウィンドウ**）

  ⇒ ping などで、RTT(Round Trip Time)が 100ms など、遅い場合、サーバーの TCP パラメータの window size を大きくすることでパフォーマンスを向上させられる

  ![Untitled](/images/20221219_professional-cloud-network-engineer/Untitled2.png)

https://www.infraexpert.com/study/tcpip11.html

---

- Primary / Secondary IP address ranges とは?

  ### Subnet primary and secondary CIDR ranges

  > All [subnets](https://cloud.google.com/compute/docs/vpc) have a *primary CIDR range*, which is the range of internal IP addresses that define the subnet.

  →subnet は(primary)CIDR ブロックによって定義される！

  > Each VM instance gets its primary internal IP address from this range.

  →VM は primary CIDR ブロックの範囲から IP address が割り当てられる

  > You can also allocate **alias IP ranges** from that primary range, or you can add a secondary range to the subnet and allocate alias IP ranges from the secondary range.

  →VM には primary IP に加え、オプションで alias IP ranges を割り当てられる。(from primary or secondary CIDR range)

  > Using IP aliasing, you can configure multiple internal IP addresses, representing containers or applications hosted in a VM, without having to define a separate network interface. You can assign VM alias IP ranges from either the subnet's primary or secondary ranges.

  →alias IP ranges は、VM 内部でホストされたコンテナやアプリケーションサービスの IP アドレスの範囲を表す。

  ![Untitled](/images/20221219_professional-cloud-network-engineer/Untitled3.png)

https://cloud.google.com/vpc/docs/alias-ip

---

- CDN のパフォーマンスベストプラクティスについて
  Enable HTTP/3, QUIC protocol support, and negative caching to reduce the load on your backends.

  > Ensure that HTTP/3 and QUIC protocol support is enabled
  > To increase performance with Cloud CDN, ensure that HTTP/3 is enabled.
  > HTTP/3 is a next-generation internet protocol. It is built on top of QUIC, a protocol developed from the original Google QUIC ) (gQUIC) protocol. HTTP/3 is supported between the external HTTP(S) load balancer, Cloud CDN, and clients.

  Use negative caching

  > Negative caching provides fine-grained control over caching for common errors or redirects. When Cloud CDN encounters specific response codes, it holds that response in cache for a set TTL. This can reduce the load on your origins and improve the end-user experience by reducing response latency.

https://cloud.google.com/cdn/docs/best-practices?hl=en#optimize_performance

---

- Negative cache(**ネガティブキャッシュ**)
  「問い合わせたけど、そんなの知らないって言われた～」な情報をメモっておく、DNS サーバさんが見るカンペ

https://wa3.i-3-i.info/word12300.html

---

- CDN にキャッシュさせない方法は？
  > To prevent caching you must "include a **'Cache-Control: private'** header in responses that should not be stored in Cloud CDN caches, or a **Cache-Control: no-store** header in responses that should not be stored in any cache, even a web browser's cache."

https://cloud.google.com/cdn/docs/caching#preventing-caching

---

- CDN のデフォルトのキャッシュ時間は？
  The default time-to-live (TTL) for content caching is 3600 seconds (1 hour).

---

- Cloud CDN は GCS bucket で有効化できる？
  バケット単独では出来ない。Cloud CDN は global external HTTP(S) LB が必要。LB のバックエンドは様々なインスタンスタイプが可能（Compute Engine VM instances, Google Kubernetes Engine Pods, Cloud Storage buckets, or external backends outside of Google Cloud）。この中に GCS bucket もある。

https://cloud.google.com/cdn/docs/setting-up-cdn-with-bucket

---

- IPv6 のサービスを GCP で提供するには？

  > Global load balancing can also provide IPv6 termination.

  ⇒ Global LB を使って IPv6 終端する
  ※ You cannot assign Ipv6 ip to an internal LB

  > "Create the instance with the designated IPv6 address." - this is incorrect, with IPv6 global load balancing, you can build more scalable and resilient applications on GCP

  ⇒ 一応、VM 単位でも IPv6 は使える

---

- ターゲットプール（Target Pool）とは？インスタンスグループとの違いは？

  > A target pool is an object that contains one or more virtual machine instances. A target pool is used in Network Load Balancing, where the load balancer forwards user requests to the attached target pool.

  ⇒ LB のバックエンドサーバーでトラフィックを割り振る。Managed Instance Group（=Instance template を使う）と違い、バックエンドの VM が使っている Library とかが違っても大丈夫。

  > If you use target pool-based Network LB, then it's required to use legacy health check, otherwise, legacy health check is not recommended to be used for HTTP(S) LB.

  ⇒ Legacy health check が必要

---

- API Gateway vs Cloud Endpoints？

  > API Gateway is an improved version of Cloud Endpoints. API Gateway can manage APIs for multiple backends including Cloud Functions, Cloud Run, App Engine, Compute Engine and Google Kubernetes Engine.

  > **_The main difference_** under the hood it is that API gateway doesn't rely over Cloud run making more user friendly, fast and clean the implementation.
  > Both products, API gateway and Cloud endpoints support same Open API implementation.

---

- Partner Interconnect での、レイヤ 2/3 接続の違い？

  ### レイヤ 2

  > レイヤ 2 接続の場合は、作成する VLAN アタッチメントごとに、Cloud Router とオンプレミス ルーターの間の BGP セッションを構成して確立する必要があります。

  ![Untitled](/images/20221219_professional-cloud-network-engineer/Untitled4.png)

  ### レイヤ 3

  > レイヤ 3 接続の場合は、VLAN アタッチメントごとに、サービス プロバイダがお客様の Cloud Router とプロバイダのオンプレミス ルーターの間の BGP セッションを確立します。BGP をお客様のローカル ルーターで構成する必要はありません。Google とお客様のサービス プロバイダが正しい BGP 構成を自動的に設定します。

  ![Untitled](/images/20221219_professional-cloud-network-engineer/Untitled5.png)

https://cloud.google.com/network-connectivity/docs/interconnect/concepts/partner-overview#connectivity-type

---

- graceful restart of BGP device？
  > Enable **graceful restart** on your on-premises BGP device. With graceful restart, traffic between networks isn't disrupted in the event of a Cloud Router or on-premises BGP device failure as long as the BGP session is re-established within the graceful restart period.

https://cloud.google.com/network-connectivity/docs/router/concepts/best-practices

---

- VM に手動で SSH 認証鍵を追加する方法二つ？
  OS Login vs メタデータベースの SSH 認証鍵を使用する方法

  ### OS Login

  GCE の機能。OS Login 機能を有効化すると、VM は Google アカウントに関連付けられた SSH 認証鍵を受け入れることが、IAM によるログイン可否/sudo 権限の設定が出来る。

  ### メタデータベースの SSH

  OS Login を使用しない VM は、Compute Engine のプロジェクト/インスタンス のメタデータに SSH 認証鍵を保存できる。プロジェクト メタデータに保存された SSH 認証鍵を使用して、プロジェクト内のすべての VM にアクセスできる。インスタンス メタデータに保存された SSH 認証鍵を使用して、個々の VM にアクセスできる。

https://cloud.google.com/compute/docs/connect/add-ssh-keys#add_ssh_keys_to_project_metadata

※Google Cloud Console または Google Cloud CLI を使用して VM に接続すると、Compute Engine によって SSH 認証鍵が自動的に作成されるので、手動で追加する必要はない。スキップ可能

---

- VPC-native clusters と Routes-based clusters？デフォルトの Pod 数と CIDR？

  ### VPC-native clusters

  > VPC-Native means that the cluster uses alias IP address ranges. This results in the pods in the cluster being natively routable within the cluster's VPC network

  ⇒ つまりポッドにはプライマリアドレスだけでなく、その中で稼働している複数のサービスに対応するセカンダリ IP に natively にアクセスできる

  > The IPs of the pods are reserved in the VPC network before the pods are created in the cluster.

  > From Google, "With the default maximum of 110 Pods per node for Standard clusters, Kubernetes assigns a /24 CIDR block (256 addresses) to each of the nodes"

  ⇒ デフォルトの Pod 数は 110 ポッド/ノード、CIDR は/24 で 256 アドレス/ノード！！

https://cloud.google.com/kubernetes-engine/docs/how-to/flexible-pod-cidr#overview

⇒ なので、1 ノード毎に 256 アドレスの VPC サブネットを用意する必要がある。もし、3 ノードにスケールさせる場合、3×/24 CIDR block = /22 (1024 アドレス)を用意する必要ある。
⇒ Pod だけなら 3×110=330 なので、/23 で足りるはず。

### Routes-based cluster

こちらは古いらしく、VPC-native がメリット多いので、そちらが推奨されている。

> _routes-based cluster will not support the scalability needed to solve the problem because it does not let you use ranges outside RFC 1918_

### Routes-based vs VPC-native cluster : Use VPC-native clusters

> Before you create a cluster, you need to choose either a routes-based or VPC-native cluster. We recommend choosing a VPC-native cluster because they use alias IP address ranges on GKE nodes and scale more easily than routes-based clusters. VPC-native clusters are required for private GKE clusters and for creating clusters on Shared VPCs. For clusters created in the Autopilot mode, VPC-native mode is always on and cannot be turned off.
>
> **Note:** You cannot migrate between routes-based and VPC-native cluster types.
>
> VPC-native clusters scale more easily than routes-based clusters without consuming Google Cloud routes and so are less susceptible to hitting routing limits. The advantages to using VPC-native clusters go hand-in-hand with alias IP support. For example, network endpoint groups (NEGs) can only be used with secondary IP addresses, so they are only supported on VPC-native clusters.
> **Note:** VPC-native cluster in Autopilot has a pre-configured pod limit.

https://cloud.google.com/kubernetes-engine/docs/best-practices/networking#vpc-native-clusters

---

- GKE の VPC-native cluster 構築時に指定する３つの IP adress range について
  When you create a VPC-native cluster, you specify a subnet in a VPC network. The cluster uses three unique subnet IP address ranges:

  - It uses the subnet's primary IP address range for all node IP addresses.
  - It uses one secondary IP address range for all Pod IP addresses.
  - It uses another secondary IP address range for all Service (cluster IP) addresses.

  ### ex)

  ![Untitled](/images/20221219_professional-cloud-network-engineer/Untitled6.png)

https://cloud.google.com/kubernetes-engine/docs/concepts/alias-ips#cluster_sizing

https://future-architect.github.io/articles/20191017/

---

- RFC1918？
  プライベート IP アドレスについて記載した RFC(Request for Comments)文書＝インターネット技術仕様を公開している文書
  ### RFC 1918 ブロック
  - 10.0.0.0/8
  - 172.16.0.0/12
  - 192.168.0.0/16
  ### CIDR ブロック
  Classless Inter-Domain Routing（CIDR、サイダー）
  アドレスの集約的表現(＝ CIDR 記法)が可能で、アドレスブロック(CIDR ブロック)の委譲も容易である。1 つの IP アドレスは CIDR ブロックの一部であり、先頭の N ビットがその CIDR ブロックのプレフィックスと一致している。
  ルーターにおけるルーティングテーブルの肥大化速度を低減させるための機構。

---

- Network Admin/Security Role、ファイヤーウォールルールを設定できるのは、、

  - **Network Admin:** Permissions to create, modify, and delete networking resources, except for firewall rules and SSL certificates.
  - **Security Admin:** Permissions to create, modify, and delete \*\*\*\*firewall rules and SSL certificates.

  > The network admin role allows read-only access to firewall rules, SSL certificates, and instances (to view their ephemeral IP addresses). The network admin role does not allow a user to create, start, stop, or delete instances.

  ⇒ 読み取り権限は NetworkAdmin でも付与される。更新には SecurityAdmin が必要

---

- Private Service Access？Private Google Access との違い？
  例：CloudSQL

  > You require access to Cloud SQL instances from VPC instances with private IPs. Google and third parties (known as service producers) offer services with internal IP addresses hosted in an underlying VPC network. Cloud SQL is one of those Google services.

  > Private service access lets you create private connections between your VPC network and the underlying Google service producers' VPC network.

  > To use private service access, you must activate the service networking API in the project, then create a private connection to a service producer.

  ### Private Google Access との違い

  Private Google Access is not the same as private service access. Private Google access allows VM instances with internal IPs to reach the EXTERNAL IP addresses of Google APIs and Services.

  ⇔ VPC の INTERNAL IP へ（VM から）アクセスするのが Private Service Access。

---

- GKE private cluster にアクセスする方法は？
  デフォルトでは外部 IP を持たないので、kubectl で pod の状態を取得しようとしても、マスターが反応しない。_Authorized networks（承認済みネットワーク）を使う。_

  > Private clusters do not allow Google Cloud IP addresses to access the control-plane endpoint by default, causing the issue in question. Using Authorised networks in private clusters makes your control plane reachable only by allowing CIDRs, nodes, and pods within the VPC and Google's internal production jobs to manage your control plane.

  > 限定公開クラスタで承認済みネットワークを使用すると、次の方法でのみコントロール プレーンに到達可能になります。
  >
  > - Google Cloud 内のアドレス（Compute Engine 仮想マシン（VM）など）
  > - 許可された CIDR ブロック
  > - クラスタの VPC 内のノードと Pod
  > - Google がお客様のコントロール プレーンを管理するために本番環境で実行する内部ジョブ

https://cloud.google.com/kubernetes-engine/docs/how-to/authorized-networks#overview

---

- proxy header とは？Via header, X-Forwarded-xx header？
  > Proxy Headers are used to redirect requests, the question does not mention if the service is using proxying.
  ### via header
  プロキシは HTTP リクエストを転送する際に、Via ヘッダに自分の情報を追記（ヘッダが存在しない場合は作成して）する必要がある。
  **Note:** If responses served by Cloud CDN are not compressed but should be, check that the web server software running on your instances is configured to compress responses. By default, some web server software will automatically disable compression for requests that include a Via header.
  ### X-Forwarded-For
  プロキシ経由時、もともとのクライアントの IP がわからなくならないよう、HTTP ヘッダに元のクライアント IP の情報を乗せるときに使われるヘッダ
  クライアントの IP から始まり、あとはクライアント起点で経由したプロキシの IP をカンマ区切りで追記していく形式
  ```
  X-Forwarded-For: クライアントのIP, プロキシのIPその1, プロキシのIPその2 ...
  ```
  ### X-Forwarded-Proto
  **X-Forwarded-Proto** (XFP) ヘッダーは、プロキシーまたはロードバランサーへ接続するのに使っていたクライアントのプロトコル (HTTP または HTTPS) を特定するために事実上の標準となっているヘッダー
  ### X-Forwarded-Host
  **X-Forwarded-Host** (XFH) ヘッダーは、 HTTP の  `[Host](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Host)`  リクエストヘッダー内でクライアントから要求された元のホストを特定するための事実上の標準となっているヘッダー

---

- host header?
  Host  リクエストヘッダーは、リクエストが送信される先のサーバーのホスト名とポート番号を指定（Required）
  Client request:

  ```
   GET /hello.txt HTTP/1.1
   User-Agent: curl/7.16.3 libcurl/7.16.3 OpenSSL/0.9.7l zlib/1.2.3
   Host: www.example.com // ←ここが Hostヘッダフィールド
   Accept-Language: en, mi

  ```

  Server response:

  ```
   HTTP/1.1 200 OK
   Date: Mon, 27 Jul 2009 12:28:53 GMT
   Server: Apache
   Last-Modified: Wed, 22 Jul 2009 19:15:56 GMT
   ETag: "34aa387-d-1568eb00"
   Accept-Ranges: bytes
   Content-Length: 51
   Vary: Accept-Encoding
   Content-Type: text/plain

   Hello World! My payload includes a trailing CRLF.

  ```

---

- Content-Based Health Checks?

  > The best way to do this would be to use the content-based health check to more completely validate the backend's response by specifying an expected response string and optionally a request path.

  ⇒ LB のバックエンドサーバーのリクエストパスを指定（ヘルスチェック用のパス）し、レスポンスに期待する文字列を定義しておく

https://cloud.google.com/load-balancing/docs/health-check-concepts#content-based_health_checks
https://cloud.google.com/load-balancing/docs/health-checks#optional-flags-hc-protocol-http

---

- Cloud Router で ECMP が機能しない？
  ### ECMP（Equal Cost Multi Path）
  OSPF（Open Shortest Path First）におけるルーティングアルゴリズム。等コストの経路が複数存在するときに、トラフィックを振り分ける機能
  ⇒ 同じ ASN にルーターが複数あって、それぞれ Cloud Router と接続しているような場合、この ECMP によってトラフィックが振り分けられる！
  ⇒ 二つの Cloud Router を Active/Standby で使いたいような場合、MED 属性を使う。

https://www.notion.so/How-to-Set-up-two-Cloud-Routers-with-Active-Stanby-4765581359f943be84f13b6846af2c5e

⇔ 逆にオンプレのルーターが異なる ASN に設定されている場合、CloudRouter ではトラフィックが振り分けられずに、一つのルートだけを使ってしまう。

> Cloud Router doesn't use ECMP across routes with different origin ASNs. For cases where you have multiple on-premises routers connected to a single Cloud Router, the Cloud Router learns and propagates routes from the router with the lowest ASN. Cloud Router ignores advertised routes from routers with higher ASNs, which might result in unexpected behavior. For example, you might have two on-premises routers advertise routes that are using two different Cloud VPN tunnels. You expect traffic to be load balanced between the tunnels, but Google Cloud uses only one of the tunnels because Cloud Router only propagated routes from the on-premises router with the lower ASN.

https://cloud.google.com/network-connectivity/docs/router/support/troubleshooting#ecmp

**Note:** OSPF は Dedicated Interconnect の要件ではない。BGP は Dedicated Interconnect でも必要。VPN ではどっちも

> Open Shortest Path First (OSPF) is not a technical requirement because Dedicated Interconnect uses BGP, not OSPF.

---

- How to Set up two Cloud Routers with Active/Stanby ?

  > You can configure 2 different MED values for each BGP neighbor in your single on-prem router to influence GCPs to 2 separate routers to select which path they use to send traffic toward you. The lower MED value is preferred.

  ## **The MED Attribute (**Multi-exit Discriminator**)**

  > MED is an optional nontransitive attribute. MED is a hint to external neighbors about the preferred path into an autonomous system (AS) that has multiple entry points. The MED is also known as the external metric of a route. A lower MED value is preferred over a higher value.
  >
  > This section describes an example of how to use MED to influence the routing decision taken by a neighboring AS.

  ⇒ 同じ AS 内にある複数の BGP neighbor のうち、どちらを優先するかを選択するために設定するのが MED Attribute。MED が小さい経路が優先される。

  ![Untitled](/images/20221219_professional-cloud-network-engineer/Untitled7.png)

https://www.cisco.com/c/en/us/support/docs/ip/border-gateway-protocol-bgp/13759-37.html

> "AS-Path" - this is incorrect; AS path length selection does not work when Cloud Router is implemented by more than one software task. However, if Cloud Router is implemented by multiple software tasks, all prefixes advertised to Google Cloud by peer routers must use the same AS path length. This ensures that Google Cloud uses only MED to select the best routes.

**AS-PATH 属性とは**

> あるプレフィックスに到達するために通過すべき AS 番号の順序付きリストです。宛先に到達するために最短の AS パスの経路を優先します。AS パスを設定により付加（プリペンド）することで、AS-PATH を長く見せ、経路を操作することができます。

⇒ HA VPN で、オンプレの 2 つのルーターのうち一つしか使われない場合のトラブルシュートで、AS が異なるために小さい AS のルートが選択される、というのがある。おそらくそれと同じで、AS が異なると AS が小さい方のルーターしか使われないはず。でも、AS は同じにして、MED だけ異なるようにする、というのが正しいやり方らしい。

https://www.notion.so/Cloud-Router-ECMP-a092b01389ae4a95ba5f084e41655806

https://hirotanoblog.com/bgp-lists/

**Local Preference とは**

> 自律システムの出口パスを選択するために使用します。自律システム内のすべての内部 BGP ルータに送信され、外部 BGP ルータ間では交換されません。 同じプレフィックスに対して、値が高い方のパスが優先され、デフォルト値は 100 です。

---

- VPC auto mode で作られるネットワークの CIDR？VPC peering や VPN 接続するために custom mode でサブネットを作成する場合、衝突させない CIDR 範囲は？

  > When an auto mode VPC network is created, one subnet from each region is automatically created within it. These automatically created subnets use a set of predefined IPv4 ranges that fit within the **10.128.0.0/9** CIDR block. Therefore, must choose CIDR range of 10.0.0.0/9 to prevent overlap between both VPC's

  ⇒ Auto mode で VPC を作ると、CIDR が被る可能性があるので、peering や VPN で VPC をつなぐ場合、custom モードで作成し、10.0.0.0/9 の CIDR 範囲を選択するのが良い。

https://cloud.google.com/vpc/docs/vpc?hl=ja

---

- MTU とは？推奨 MTU to be configured on your peer VPN gateway?

  ### MTU (Maximum Transmission Unit)

  ネットワークで一回に送信できる最大のデータサイズのこと。MTU は物理媒体ごとに異なり、イーサネットの MTU は 1500 バイトで、光ファイバ（FDDI）は 4352 バイトとなる。
  MTU の値を超えたパケットを送信する場合、MTU に合わせてパケットを分割する。(IP フラグメンテーション)。ルータを経由する際に自動的に行われ、あて先ではすべてのフラグメント化されたパケットが揃うまで再構成を実行しない。
  TCP/IP の MTU の最小サイズは 576 バイトと、Ethernet よりも遥かに小さいサイズが設定されており、IP フラグメンテーションが発生する可能性は高い。
  `ping`コマンドなどで MTU サイズを事前に確認し、MTU の値を適切なサイズに設定することが望ましい。

  ### VPN ゲートウェイの MTU 設定

  > The MTU must not be greater than 1460 bytes.

  ⇒ Google Cloud 仮想マシン（VM）インスタンスのデフォルトの MTU 設定と一致するため、1,460 バイトの値を推奨。(IP フラグメンテーションの防止)

https://cloud.google.com/network-connectivity/docs/vpn/concepts/mtu-considerations#gateway_mtu_versus_system_mtu

※ TCP window の制御と似ている。どこが違うのか？

---

- NAT ゲートウェイを通るルートを作成し、特定の VM にルートを適用するには？

  > `gcloud compute routes create` is used to create routes. A route is a rule that specifies how certain packets should be handled by the virtual network. Routes are associated with virtual machine instances by tag, and the set of routes for a particular VM is called its routing table. For each packet leaving a virtual machine, the system searches that machine's routing table for a single best matching route.

  ⇒ このコマンドで VM のルートテーブルを追加できる。VM が通信するとき、IP パケットの宛先を見て、ベストマッチするルートの next-hop にパケットを送る。

  > `--tags`=**`TAG`**,[**`TAG`**,…]
  > Identifies the set of instances that this route will apply to. If no tags are provided, the route will apply to all instances in the network.
  >
  > If we want existing instances to use the new NAT gateway then we must add the tags to our existing instances.

  ⇒ 作成したルートを適用する VM インスタンスを tag で指定できる。
  ⇒--next-hop に NAT ゲートウェイを指定したルートをタグ付きで`routes create`したら、 同じネットワーク内の VM インスタンスにもタグ付けすれば、NAT を使うようになる

https://cloud.google.com/sdk/gcloud/reference/compute/routes/create

---

- Cloud NAT logging?

  > Cloud NAT ロギングを使用すると、NAT 接続とエラーをログに記録できます。Cloud NAT ロギングを有効にすると、次のシナリオごとに 1 つのログエントリを生成できます。
  >
  > - NAT を使用するネットワーク接続が作成された。
  > - NAT に使用可能なポートがないことが原因でパケットが破棄された。

  ⇒ それぞれ Translation logs, Errors logs というらしい

  > Translation logs show VMs that initiates a connection that is successfully allocated to a NAT IP and port and traverses to the internet. Errors logs show details of when the NAT gateway can't allocate a NAT IP and por due to port exhaustion

  ※ "Connection logs" や "NAT logs"などというものは存在しない。

  ちなみに Cloud NAT の特徴は NAT をおこなうゲートウェイが 通信経路上に存在せず、各 VM が自律分散的に NAT をおこなっている点。

  ![Untitled](/images/20221219_professional-cloud-network-engineer/Untitled8.png)

  そのため中間ノードのパフォーマンス上の制限や、可用性の問題などは原理的に発生しない。（スループットは各 VM のスループットに依存）
  一方、各 VM が自律分散的に NAT をおこなっており、外部 IP アドレスを共用しているため、送信元ポート番号が重複しないようにうまく割り当てる必要がある。デフォルトで Cloud NAT が動的に行うので、ユーザーとしてはあまり気にすることない。

https://medium.com/google-cloud-jp/cloud-nat-endpoint-independent-mapping-39d7eab3e83c

---

- Source IP を保持できる Global LB?
  TCP/SSL proxy LB でクライアント接続情報を保持するための PROXY プロトコルの設定をすること。デフォルトではクライアント IP とポートは保持されないが、PROXY プロトコルを追加で構成すると送信元 IP、ポート番号を含む追加ヘッダーをインスタンスへのリクエストに含められる。
  ※ L4 で動作する LB のうち、ネットワークロードバランサーはリージョナルのみ

https://www.notion.so/UDP-protocol-UDP-584dc497cce24c17a2f3697a740ee764

https://cloud.google.com/load-balancing/docs/tcp/setting-up-tcp#proxy-protocol

---

- UDP protocol の例？UDP に対応したロードバランサは？
  L4 で動作する LB の内、TCP のみ使えるのが TCP Proxy LB と SSL Proxy LB。UDP も使えるのが、外部 Network LB と内部 Netwrork LB。UDP 使えるのはネットワークロードバランサーのみ。
  ※ L4 で動作する LB のうち、ネットワークロードバランサーはリージョナルのみ
  ※ L4 で動作する LB のうち、TCP/SSL proxy LB では PROXY プロトコルの設定をすることでクライアント接続情報を保持する。

  ### UDP の例

  1. TFTP ( **T**rivial **F**ile **T**ransfer **P**rotocol ) is a UDP-based protocol. Servers listen on port 69 for the initial client to-server packet to establish the TFTP session, then use a port above 1023 for all further packets during that session. Clients use ports above 1023

     ⇒ FTP は TCP プロトコルだが、認証をなくす代わりに高速な UDP プロトコルを使うのが TFTP。

  2. VoIP applications use UDP

---

- VM に静的内部アドレスを割り当てる？

  > リソースのエフェメラル内部 IP アドレスを静的内部 IP に昇格させることは可能で、その場合はリソースが削除された後もアドレスの予約状態は継続されます。

  ⇔ すでに割り当てられたアドレスを静的に固定はできるが、実行中の VM に静的アドレスを割当てることはできない。（割当済みの内部 IP を変更できない）

---

- NetworkPolicy？

  > Network Policy is used to restrict pod and namespace communications in GKE

  NetworkPolicy は、k8s で IP アドレスもしくはポートレベルでトラフィックを制御するリソース（kind: NetworkPolicy）。

  - Pod
  - Namespace
  - IP アドレス
    の組み合わせでトラフィックを制御

    ⇒ K8S での Pod 間のトラフィック制御はファイヤーウォールルールではなくこれ！

---

- VPN トンネルのルーティング オプション？静的ルーティングはいつ使う？静的ルーティングの種類？トラフィックセレクタ・IKE？

  ### 動的（BGP）ルーティング

  > 動的ルーティングでは、Cloud Router  を使用し、BGP によってルート交換を自動的に管理します。Cloud VPN トンネルと同じリージョンにある Cloud Router の BGP インターフェースによって自動的にルートの追加削除が行われ、トンネルの削除と再作成は必要ありません。
  >
  > VPC ネットワークの動的ルーティング モードにより、そのネットワークにあるすべての Cloud Router の動作が制御されます。

  ⇒ VPC の動的ルーティングモードを on にしておけば、VPN ゲートウェイのルート交換も勝手にやってくれる。

  ※ オンプレの VPN ゲートウェイでも BGP プロトコルに対応している必要がある。BGP に対応していない場合、以下の静的ルーディングオプションを使うはず

  ### 静的ルーティング

  GCP で静的ルーティングの VPN トンネルを作ると「Classic VPN」というリソースができるみたい。

  **ポリシーベース**
  VPN トンネル作成時にローカル IP 範囲とリモート IP 範囲を定義する。

  > ポリシーベースのトンネルを作成すると、Classic VPN は次のタスクを実行します。
  >
  > 1. トンネルのローカル トラフィック セレクタを、指定する IP 範囲に設定します。
  > 2. トンネルのリモート トラフィック セレクタを [**リモート ネットワーク IP の範囲**] フィールドに指定する IP 範囲に設定します。
  > 3. 宛先（接頭辞）が範囲内の CIDR であり、ネクストホップがトンネルであるカスタム静的ルートを Google Cloud が作成します。

  ⇒ 上記の 1,2 が VPN トンネルの作成(VPN ゲートウェイ)、3 が静的ルートの作成(CloudRouter)

  **ルートベース**

  > 1. VPN トンネル作成時にリモート IP 範囲のリストのみを指定する。
  > 2. ルートベースのトンネルを作成すると、Classic VPN は次のタスクを実行します。
  > 3. トンネルのローカルとリモートのトラフィック セレクタを任意の IP アドレス（`0.0.0.0/0`）に設定します。
  > 4. [**リモート ネットワーク IP の範囲**] の各範囲に対して、宛先（接頭辞）が範囲内の CIDR であり、ネクストホップがトンネルであるカスタム静的ルートを Google Cloud が作成します。

  ![Untitled](/images/20221219_professional-cloud-network-engineer/Untitled9.png)

  ※ トラフィックセレクタ

  > VPN トンネルを確立するために使用される一連の IP アドレス範囲または CIDR ブロックを定義。「暗号化ドメイン」とも呼ばれる。IKE handshake を確立するために使用される VPN トンネルの本質的な部分。ローカルまたはリモートのいずれかの CIDR を変更する必要がある場合は、Cloud VPN トンネルと、それに対応するピアのトンネルを破棄して再作成する必要

  ※ IKE

  > IPSec では、認証・暗号化などのセキュリティ機構を提供する SA(Security Association)が提供される。認証と暗号化に必要な SA のキー情報の管理をキー管理といい、IKE (インターネットキー交換) プロトコルにより、キー管理が自動的に行われる。

https://www.infraeye.com/study/juniperssg21.html
https://learn.microsoft.com/ja-jp/azure/vpn-gateway/vpn-gateway-connect-multiple-policybased-rm-ps
https://cloud.google.com/network-connectivity/docs/vpn/how-to/creating-static-vpns#routing_options

---

- NEG とは？Instance Group との違い？
  ネットワークエンドポイントグループ
  基本的に、GKE クラスタでのサービスをコンテナにデプロイするときのユースケースらしい。Network Endpoint というのは IP:Port で一意に表されるエンドポイントで、Pod に相当、NEG は Service に相当。
  > 前述したように NEG は  GCP のリソースとして定義されているものなので、NEG の操作を行うには  `gcloud compute network-endpoint-groups`  コマンドなどで GCP の API を叩く必要がありますが、GKE の場合は Service に  `cloud.google.com/neg`  から始まる annotation を付けてあげるだけで、Kubernetes の Service を作った時に NEG が作られたり、Pod が作られた時に Network Endpoint が作られるように制御することが可能になっています。

https://miro.medium.com/max/1362/0*TpTSrhpoUxnCd8j6

https://medium.com/google-cloud-jp/neg-%E3%81%A8%E3%81%AF%E4%BD%95%E3%81%8B-cc1e2bbc979e

### Google のドキュメントでの説明

NEG の種類

- [ゾーン NEG](https://cloud.google.com/load-balancing/docs/negs?hl=ja#zonal-neg)
- [インターネット NEG](https://cloud.google.com/load-balancing/docs/negs?hl=ja#internet-neg)
- [サーバーレス NEG](https://cloud.google.com/load-balancing/docs/negs?hl=ja#serverless-neg)
- [ハイブリッド接続 NEG](https://cloud.google.com/load-balancing/docs/negs?hl=ja#hybrid-neg)
- [Private Service Connect NEG](https://cloud.google.com/load-balancing/docs/negs?hl=ja#psc-neg)
  [ネットワーク エンドポイント グループの概要 | 負荷分散 | Google Cloud](https://cloud.google.com/load-balancing/docs/negs?hl=ja)

### Instance Group との違いは？

> 従来の負荷分散では、 **Instance Group (IG)**  を利用していました。IG を利用した場合のネットワークパケットは以下のような経路で転送されます。
>
> 1. Load Balancer へリクエスト
> 2. Load Balancer から VM Instance ( K8S Node ) に対して転送
> 3. K8S Node 内の iptables で Pod へ転送
>
> ここで、 **3**  の転送処理は自分の Node 内で稼働している Pod だけでなく、 **別 Node の Pod へも転送される可能性がある**  という点に注意が必要です。
>
> iptables をホップする分、また別 Node の Pod へも転送される可能性がある分、ロスがあります。
> NEG を利用する場合、Ingress リソースを生成したときに GCP に作られる Load Balancer が  **Container Native Load Balancing**  という手法で Pod に対してリクエストを分散するようになります。
>
> *(どういう仕組なのかわかりませんが)* Load Balancer は直接 Pod の持つ IP:Port に対してパケットを転送します。
>
> 転送効率が良いというわけです。

https://genzouw.com/entry/2021/05/20/160245/2613/#

※ 普通の VM だと、Managed instance group, Unmanaged instance group, Target pool などがあるが、GKE の文脈では NEG を使った Container Native Load Balancing が使われるぽい。

https://www.notion.so/Target-Pool-e5f21a1ad77947ea85ba993c9a4d9661

---

- 2 つの NIC を持つ VM について
  各インターフェースは、異なる VPC に接続する必要！

https://cloud.google.com/vpc/docs/create-use-multiple-interfaces

---

- プライベートサービスアクセス

  ![Untitled](/images/20221219_professional-cloud-network-engineer/Untitled10.png)

https://cloud.google.com/sql/docs/mysql/private-ip

To enable Private Services Access (enable service networking API)

https://cloud.google.com/service-infrastructure/docs/enabling-private-services-access

## 用語

---

- オリジンサーバー
  オリジナルのコンテンツが存在する Web サーバーのこと。
  自社ページなどを公開する際に、ページを配置したサーバに直接アクセスさせるのではなく WAF や CDN などのサービスを経由させてアクセスさせるネットワーク構成としたときに、WAF や CDN から見た接続先となるサーバをオリジンサーバと呼ぶ。
  CDN を利用した場合、エンドユーザーはオリジンサーバーにアクセスするのではなく、CDN のサーバ（**エッジサーバー**）にアクセスする。

https://support.cdnext.stream.co.jp/hc/ja/articles/360001787832-%E3%82%AA%E3%83%AA%E3%82%B8%E3%83%B3%E3%82%B5%E3%83%BC%E3%83%90%E3%83%BC%E3%81%A8%E3%81%AF%E3%81%AA%E3%82%93%E3%81%A7%E3%81%99%E3%81%8B-

- 単一テナントノード
  英語で  **sole-tenant node**
  通常、クラウド事業者の物理サーバーは仮想化されて複数の顧客によって共有して使われているが、専有できるのが単一テナントノード。セキュリティやコンプライアンス面で厳しい要件が課されているプロジェクトで使われる。

- RTT

  - RTT 【Round-Trip Time】 ラウンドトリップタイム
    通信相手に信号やデータを発信してから、応答が帰ってくるまでにかかる時間

    $$ RTT=レイテンシ ×2 + 相手方での処理時間 $$

  - レイテンシ（latency/遅延時間）
    発信した信号やデータが相手に届く（あるいはその逆）までにかかる時間
  - レスポンスタイム（response time/応答時間）
    システムの応答や反応にかかる時間を表す場合、入力が完了してから出力が始まるまでの時間
