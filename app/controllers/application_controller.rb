class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # USERS = { "districtsports" => Rails.application.secrets.login_password }

  # before_filter :authenticate

  # def authenticate
    # if Rails.env.production?
      # authenticate_or_request_with_http_digest("Application") do |name|
        # USERS[name]
      # end
    # end
  # end

  helper_method :current_user

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
end
