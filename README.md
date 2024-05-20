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

### 1.2. アクセストークン, TapyrusAPI エンドポイント, クライアント証明書のパスフレーズ

```bash
cp .env.sample .env
```

`.env`ファイルを編集します。  
アクセストークン, TapyrusAPI エンドポイント, クライアント証明書のパスフレーズはハンズオン時にお伝えします。  

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
docker compose up --build
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

1. [Work1 スクリプトの作成](doc/work1.md)
1. [Work2 ウェブアプリの作成](doc/work2.md)
