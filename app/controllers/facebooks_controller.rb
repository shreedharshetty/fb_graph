require 'rack/oauth2'

class FacebooksController < ApplicationController
  before_filter :require_authentication, :only => :destroy

  rescue_from Rack::OAuth2::Client::Error, :with => :oauth2_error

  # handle Facebook Auth Cookie generated by JavaScript SDK
  def show
    auth = Facebook.auth.from_cookie(cookies)
    authenticate Facebook.identify(auth.user)
    redirect_to dashboard_url
  end

  # handle Normal OAuth flow: start
  def new
    client = Facebook.auth(callback_facebook_url).client
    redirect_to client.authorization_uri(
      :scope => Facebook.config[:scope]
    )
  end

  # handle Normal OAuth flow: callback
  def create
    client = Facebook.auth(callback_facebook_url).client
    client.authorization_code = params[:code]
    access_token = client.access_token!
    user = FbGraph::User.me(access_token).fetch
    authenticate Facebook.identify(user)
    redirect_to dashboard_url
  end

  def destroy
    unauthenticate
    redirect_to root_url
  end

  private

  def oauth2_error(e)
    flash[:error] = {
      :title => e.response[:error][:type],
      :message => e.response[:error][:message]
    }
    redirect_to root_url
  end
end