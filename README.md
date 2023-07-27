# README

B3 のワークショップで用いるサンプルコード

# 起動手順

## 1. TapyrusAPI の準備

クライアント証明書のPKCS12ファイルを配置します。
階層は以下のようになります。

```
- workshop
|-- app
|-- bin
|-- config
....
|-- tapyrus_api_client_cert.p12
```
### 1.1. クライアント証明書

Google ドライブで共有する `tapyrus_api_client_cert.p12` を `workshop` ディレクトリに置きます。

TapyrusAPI のクライアント証明書は API 利用のための認証情報になります。

### 1.2. アクセストークン

`lib/utils/tapyrus_api.rb` の 2 行目にある `ACCESS_TOKEN = 'ここにアクセストークンを記入してください'` の部分に 教えてもらったアクセストークンを書いてください。

TapyrusAPI のアクセストークンはそれぞれのウォレットを識別する情報であり、また API 利用のための認証情報でもあります。

### 1.3. TapyrusAPI エンドポイント

`lib/utils/tapyrus_api.rb` の 3 行目にある `TAPYRUS_API_ENDPOINT_URL = 'ここにURLを記入してください'` の部分に TapyrusAPI エンドポイントの URL を以下のように書いてください。 
エンドポイントは当日Discord、Zoom等でお知らせします。

```ruby
TAPYRUS_API_ENDPOINT_URL = "https://yzjwv84b.api.tapyrus.chaintope.com"
```

## 2. Web App を起動する

Docker で用意された環境を起動します。

### 2.1. データベースを作成する

初回起動時はデータベースがないため作成する必要があります。
以下のコマンドを実行しデータベースを作成します。

```
docker compose run --rm web bin/rails db:create
```

### 2.2. アプリケーションを起動する

```
docker compose up -d --build
```

起動したら `http://localhost:3000` にアクセスすることでアプリケーションを使用できます。

### 2.3. Docker コンテナとデータベースを削除する

このコマンドは環境を再構築したい場合に実行してください。
Dockerのコンテナなど構築した環境を全て削除します。

なお、TapyrusAPI を使ってブロックチェーンに書き込んだトランザクションは消えません。

```
docker compose down -v --remove-orphans
```

# ワーク

このワークでは、独自のトークンを作成しそれを誰かに送付することを行います。
`http://localhost:3000/tokens`で表示される画面の機能を実装していきます。

## 1. トークンの新規作成と送付

### 1.1. 保持トークンの一覧表示

最初は、自分が保有しているトークンを表示できるようにします。そのために、`TapyrusAPI`のトークンの総量取得 API を実装しましょう。`TapyrusApi` クラスの `get_tokens` メソッドを実装します。

以下の通り実装することで、TapyrusAPI のトークンの総量取得 API を実行できます。

編集対象のファイルは `lib/utils/tapyrus_api.rb` です。

```ruby
def get_tokens(confirmation_only = true)
  res = instance.connection.get("/api/v1/tokens") do |req|
    req.headers['Authorization'] = "Bearer #{instance.access_token}"
    req.params['confirmation_only'] = confirmation_only
  end

  res.body
end
```

これらのコードは、TapyrusAPI の次の機能を呼び出しています。 https://doc.api.tapyrus.chaintope.com/#tag/token/operation/getTokens
 
実装が完了したら、 http://localhost:3000/tokens にアクセスしてみましょう。現在保有しているトークンと、保有量が表示されます。前回のハンズオンで作成したトークンが表示されると思います。

### 1.2. トークンの新規発行

続いて、トークンの新規発行 API を実装しましょう。

トークンの新規発行も TapyrusAPI を使うことで簡単に行えます。
`TapyrusApi` クラスの `post_tokens_issue` メソッドを以下の通り実装することで、TapyrusAPI のトークンの新規発行 API を実行できます。

編集対象のファイルは `lib/utils/tapyrus_api.rb` です。

```ruby
def post_tokens_issue(amount:, token_type: 1, split: 1)
  res = instance.connection.post("/api/v1/tokens/issue") do |req|
    req.headers['Authorization'] = "Bearer #{instance.access_token}"
    req.headers['Content-Type'] = 'application/json'
    req.body = JSON.generate({ "amount" => amount, "token_type" => token_type, "split" => split })
  end

  res.body
end
```

TapyrusAPI は REST API なので、最初の `res = instance.connection.post("/api/v1/tokens/issue") do |req|` で TapyrusAPI のトークンの新規発行のエンドポイントを呼び出しています。

次の行の `req.headers['Authorization'] = "Bearer #{instance.access_token}"` は TapyrusAPI へアクセスするためのアクセストークンを指定しています。

TapyrusAPI ではアクセストークン毎に wallet が作成されていますので、これはトークンを新規発行する対象の wallet を指定していることでもあります。

次の２行では、トークンの新規発行のエンドポイントに必要なパラメータを指定しています。

```ruby
    req.headers['Content-Type'] = 'application/json'
    req.body = JSON.generate({ "amount" => amount, "token_type" => token_type, "split" => split })
```

これらのコードは、TapyrusAPI の次の機能を呼び出しています。 https://doc.api.tapyrus.chaintope.com/#tag/token/operation/issueToken

ドキュメントにも記載がある通り、TapyrusAPI では以下の 3 種類のトークンが発行可能です。

1. 再発行可能なトークン
2. 再発行不可能なトークン
3. NFT

実装したら早速ブラウザで確認します。

http://localhost:3000/tokens/new にアクセスします。

今回は、再発行可能トークンを 100 発行します。次の通り指定して実行しましょう。
`Amount` には `100` を、 `Token Type` には `再発行可能トークン` を、 `Split` には `10` を入力して `BCに記録` を押してみましょう。

しばらく（約20分ほど）するとトークンが新規発行され、トークン一覧画面( http://localhost:3000/tokens )に表示されます。

### 1.3. アドレス一覧の表示

作成したトークンを早速送付したいのですが、トークンを送付するためには受け取りアドレスが必要です。
なので、次はアドレス一覧の表示及び、新規作成機能を実装します。

まずはアドレス一覧の表示機能から実装します。
http://localhost:3000/wallets でアドレスの一覧が表示されるように実装します。
`TapyrusApi` クラスの `get_addresses` メソッドを実装することで該当画面にアドレス一覧が表示されるようになります。

以下のコードを実装して下さい。

```ruby
def get_addresses(per: 25, page: 1, purpose: "general")
  res = instance.connection.get("/api/v1/addresses") do |req|
    req.headers['Authorization'] = "Bearer #{instance.access_token}"
    req.params['per'] = per
    req.params['page'] = page
    req.params['purpose'] = purpose
  end

  res.body
end
```

これらのコードは、TapyrusAPI の次の機能を呼び出しています。
https://doc.api.tapyrus.chaintope.com/#tag/address/operation/getAddresses

実装が完了したら、http://localhost:3000/wallets にアクセスしてみましょう。
自分のwalletで管理しているアドレスの一覧が表示されます。

### 1.4. アドレスの新規作成

続いてアドレスの新規作成機能を実装します。walletを初めて使用するときはまだアドレスが存在していません。
また、用途に応じてアドレスを使い分けたい場合もあると思います。

アドレスの新規作成機能を追加するために、`TapyrusApi` クラスの `post_addresses` メソッドを実装しましょう。

以下の通り実装することで、TapyrusAPI のアドレスの生成 API を実行できます。

```ruby
def post_addresses(purpose: "general")
  res = instance.connection.post("/api/v1/addresses") do |req|
    req.headers['Authorization'] = "Bearer #{instance.access_token}"
    req.headers['Content-Type'] = 'application/json'
    req.body = JSON.generate({ "purpose" => purpose })
  end

  res.body
end
```

これらのコードは、TapyrusAPI の次の機能を呼び出しています。 https://doc.api.tapyrus.chaintope.com/#tag/address/operation/createAddress

`アドレス作成` を押すと 1 つアドレスが新規に作成されます。
このアドレスをトークンの送り主に教えましょう。

### 1.5 トークンの送付

最後に作成したトークンを誰かに送ってみましょう。

`TapyrusApi` クラスの `put_tokens_transfer` メソッドを実装しましょう。
以下の通り実装することで、TapyrusAPI のトークンの送付 API を実行できます。

編集対象のファイルは `lib/utils/tapyrus_api.rb` です。

```ruby
def put_tokens_transfer(token_id, address:, amount:)
  res = instance.connection.put("/api/v1/tokens/#{token_id}/transfer") do |req|
    req.headers['Authorization'] = "Bearer #{instance.access_token}"
    req.headers['Content-Type'] = 'application/json'
    req.body = JSON.generate({ "address" => address, "amount" => amount })
  end

  res.body
end
```

これらのコードは、TapyrusAPI の次の機能を呼び出しています。 https://doc.api.tapyrus.chaintope.com/#tag/token/operation/transferToken

実装が完了したら、実際に誰かにトークンを送ってみましょう。

http://localhost:3000/tokens/transfer にアクセスします。

自分が所有している送りたいトークンの `Token Id` を指定し、送り先の `Address` と送付量 `Amount` を入力して `BCに記録` しましょう。

トークンの送付はできましたか？

最後に、誰かから送られてきたトークンがどれだけあるのか確認したいですよね。

http://localhost:3000/tokens にアクセスして確認してみましょう。

いかがでしたか？

自分で作成したトークン以外のトークンが表示されましたか？

以上でトークンの送付と確認のワークは終了になります。

