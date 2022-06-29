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
```json
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

これでコマンドが実行できるようになりました。以下のコマンドを実行してアドレスを作成しましょう。

```bash
docker compose exec web bin/rails api:post_addresses
```

3トークンを新規発行する

以下のコマンドでトークンを発行できるように実装してみましょう。

```bash
docker compose exec web bin/rails api:post_tokens_issue'[100,1,10]'
```

このコマンドで実行されるのは `lib/tasks/api.rake` の 29 行目です。この中で`TapyrusApi.post_tokens_issue(amount: amount, token_type: token_type, split: split)`を呼び出しています。

先ほどと同様にメソッドの中身がありませんので実装しましょう。

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

これでコマンドが実行できるようになりました。以下のコマンドを実行してトークンを発行しましょう。

```bash
docker compose exec web bin/rails api:post_tokens_issue'[100,1,10]'
```

4トークンを送付する

以下のコマンドでトークンを送付できるように実装してみましょう。

```bash
docker compose exec web bin/rails api:put_tokens_transfer'[<token_id>,<address>,<amount>]'
```

このコマンドで実行されるのは `lib/tasks/api.rake` の 44 行目です。この中で`TapyrusApi.put_tokens_transfer(token_id, address: address, amount: amount)`を呼び出しています。

先ほどと同様にメソッドの中身がありませんので実装しましょう。

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

これでコマンドが実行できるようになりました。以下のコマンドを実行してトークンを発行しましょう。
`<token_id>` は 2. で発行したトークンの `token_id` を、 `<address>` は 1. で作成した自分もしくは他人のアドレスを、 `<amount>` は 2. で発行したトークンの量 (100) 以下の値を指定します。

```bash
docker compose exec web bin/rails api:put_tokens_transfer'[<token_id>,<address>,<amount>]'
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

これでコマンドが実行できるようになりました。以下のコマンドを実行してトークンを確認しましょう。
自分のアドレスに送付した人は、発行時と変わらないと思いますが、他人のアドレスに送付した人は自分が発行したトークンが減少していると思います。
また、他人から送付された人は自分が発行したものとは別のトークンが確認できるかと思います。

```bash
docker compose exec web bin/rails api:get_tokens
```
