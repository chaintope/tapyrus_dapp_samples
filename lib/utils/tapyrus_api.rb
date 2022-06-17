class TapyrusApi
  include Singleton

  class FileNotFound < StandardError; end
  class EndpointNotFound < StandardError; end

  class << self
    def get_addresses(per: 25, page: 1, purpose: "general")
      res = instance.connection.get("addresses") do |req|
        req.headers['Authorization'] = "Bearer #{instance.access_token}"
        req.params['per'] = per
        req.params['page'] = page
        req.params['purpose'] = purpose
      end

      res.body
    end

    def post_addresses(purpose: "general")
      res = instance.connection.post("addresses") do |req|
        req.headers['Authorization'] = "Bearer #{instance.access_token}"
        req.headers['Content-Type'] = 'application/json'
        req.body = JSON.generate({ "purpose" => purpose })
      end

      res.body
    end

    def get_userinfo(confirmation_only = true)
      res = instance.connection.get("userinfo") do |req|
        req.headers['Authorization'] = "Bearer #{instance.access_token}"
        req.params['confirmation_only'] = confirmation_only
      end

      res.body
    end

    def get_timestamps
      res = instance.connection.get("timestamps") do |req|
        req.headers['Authorization'] = "Bearer #{instance.access_token}"
      end

      res.body
    end

    def get_timestamp(id)
      res = instance.connection.get("timestamps/#{id}") do |req|
        req.headers['Authorization'] = "Bearer #{instance.access_token}"
      end

      res.body
    end

    def post_timestamp(content:, digest:, prefix:, type:)
      res ||= instance.connection.post("timestamps") do |req|
        req.headers['Authorization'] = "Bearer #{instance.access_token}"
        req.headers['Content-Type'] = 'application/json'
        req.body = JSON.generate({ "content" => content, "digest" => digest, "prefix" => prefix, "type" => type })
      end

      res.body
    end

    def get_tokens(confirmation_only = true)
      res = instance.connection.get("tokens") do |req|
        req.headers['Authorization'] = "Bearer #{instance.access_token}"
        req.params['confirmation_only'] = confirmation_only
      end

      res.body
    end

    def post_tokens_issue(amount:, token_type: 1, split: 1)
      res = instance.connection.post("tokens/issue") do |req|
        req.headers['Authorization'] = "Bearer #{instance.access_token}"
        req.headers['Content-Type'] = 'application/json'
        req.body = JSON.generate({ "amount" => amount, "token_type" => token_type, "split" => split })
      end

      res.body
    end

    def post_tokens_reissue(token_id, amount:, split: 1)
      res = instance.connection.post("tokens/#{token_id}/reissue") do |req|
        req.headers['Authorization'] = "Bearer #{instance.access_token}"
        req.headers['Content-Type'] = 'application/json'
        req.body = JSON.generate({ "amount" => amount, "split" => split })
      end

      res.body
    end

    def put_tokens_transfer(token_id, address:, amount:)
      res = instance.connection.put("tokens/#{token_id}/transfer") do |req|
        req.headers['Authorization'] = "Bearer #{instance.access_token}"
        req.headers['Content-Type'] = 'application/json'
        req.body = JSON.generate({ "address" => address, "amount" => amount })
      end

      res.body
    end
  end

  attr_reader :connection, :access_token, :endpoint

  def initialize
    load_access_token
    load_endpoint
    raise TapyrusApi::EndpointNotFound, "接続先URLが正しくありません" if URI::DEFAULT_PARSER.make_regexp.match(@endpoint).blank?
    @connection ||= Faraday.new(@endpoint) do |builder|
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

  def load_endpoint
    if File.exist?(Rails.root.join("endpoint.txt"))
      @endpoint = File.read(Rails.root.join("endpoint.txt"))
    else
      Rails.logger.warn("Not Found Endpoint")
      @endpoint = nil
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
