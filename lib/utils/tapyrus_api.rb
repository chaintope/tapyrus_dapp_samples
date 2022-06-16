class TapyrusApi
  include Singleton

  class << self
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
  end

  attr_reader :connection, :access_token, :endpoint

  def initialize
    load_access_token
    load_endpoint
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
  end

  def client_key
    OpenSSL::PKey.read File.read(client_pem_path)
  end

  def client_pem_path
    Rails.root.join("tapyrus_api_client.pem")
  end
end
