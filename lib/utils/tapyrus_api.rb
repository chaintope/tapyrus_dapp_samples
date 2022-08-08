# ワークで実装
ACCESS_TOKEN = "ここにアクセストークンを記入してください"
TAPYRUS_API_ENDPOINT_URL = "ここにURLを記入してください"

class TapyrusApi
  include Singleton

  class FileNotFound < StandardError; end
  class UrlNotFound < StandardError; end

  class << self
    def get_addresses(per: 25, page: 1, purpose: "general")
      # ワーク1.3.で実装
      return {
        "addresses": ["未実装です", "未実装です"],
        "count": 2
      }
    end

    def post_addresses(purpose: "general")
      # ワーク1.3.で実装
    end

    def get_userinfo(confirmation_only = true)
      # http://localhost:3000 で使用している。
      # 応用編として実装してみよう。
      return {
        sub: "未実装です。",
        addresses: ["未実装です。"]
      }
    end

    def get_timestamps
      # Additional Task で実装
    end

    def get_timestamp(id)
      # Additional Task で実装
    end

    def post_timestamp(content:, digest:, prefix:, type:)
      # Additional Task で実装
    end

    def get_tokens(confirmation_only = true)
      # ワーク1.2.で実装
      return [
        {
          token_id: "未実装です",
          amount: 0
        }

      ]
    end

    def post_tokens_issue(amount:, token_type: 1, split: 1)
      # ワーク1.1.で実装
    end

    def put_tokens_transfer(token_id, address:, amount:)
      # ワーク1.3.で実装
    end
  end

  attr_reader :connection, :access_token, :url

  def initialize
    @access_token = ACCESS_TOKEN
    @url = TAPYRUS_API_ENDPOINT_URL
    raise TapyrusApi::UrlNotFound, "接続先URLが正しくありません" if URI::DEFAULT_PARSER.make_regexp.match(@url).blank?
    @connection ||= Faraday.new(@url) do |builder|
      builder.response :raise_error
      builder.response :json, parser_options: { symbolize_names: true }, content_type: 'application/json'
      builder.ssl[:client_cert] = client_cert
      builder.ssl[:client_key] = client_key
    end
  end

  private

  def client_cert
    OpenSSL::PKCS12.new(load_client_cert_p12, 'b3workshop').certificate
  rescue Errno::ENOENT => e
    Rails.logger.error(e)
    raise TapyrusApi::FileNotFound, 'クライアント証明書がありません'
  end

  def client_key
    OpenSSL::PKCS12.new(load_client_cert_p12, 'b3workshop').key
  rescue Errno::ENOENT => e
    Rails.logger.error(e)
    raise TapyrusApi::FileNotFound, 'クライアント証明書がありません'
  end

  def load_client_cert_p12
    File.read(Rails.root.join("tapyrus_api_client_cert_2022-07-26.p12"))
  end
end
