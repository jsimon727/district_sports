class User < ActiveRecord::Base
  use Rack::Session::Cookie
  use OmniAuth::Strategies::Developer

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token.info
    if (User.admins.include?(data.email))
    user = User.find_by(email: data.email)
      if user
        user.provider = access_token.provider
        user.uid = access_token.uid
        user.token = access_token.credentials.token
        user.save
        user
      else
        redirect_to new_user_registration_path, notice: "Error."
      end
    end
  end
end
