# README

2022 年に実施の B3 のワークショップで用いるサンプルコード

# 起動手順

## 1. TapyrusAPI の準備

以下の 3 つの設定ファイルを配置してください。

階層は以下のようになります。

```
- workshop202207
|-- app
|-- bin
|-- config
....
|-- access_token.txt
|-- endpoint.txt
|-- tapyrus_api_client.pem
```

### 1.1. エンドポイント

Google ドライブで共有する `endpoint.txt` を `workshop202207` ディレクトリに置きます。

### 1.2. アクセストークン

Google ドライブで共有する `access_token.txt` を `workshop202207` ディレクトリに置きます。

TapyrusAPI のアクセストークンはそれぞれのウォレットを識別する情報であり、また API 利用のための認証情報でもあります。

### 1.3. クライアント証明書

Google ドライブで共有する `tapyrus_api_client.pem` を `workshop202207` ディレクトリに置きます。

TapyrusAPI のクライアント証明書は API 利用のための認証情報になります。

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
