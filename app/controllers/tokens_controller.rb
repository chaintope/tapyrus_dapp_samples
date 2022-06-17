class TokensController < ApplicationController
  def index
    @tokens = Kaminari.paginate_array(TapyrusApi.get_tokens.reverse).page(params[:page])
  end
end
