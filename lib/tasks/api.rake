namespace :api do
  desc 'アドレス一覧'
  task :get_addresses, [:per, :page, :purpose] => :environment do |task, args|
    per = args.per.presence || 25
    page = args.page.presence || 1
    purpose = args.purpose.presence || "general"

    res = TapyrusApi.get_addresses(per: per, page: page, purpose: purpose)
    pp res
  end

  desc 'アドレス作成'
  task :post_addresses, [:purpose] => :environment do |task, args|
    purpose = args.purpose.presence || "general"

    res = TapyrusApi.post_addresses(purpose: purpose)
    pp res
  end

  desc 'トークンの総量取得'
  task :get_tokens, [:confirmation_only] => :environment do |task, args|
    confirmation_only = args.confirmation_only.presence || true

    res = TapyrusApi.get_tokens(confirmation_only)
    pp res
  end

  desc 'トークンの新規作成'
  task :post_tokens_issue, [:amount, :token_type, :split] => :environment do |task, args|
    amount = args.amount.presence
    if amount.blank?
      p 'Amount(発行量)を指定してください。'
      next
    end

    token_type = args.token_type.presence || 1
    split = args.split.presence || 1

    res = TapyrusApi.post_tokens_issue(amount: amount, token_type: token_type, split: split)
    pp res
  end

  desc 'トークンの送付'
  task :put_tokens_transfer, [:token_id, :address, :amount] => :environment do |task, args|
    token_id = args.token_id.presence
    address = args.address.presence
    amount = args.amount.presence

    if token_id.blank? || address.blank? || amount.blank?
      p "引数が不正です。 token_id: #{token_id}, address: #{address}, amount: #{amount}"
      next
    end

    res = TapyrusApi.put_tokens_transfer(token_id, address: address, amount: amount)
    pp res
  end
end