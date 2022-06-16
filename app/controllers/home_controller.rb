class HomeController < ApplicationController
  def index
    @userinfo = TapyrusApi.get_userinfo
  end
end
