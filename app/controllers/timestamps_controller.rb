class TimestampsController < ApplicationController
  def index
    @timestamps = Kaminari.paginate_array(TapyrusApi.get_timestamps.reverse).page(params[:page])
  end

  def show
    @timestamp = TapyrusApi.get_timestamp(params[:id])
  end
end
