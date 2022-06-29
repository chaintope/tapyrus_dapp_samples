# ワークで実装
TAPYRUS_API_ENDPOINT_URL = "ここにURLを記入してください"

class TapyrusApi
  include Singleton

  class FileNotFound < StandardError; end
  class UrlNotFound < StandardError; end

  class << self
    def get_addresses(per: 25, page: 1, purpose: "general")
      # ワーク1.3.で実装
    end

    def post_addresses(purpose: "general")
      # ワーク1.3.で実装
    end

    def get_userinfo(confirmation_only = true)
      # http://localhost:3000 で使用している。
      # 応用編として実装してみよう。
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
    load_access_token
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

  def load_access_token
    if File.exist?(Rails.root.join("access_token.txt"))
      @access_token = File.read(Rails.root.join("access_token.txt"))
    else
      Rails.logger.warn("Not Found Access Token")
      @access_token = nil
    end
  end

  def client_cert
    OpenSSL::X509::Certificate.new File.read(client_pem_path)
  rescue Errno::ENOENT => e
    Rails.logger.error(e)
    raise TapyrusApi::FileNotFound, 'クライアント証明書がありません'
  end

  def client_key
    OpenSSL::PKey.read File.read(client_pem_path)
  rescue Errno::ENOENT => e
    Rails.logger.error(e)
    raise TapyrusApi::FileNotFound, 'クライアント証明書がありません'
  end

  def client_pem_path
    Rails.root.join("tapyrus_api_client.pem")
  end
end
