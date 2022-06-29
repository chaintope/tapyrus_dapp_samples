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

`lib/utils/tapyrus_api.rb` の 131行目にある `@url = 'ここにURLを記入してください'` の部分に TapyrusAPI エンドポイントの URL を書いてください。

## 2. 実行環境を起動する

Docker で用意された環境を起動します。

### 2.1. データベースを作成する

初回起動時はデータベースがないため作成する必要があります。
以下のコマンドを実行しデータベースを作成します。

workshop202207フォルダに移動して、以下のコマンドを実行してください。

```
docker compose run --rm web bin/rails db:create
```

### 2.2. アプリケーションを起動する

workshop202207フォルダに移動して、以下のコマンドを実行してください。

```
docker compose up --build
```

アプリケーションを起動すると、そのターミナル上にはアプリケーションのログが表示されます。

以降の作業でコマンドを実行する場合は新しいターミナルを起動して実行してください。

### 2.3. Docker コンテナとデータベースを削除する

Dockerコンテナで作成されたデータを削除できます。

TapyrusAPI を使ってブロックチェーンに書き込んだトランザクションは消えません。

```
docker compose down -v --remove-orphans
```

# ワーク

## 1. TapyrusAPI を使ってみよう

あらかじめ Rake タスクで TapyrusAPI のトークン API を実装しています。

Rake タスクを実行して TapyrusAPI を実行してみましょう。

1. アドレスを作成する

```bash
docker compose exec web bin/rails api:post_addresses
```

2. トークンを新規発行する

```bash
docker compose exec web bin/rails api:post_tokens_issue'[100,1,10]'
```

3. トークンを送付する

```bash
docker compose exec web bin/rails api:put_tokens_transfer'[<token_id>,<address>,<amount>]'
```

4. トークンを確認する

```bash
docker compose exec web bin/rails api:get_tokens
```
