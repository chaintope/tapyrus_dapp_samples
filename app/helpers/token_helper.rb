module TokenHelper
  def token_ids
    TapyrusApi.get_tokens.map { |h| h[:token_id] }
  end
end
