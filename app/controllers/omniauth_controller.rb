class OmniauthController < ApplicationController
  def redirect
    puts "ATTENTION: HELLLO redirect_uri: 'http://#{Rails.application.secrets.redirect_uri_hostname}/auth/google_oauth2/callback'"

    google_api_client = Google::APIClient.new({
      application_name: 'District Sports',
      application_version: '1.0.0'
    })
    google_api_client.authorization = Signet::OAuth2::Client.new({
      client_id: client_id,
      client_secret: client_secret,
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      scope: 'https://www.googleapis.com/auth/calendar',
      redirect_uri: "http://district-sports.herokuapp.com/auth/google_oauth2/callback"
    })

    authorization_uri = google_api_client.authorization.authorization_uri
    redirect_to authorization_uri.to_s
  end

  def callback
    google_api_client = Google::APIClient.new({
      application_name: 'District Sports',
      application_version: '1.0.0'
    })

    google_api_client.authorization = Signet::OAuth2::Client.new({
      client_id: client_id,
      client_secret: client_secret,
      grant_type: 'authorization_code',
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      scope: 'https://www.googleapis.com/auth/calendar',
      redirect_uri: "http://district-sports.herokuapp.com/auth/google_oauth2/callback",
      code: params[:code]
    })

    response = google_api_client.authorization.fetch_access_token!
    session[:access_token] = response['access_token']

    redirect_to auth_google_oauth2_calendar_path
  end

  def calendar
    google_api_client = Google::APIClient.new({
      application_name: 'District Sports',
      application_version: '1.0.0'
    })

    google_api_client.authorization = Signet::OAuth2::Client.new({
      client_id: client_id,
      client_secret: client_secret,
      access_token: session[:access_token]
    })

    google_calendar_api = google_api_client.discovered_api('calendar', 'v3')
    api_method = google_calendar_api.events.import
    programs ||= Program.get_live
    events = GameBuilder.new(programs).build_games_for_export
    events.each do |event|
      google_api_client.execute(:api_method => api_method,
                              :parameters => {'calendarId' => 'primary'},
                              :body => JSON.dump(event),
                              :headers => {'Content-Type' => 'application/json'})
    end
    redirect_to root_path
  end

  private

  def client_id
    Rails.application.secrets.google_client_id
  end

  def client_secret
    Rails.application.secrets.google_client_secret
  end
end
