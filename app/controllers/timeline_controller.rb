class TimelineController < ApplicationController
  before_filter :require_authentication

  def show
    @posts = current_user.profile.home
  end

  def create
    current_user.profile.feed!(
      :message => params[:message],
      :created_time => @created_time 
    )
    redirect_to timeline_url
  end

end
