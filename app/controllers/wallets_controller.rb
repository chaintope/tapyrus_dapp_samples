class WalletsController < ApplicationController
  def index
    wallets = TapyrusApi.get_addresses(per: 25, page: params[:page])
    wallets[:addresses].reverse!
    @wallets = Kaminari.paginate_array(wallets[:addresses], total_count: wallets[:count]).page(params[:page]).per(25)
  end

  def create
    wallet = TapyrusApi.post_addresses
    if wallet.blank?
      redirect_to wallets_path, alert: 'アドレスの作成に失敗しました。'
    end
    redirect_to wallets_path, notice: "アドレス #{wallet} を作成しました。"
  end
end
