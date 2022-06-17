class TimestampsController < ApplicationController
  def index
    @timestamps = Kaminari.paginate_array(TapyrusApi.get_timestamps.reverse).page(params[:page])
  end

  def show
    @timestamp = TapyrusApi.get_timestamp(params[:id])
  end

  def new
    @form = Timestamp::Form.new
  end

  def create
    @form = Timestamp::Form.new(create_params)
    if @form.validate
      res = TapyrusApi.post_timestamp(content: @form.content, digest: :sha256, prefix: @form.prefix, type: :simple)
      if res.present?
        redirect_to timestamp_path(res[:id]), notice: 'Timestampを作成しました'
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
    flash.now[:alert] = 'Timestampの作成に失敗しました'
    render :new
  end

  private

  def create_params
    params.require(:timestamp).permit(:prefix, :content)
  end
end
