require "bundler/setup"
require "openssl"
Bundler.require
require "active_support/inflector"

class TapyrusApi
  ENDPOINT = "https://<endpoint>.api.tapyrus.chaintope.com/api/v1"

  def get_timestamps
    connection = Faraday.new(ENDPOINT) do |builder|
      builder.response :raise_error
      builder.response :json, parser_options: { symbolize_names: true }, content_type: 'application/json'
      builder.ssl[:client_cert] = client_cert
      builder.ssl[:client_key] = client_key
    end

    @res ||= connection.get("timestamps") do |req|
      req.headers['Authorization'] = "Bearer #{access_token}"
    end
    
    @res.body
  end

  def get_timestamp(id)
    connection = Faraday.new(ENDPOINT) do |builder|
      builder.response :raise_error
      builder.response :json, parser_options: { symbolize_names: true }, content_type: 'application/json'
      builder.ssl[:client_cert] = client_cert
      builder.ssl[:client_key] = client_key
    end

    @res ||= connection.get("timestamps/#{id}") do |req|
      req.headers['Authorization'] = "Bearer #{access_token}"
    end
    
    @res.body
  end

  def post_timestamp(content:, digest:, prefix:, type:)
    connection = Faraday.new(ENDPOINT) do |builder|
      builder.response :raise_error
      builder.response :json, parser_options: { symbolize_names: true }, content_type: 'application/json'
      builder.ssl[:client_cert] = client_cert
      builder.ssl[:client_key] = client_key
    end

    @res ||= connection.post("timestamps") do |req|
      req.headers['Authorization'] = "Bearer #{access_token}"
      req.headers['Content-Type'] = 'application/json'
      req.body = JSON.generate({ "content" => content, "digest" => digest, "prefix" => prefix, "type" => type })
    end
    
    @res.body
  end

  def client_cert
    OpenSSL::X509::Certificate.new File.read(client_pem_path)
  end

  def client_key
    OpenSSL::PKey.read File.read(client_pem_path)
  end

  def client_pem_path
    './tapyrus_api_client.pem'
  end

  def access_token
    File.read('./access_token.txt')
  end
end

def help
  p "#{__FILE__} [command] [parameter]"
  p "commands:"
  p "get_timestamps               Get Tapyrus Timestamp Transactions"
  p "get_timestamp [id]           Get Tapyrus Timestamp Transaction"
  p "post_timestamp [content]     Issue Tapyrus Timestamp Transaction"
  p "example:"
  p "#{__FILE__} get_timestamps"
  p "#{__FILE__} get_timestamp 1"
  p "#{__FILE__} post_timestamp test"
end

include ActiveSupport::Inflector

args = ARGV

if ["-h", "--help"].any? {|opt| args.include?(opt)}
  help
  return
end

method = args.shift.underscore

api = TapyrusApi.new

case method
when "get_timestamps"
  puts JSON.pretty_generate(api.get_timestamps)
  return
when "get_timestamp"
  puts JSON.pretty_generate(api.get_timestamp(args.shift))
  return
when "post_timestamp"
  content = args.shift
  if content.nil? || content&.empty?
    p "content が指定されていません。使い方は -h オプションで確認できます。"
    return
  end
  puts JSON.pretty_generate(api.post_timestamp(content: content, digest: "sha256", prefix: "b3workshop2022", type: :simple))
  return
else
  p "#{method} は定義されていません。以下のコマンドのいずれかを実行してください。"
  help
  return
end
