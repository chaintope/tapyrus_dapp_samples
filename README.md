# README

2022 年に実施の B3 のワークショップで用いるサンプルコード

# 起動手順

## 1. TapyrusAPI の準備

以下の 2 つの設定ファイルを配置してください。

階層は以下のようになります。

```
- workshop202207
|-- app
|-- bin
|-- config
....
|-- access_token.txt
|-- tapyrus_api_client.pem
```

### 1.1. アクセストークン

Google ドライブで共有する `access_token.txt` を `workshop202207` ディレクトリに置きます。

TapyrusAPI のアクセストークンはそれぞれのウォレットを識別する情報であり、また API 利用のための認証情報でもあります。

### 1.2. クライアント証明書

Google ドライブで共有する `tapyrus_api_client.pem` を `workshop202207` ディレクトリに置きます。

TapyrusAPI のクライアント証明書は API 利用のための認証情報になります。

### 1.3. TapyrusAPI エンドポイント

`lib/utils/tapyrus_api.rb` の 2 行目にある `TAPYRUS_API_ENDPOINT_URL = 'ここにURLを記入してください'` の部分に TapyrusAPI エンドポイントの URL を書いてください。

## 2. 実行環境を起動する

Docker で用意された環境を起動します。

### 2.1. データベースを作成する

初回起動時はデータベースがないため作成する必要があります。
以下のコマンドを実行しデータベースを作成します。

workshop202207 フォルダに移動して、以下のコマンドを実行してください。

```
docker compose run --rm web bin/rails db:create
```

### 2.2. アプリケーションを起動する

workshop202207 フォルダに移動して、以下のコマンドを実行してください。

```
docker compose up --build
```

アプリケーションを起動すると、そのターミナル上にはアプリケーションのログが表示されます。

以降の作業でコマンドを実行する場合は新しいターミナルを起動して実行してください。

### 2.3. Docker コンテナとデータベースを削除する

Docker コンテナで作成されたデータを削除できます。

TapyrusAPI を使ってブロックチェーンに書き込んだトランザクションは消えません。

```
docker compose down -v --remove-orphans
```

# ワーク

## 1. TapyrusAPI を使ってみよう

あらかじめ Rake タスクを定義しています。

Rake タスクを実行して TapyrusAPI を実行できるようにしてみましょう。

1. TapyrusAPIへの接続を確認する

まずは、TapyrusAPIに接続できるかを確認します。以下のコマンドを実行して、addressの一覧を取得してみましょう。
```bash
docker compose exec web bin/rails api:get_addresses
```

最初はアドレスが存在していないため、以下のような結果が表示されます。
すでにアドレスを発行済みの場合は、アドレスの一覧が表示されます。
```ruby
{:count=>0, :addresses=>[]}
```

コマンド実行時に、エラーメッセージが表示される場合は、TapyrusAPIへのURLの設定、もしくはクライアント証明書の配置が正しくない可能性があるので、設定内容を見直してください。

2. アドレスを作成する

以下のコマンドでアドレスを作成できるように実装してみましょう。

```bash
docker compose exec web bin/rails api:post_addresses
```

このコマンドで実行されるのは `lib/tasks/api.rake` の 13 行目です。この中で`TapyrusApi.post_addresses(purpose: purpose)`を呼び出しています。`TapyrusApi` は `lib/utils/tapyrus_api.rb` に定義されています。

しかし、この `TapyrusApi` クラスの `post_addresses` メソッドは中身がありませんので次のように実装します。

編集する対象のファイルは `lib/utils/tapyrus_api.rb` です。

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

TapyrusAPIはREST APIなので、最初の `res = instance.connection.post("/api/v1/addresses") do |req|` でTapyrusAPIのアドレス発行のエンドポイントを呼び出しています。

次の行の `req.headers['Authorization'] = "Bearer #{instance.access_token}"` はTapyrusAPIへアクセスするためのアクセストークンを指定しています。

TapyrusAPIではアクセストークン毎にwalletが作成されていますので、これはアドレスを新規作成する対象のwalletを指定していることでもあります。

次の２行では、アドレス新規作成のエンドポイントに必要なパラメータを指定しています。
```ruby
    req.headers['Content-Type'] = 'application/json'
    req.body = JSON.generate({ "purpose" => purpose })
```

これらのコードは、TapyrusAPIの次の機能を呼び出しています。
https://doc.api.tapyrus.chaintope.com/#tag/address/operation/createAddress


これでアドレスを新規作成できるようになりました。以下のコマンドを実行してアドレスを作成しましょう。

```bash
docker compose exec web bin/rails api:post_addresses
```

実行結果として以下のように、新規発行されたアドレスが表示されれば正しく実装されています。

```bash
"13aV8XCYZDQvPFEDFoYrE69qizYWJpPrpT"
```


3トークンを新規発行する

以下のコマンドでトークンを発行できるように実装してみましょう。

```bash
docker compose exec web bin/rails api:post_tokens_issue'[100,1,10]'
```

このコマンドで実行されるのは `lib/tasks/api.rake` の 29 行目です。この中で`TapyrusApi.post_tokens_issue(amount: amount, token_type: token_type, split: split)`を呼び出しています。

先ほどと同様にメソッドの中身がありませんので実装しましょう。

編集する対象のファイルは `lib/utils/tapyrus_api.rb` です。

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


これらのコードは、先程と同様にTapyrusAPIのトークン新規発行機能を呼び出すものです。
https://doc.api.tapyrus.chaintope.com/#tag/token/operation/issueToken

ドキュメントにも記載がある通り、TapyrusAPIでは以下の3種類のトークンが発行可能です。

1. 再発行可能なトークン
2. 再発行不可能なトークン
3. NFT

今回は、token_typeに1を指定して、再発行可能なトークンを発行します。
それでは、以下のコマンドを実行してトークンを発行しましょう。

```bash
docker compose exec web bin/rails api:post_tokens_issue'[100,1,10]'
```

実行結果として以下のように、新規発行されたトークンのIDとトークン新規発行のために発行されたtransactionのidが表示されれば、正しく実装できています。

```ruby
{:token_id=>"c154fb27bbb2c91c1eec9357032cf029e0bf6257b429a427d5587504b3c85ca11c", :txid=>"a3d9c914655707240cb80757b7a377f8f741d6455bc4f6baba2645d49ff1edb0"}
```

このトークンは、再発行が可能なのでTapyrusAPIのトークンの再発行機能を呼び出すことで、追加発行が可能です。
https://doc.api.tapyrus.chaintope.com/#tag/token/operation/reissueToken

token_typeに2を指定すると、再発行不可能なトークンとなるため、総量が固定され追加発行はできなくなります。

token_typeを3にするとNFTとなるため、トークンの発行数は常に1になります。


4トークンを送付する

以下のコマンドでトークンを送付できるように実装してみましょう。

```bash
docker compose exec web bin/rails api:put_tokens_transfer'[<token_id>,<address>,<amount>]'
```

このコマンドで実行されるのは `lib/tasks/api.rake` の 44 行目です。この中で`TapyrusApi.put_tokens_transfer(token_id, address: address, amount: amount)`を呼び出しています。

先ほどと同様にメソッドの中身がありませんので実装しましょう。

編集する対象のファイルは `lib/utils/tapyrus_api.rb` です。

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

これらのコードは、先程と同様にTapyrusAPIのトークンの送付機能を呼び出すものです。
https://doc.api.tapyrus.chaintope.com/#tag/token/operation/transferToken

4行目の、`req.body = JSON.generate({ "address" => address, "amount" => amount })` で、トークンを送付する相手のaddressと、送付する数量をパラメータに指定しています。

これでコマンドが実行できるようになりました。以下のコマンドを実行してトークンを発行しましょう。
`<token_id>` は 2. で発行したトークンの `token_id` を、 `<address>` は 1. で作成した自分もしくは他人のアドレスを、 `<amount>` は 2. で発行したトークンの量 (100) 以下の値を指定します。

例えば、送付するトークンのIDが`c154fb27bbb2c91c1eec9357032cf029e0bf6257b429a427d5587504b3c85ca11c`、送付先のアドレスが `13aV8XCYZDQvPFEDFoYrE69qizYWJpPrpT`、送付する数量が50の場合は以下のコマンドになります。

```bash
docker compose exec web bin/rails api:put_tokens_transfer'[c154fb27bbb2c91c1eec9357032cf029e0bf6257b429a427d5587504b3c85ca11c,13aV8XCYZDQvPFEDFoYrE69qizYWJpPrpT,50]'
```

実行結果として以下のように、新規発行されたトークンのIDとトークンを送付するtransactionのidが表示されれば、正しく実装できています。
```ruby
{:token_id=>"c154fb27bbb2c91c1eec9357032cf029e0bf6257b429a427d5587504b3c85ca11c", :txid=>"33ed4f17ea85746256225eaaebd7d7d7c45337bfc80081b01cb9a2af4da5672a"}
```

5トークンを確認する

以下のコマンドでトークンを確認できるように実装してみましょう。

```bash
docker compose exec web bin/rails api:get_tokens
```

このコマンドで実行されるのは `lib/tasks/api.rake` の 21 行目です。この中で`TapyrusApi.get_tokens(confirmation_only)`を呼び出しています。

先ほどと同様にメソッドの中身がありませんので実装しましょう。

```ruby
def get_tokens(confirmation_only = true)
  res = instance.connection.get("/api/v1/tokens") do |req|
    req.headers['Authorization'] = "Bearer #{instance.access_token}"
    req.params['confirmation_only'] = confirmation_only
  end

  res.body
end
```

これらのコードは、TapyrusAPIのトークンの総量取得機能を呼び出すものです。
https://doc.api.tapyrus.chaintope.com/#tag/token/operation/getTokens

これでコマンドが実行できるようになりました。以下のコマンドを実行してトークンを確認しましょう。
自分のアドレスに送付した人は、発行時と変わらないと思いますが、他人のアドレスに送付した人は自分が発行したトークンが減少しています。
また、他の人からトークンを送付された人は自分が発行したものとは別のトークンが確認できます。

```bash
docker compose exec web bin/rails api:get_tokens
```

以下のように、所持しているトークンのIDと総量が表示されれば、正しく実装できています。
```ruby
[{:token_id=>"c154fb27bbb2c91c1eec9357032cf029e0bf6257b429a427d5587504b3c85ca11c", :amount=>100}]
```

もちろんトークンを複数種類発行したり、他の人から受け取っていた場合は、その種類分のトークンが表示されます。
