class TokensController < ApplicationController
  def index
    @tokens = Kaminari.paginate_array(TapyrusApi.get_tokens.reverse).page(params[:page])
  end

  def new
    @form = Token::Form.new
  end

  def create
    @form = Token::Form.new(create_params)
    if @form.validate
      res = TapyrusApi.post_tokens_issue(amount: @form.amount, token_type: @form.token_type, split: @form.split)
      if res.present?
        redirect_to tokens_path, notice: 'Tokenを作成しました。反映されるまでしばらく時間がかかります。'
      else
        Rails.logger.error("#{self.class.name}##{__method__} res=#{res}")
        flash.now[:alert] = 'TapyrusAPIの接続で障害が発生しました'
        render :new
      end
    else
      render :new
    end
  rescue StandardError, RuntimeError => e
    Rails.logger.error(e)
    flash.now[:alert] = 'Tokenの作成に失敗しました'
    render :new
  end

  private

  def create_params
    params.require(:token).permit(:amount, :token_type, :split)
  end
end
