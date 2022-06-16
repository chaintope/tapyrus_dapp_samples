class TimestampsController < ApplicationController
  def index
    @timestamps = Kaminari.paginate_array(TapyrusApi.get_timestamps).page(params[:page])
  end
end
