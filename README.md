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

`lib/utils/tapyrus_api.rb` の `@url = 'ここにURLを記入してください'` の部分に TapyrusAPI エンドポイントの URL を書いてください。

## 2. Web App を起動する

Docker で用意された環境を起動します。

起動したら `http://localhost:3000` にアクセスすることでアプリケーションを使用できます。

### 2.1. データベースを作成する

初回起動時はデータベースがないため作成する必要があります。
以下のコマンドを実行しデータベースを作成します。

```
docker compose run --rm web db:create db:migrate
```

### 2.2. アプリケーションを起動する

```
docker compose up -d --build
```

### 2.3. Docker コンテナとデータベースを削除する

Docker にまつわるデータを削除できます。

TapyrusAPI を使ってブロックチェーンに書き込んだトランザクションは消えません。

```
docker compose down -v --remove-orphans
```

# ワーク

## 1. トークンの新規作成と送付

### 1.1. トークンの新規発行

このワークでは、独自のトークンを作成しそれを誰かに送付することを行います。

トークンの新規発行は TapyrusAPI を使うことで簡単に行えます。

まずは、トークンの新規発行 API を実装しましょう。
`lib/utils/tapyrus_api.rb` の `post_tokens_issue` メソッドを実装しましょう。

以下の通り実装することで、TapyrusAPI のトークンの新規発行 API を実行できます。

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

実装したら早速ブラウザで確認してみましょう。

[コンテナを更新](#22-アプリケーションを起動する)して http://localhost:3000/tokens/new にアクセスしてみましょう。

`Amount` には `100` を、 `Token Type` には `再発行可能トークン` を、 `Split` には `10` を入力して `BCに記録` を押してみましょう。

### 1.2. トークンの確認

トークンを作成したら今持っているトークンの量が気になりますよね。

そしたら次は、トークンの総量取得 API を実装しましょう。
`lib/utils/tapyrus_api.rb` の `get_tokens` メソッドを実装しましょう。

以下の通り実装することで、TapyrusAPI のトークンの総量取得 API を実行できます。

```ruby
def get_tokens(confirmation_only = true)
  res = instance.connection.get("/api/v1/tokens") do |req|
    req.headers['Authorization'] = "Bearer #{instance.access_token}"
    req.params['confirmation_only'] = confirmation_only
  end

  res.body
end
```

[コンテナを更新](#22-アプリケーションを起動する)して http://localhost:3000/tokens にアクセスしてみましょう。

### 1.3. トークンの送付

最後に作成したトークンを誰かに送ってみましょう。

`lib/utils/tapyrus_api.rb` の `put_tokens_transfer` メソッドを実装しましょう。

以下の通り実装することで、TapyrusAPI のトークンの送付 API を実行できます。

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

送り先のアドレスが必要になります。

アドレスがない場合は `lib/utils/tapyrus_api.rb` の `post_addresses` メソッドを実装しましょう。

以下の通り実装して、API を実行することで作成できます。

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

また、作成したアドレスは `lib/utils/tapyrus_api.rb` の `get_addresses` メソッドを実装して API を実行することで確認できます。

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

[コンテナを更新](#22-アプリケーションを起動する)して http://localhost:3000/wallets にアクセスしてみましょう。

`アドレス作成` を押すと 1 つアドレスが新規に作成されます。
このアドレスをトークンの送り主に教えましょう。

そしたら次は、誰かにトークンを送ってみましょう。

http://localhost:3000/tokens/transfer にアクセスしてみましょう。

自分が所有している送りたいトークンの `Token Id` を指定し、送り先の `Address` と送付量 `Amount` を入力して `BCに記録` しましょう。

トークンの送付はできましたか？

最後に、誰かから送られてきたトークンがどれだけあるのか確認したいですよね。

http://localhost:3000/tokens にアクセスして確認してみましょう。

いかがでしたか？

自分で作成したトークン以外のトークンが表示されましたか？

以上でトークンの送付と確認のワークは終了になります。
