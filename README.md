# 使い方

## 1. 実行環境の準備

1. Ruby 2.7 以上をインストールする。

2. Bundler がインストール済みか確認する。確認するには以下のコマンドを実施する。

```bash
gem list bundler

# 以下のように表示されればインストールされている。
*** LOCAL GEMS ***

bundler (default: 2.2.15)
```

3. Bundler をインストールする。すでにインストール済みの場合はこの手順は不要。

```bash
gem install bundler
```

4. Gemfile に定義している gem をインストールする。

```bash
# Bundler　のローカル設定
# インストール場所を vendor/bundle に設定
# 並列実行数を4に設定
bundle config --local path vendor/bundle
bundle config --local jobs 4

# gem のインストール
bundle install
```

## 2. TapyrusAPI の接続情報設定

1. 各自指定された Google ドライブのフォルダから `tapyrus_api_client.pem` と `access_token.txt` をダウンロードする。

2. ダウンロードした 2 つのファイルを `tapyrus_api.rb` ファイルと同じ階層に配置する。

## 3. TapyrusAPI の使用

### [タイムスタンプトランザクションの作成]

1. 記録したいコンテンツを用意する。コンテンツは文字列である必要がある。

2. Ruby スクリプトを実行する。例としてコンテンツを `test` として実行する。

```bash
ruby tapyrus_api.rb post_timestamp test

# 以下のようなレスポンスが表示される。
{
  "id": 2938,
  "txid": "bf66b17fbdc4da5a454de9f174d0caba0bc4e4a4576e042900d4d7dc3e11e5e3",
  "status": "unconfirmed",
  "content_hash": "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08",
  "prefix": "b3workshop2022",
  "wallet_id": "8b98941123ed727f780aebf95afe29f0",
  "timestamp_type": "simple",
  "p2c_address": null,
  "payment_base": null,
  "prev_id": null,
  "latest": false
}
```

### [作成したトランザクションの確認]

1. 作成済みのトランザクションを参照する。以下の Ruby スクリプトを実行する。ここでは例として [タイムスタンプトランザクションの作成](#タイムスタンプトランザクションの作成) で作成したトランザクションを参照する。

```bash
# ruby tapyrus_api.rb get_timestamp [id]
ruby tapyrus_api.rb get_timestamp 2937

# 以下のようなレスポンスが表示される。
{
  "id": 2938,
  "txid": "bf66b17fbdc4da5a454de9f174d0caba0bc4e4a4576e042900d4d7dc3e11e5e3",
  "status": "unconfirmed",
  "content_hash": "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08",
  "prefix": "b3workshop2022",
  "wallet_id": "8b98941123ed727f780aebf95afe29f0",
  "timestamp_type": "simple",
  "p2c_address": null,
  "payment_base": null,
  "prev_id": null,
  "latest": false
}
```

## 4. 記録した情報の検証

[3. TapyrusAPI の使用](#3-tapyrusapi-の使用)でブロックチェーンに記録したコンテンツを検証する。

1. 記録したコンテンツを SHA256 ハッシュ関数に入力する。例では `test` という文字列をハッシュ関数に入力する。

```bash
ruby sha256.rb test

# 以下のレスポンスが表示される。
"9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08"
```

2. [3. TapyrusAPI の使用](#3-tapyrusapi-の使用)で表示したレスポンスの `content_hash` と 上記の SHA256 の出力を比較する。一致していれば検証 OK。
