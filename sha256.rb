require 'openssl'

# 第1引数に指定したパラメータをSHA256ハッシュするスクリプト
args = ARGV

if args.size > 0
  p OpenSSL::Digest::SHA256.hexdigest(args.shift)
else
  p "引数が指定されていません。"
end
