class TimestampsController < ApplicationController
  def index
    @timestamps = Kaminari.paginate_array(TapyrusApi.get_timestamps.reverse).page(params[:page])
  end

  def show
    @timestamp = TapyrusApi.get_timestamp(params[:id])
  end

  def new
  end

  def create
    response = TapyrusApi.post_timestamp(content: create_params[:content], digest: :sha256, prefix: create_params[:prefix], type: :simple)
    if response.present?
      redirect_to timestamp_path(response[:id]), notice: 'Timestampを作成しました'
    else
      redirect_to timestamps_path, notice: 'Timestampを作成しました'
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
