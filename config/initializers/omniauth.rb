Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_CAL_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'],
  { access_type: "offline", approval_prompt: "", scope: 'email,calendar' }
end
