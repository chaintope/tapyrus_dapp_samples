# Work1 スクリプトの作成

## 1. TapyrusAPI を使ってみよう

あらかじめ Rake タスクを定義しています。

Rake タスクを実行して TapyrusAPI を実行できるようにしてみましょう。

### 1. TapyrusAPI への接続を確認する

まずは、TapyrusAPI に接続できるかを確認します。以下のコマンドを実行して、address の一覧を取得してみましょう。

```bash
docker compose exec web bin/rails api:get_addresses
```

最初はアドレスが存在していないため、以下のような結果が表示されます。
すでにアドレスを発行済みの場合は、アドレスの一覧が表示されます。

```ruby
{:count=>0, :addresses=>[]}
```

コマンド実行時に、エラーメッセージが表示される場合は、TapyrusAPI への URL の設定、もしくはクライアント証明書の配置が正しくない可能性があるので、設定内容を見直してください。

### 2. アドレスを作成する

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

TapyrusAPI は REST API なので、最初の `res = instance.connection.post("/api/v1/addresses") do |req|` で TapyrusAPI のアドレス発行のエンドポイントを呼び出しています。

次の行の `req.headers['Authorization'] = "Bearer #{instance.access_token}"` は TapyrusAPI へアクセスするためのアクセストークンを指定しています。

TapyrusAPI ではアクセストークン毎に wallet が作成されていますので、これはアドレスを新規作成する対象の wallet を指定していることでもあります。

次の２行では、アドレス新規作成のエンドポイントに必要なパラメータを指定しています。

```ruby
    req.headers['Content-Type'] = 'application/json'
    req.body = JSON.generate({ "purpose" => purpose })
```

これらのコードは、TapyrusAPI の次の機能を呼び出しています。
https://doc.api.tapyrus.chaintope.com/#tag/address/operation/createAddress

これでアドレスを新規作成できるようになりました。以下のコマンドを実行してアドレスを作成しましょう。

```bash
docker compose exec web bin/rails api:post_addresses
```

実行結果として以下のように、新規発行されたアドレスが表示されれば正しく実装されています。

```bash
"13aV8XCYZDQvPFEDFoYrE69qizYWJpPrpT"
```

### 3. トークンを新規発行する

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

これらのコードは、先程と同様に TapyrusAPI のトークン新規発行機能を呼び出すものです。
https://doc.api.tapyrus.chaintope.com/#tag/token/operation/issueToken

ドキュメントにも記載がある通り、TapyrusAPI では以下の 3 種類のトークンが発行可能です。

1. 再発行可能なトークン
2. 再発行不可能なトークン
3. NFT

今回は、token_type に 1 を指定して、再発行可能なトークンを発行します。
それでは、以下のコマンドを実行してトークンを発行しましょう。

```bash
docker compose exec web bin/rails api:post_tokens_issue'[100,1,10]'
```

実行結果として以下のように、新規発行されたトークンの ID とトークン新規発行のために発行された transaction の id が表示されれば、正しく実装できています。

```ruby
{:token_id=>"c154fb27bbb2c91c1eec9357032cf029e0bf6257b429a427d5587504b3c85ca11c", :txid=>"a3d9c914655707240cb80757b7a377f8f741d6455bc4f6baba2645d49ff1edb0"}
```

このトークンは、再発行が可能なので TapyrusAPI のトークンの再発行機能を呼び出すことで、追加発行が可能です。
https://doc.api.tapyrus.chaintope.com/#tag/token/operation/reissueToken

token_type に 2 を指定すると、再発行不可能なトークンとなるため、総量が固定され追加発行はできなくなります。

token_type を 3 にすると NFT となるため、トークンの発行数は常に 1 になります。

### 4. トークンを確認する

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

これらのコードは、TapyrusAPI のトークンの総量取得機能を呼び出すものです。
https://doc.api.tapyrus.chaintope.com/#tag/token/operation/getTokens

これでコマンドが実行できるようになりました。以下のコマンドを実行してトークンを確認しましょう。
自分のアドレスに送付した人は、発行時と変わらないと思いますが、他人のアドレスに送付した人は自分が発行したトークンが減少しています。
また、他の人からトークンを送付された人は自分が発行したものとは別のトークンが確認できます。

```bash
docker compose exec web bin/rails api:get_tokens
```

以下のように、所持しているトークンの ID と総量が表示されれば、正しく実装できています。

```ruby
[{:token_id=>"c154fb27bbb2c91c1eec9357032cf029e0bf6257b429a427d5587504b3c85ca11c", :amount=>100}]
```

もちろんトークンを複数種類発行したり、他の人から受け取っていた場合は、その種類分のトークンが表示されます。

### 5. トークンを送付する

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

これらのコードは、先程と同様に TapyrusAPI のトークンの送付機能を呼び出すものです。
https://doc.api.tapyrus.chaintope.com/#tag/token/operation/transferToken

4 行目の、`req.body = JSON.generate({ "address" => address, "amount" => amount })` で、トークンを送付する相手の address と、送付する数量をパラメータに指定しています。

これでコマンドが実行できるようになりました。以下のコマンドを実行してトークンを発行しましょう。
`<token_id>` は 2. で発行したトークンの `token_id` を、 `<address>` は 1. で作成した自分もしくは他人のアドレスを、 `<amount>` は 2. で発行したトークンの量 (100) 以下の値を指定します。

例えば、送付するトークンの ID が`c154fb27bbb2c91c1eec9357032cf029e0bf6257b429a427d5587504b3c85ca11c`、送付先のアドレスが `13aV8XCYZDQvPFEDFoYrE69qizYWJpPrpT`、送付する数量が 50 の場合は以下のコマンドになります。

```bash
docker compose exec web bin/rails api:put_tokens_transfer'[c154fb27bbb2c91c1eec9357032cf029e0bf6257b429a427d5587504b3c85ca11c,13aV8XCYZDQvPFEDFoYrE69qizYWJpPrpT,50]'
```

実行結果として以下のように、新規発行されたトークンの ID とトークンを送付する transaction の id が表示されれば、正しく実装できています。

```ruby
{:token_id=>"c154fb27bbb2c91c1eec9357032cf029e0bf6257b429a427d5587504b3c85ca11c", :txid=>"33ed4f17ea85746256225eaaebd7d7d7c45337bfc80081b01cb9a2af4da5672a"}
```
