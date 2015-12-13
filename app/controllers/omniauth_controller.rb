class OmniauthController < ApplicationController
  def redirect
    google_api_client = Google::APIClient.new({
      application_name: 'District Sports',
      application_version: '1.0.0'
    })
    google_api_client.authorization = Signet::OAuth2::Client.new({
      client_id: client_id,
      client_secret: client_secret,
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      scope: 'https://www.googleapis.com/auth/calendar',
      redirect_uri: "http://localhost:3000/auth/google_oauth2/callback"
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
      redirect_uri: "http://localhost:3000/auth/google_oauth2/callback",
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

    @events =
      {
        'summary' => 'Distrcit Sports Test API',
        'description' => 'District Sports Test',
        'location' => 'Somewhere',
        'iCalUID' => SecureRandom.uuid,
        'start' => {
          'dateTime' => '2015-12-04T10:00:00.000-07:00'
        },
        'end' => {
          'dateTime' => '2015-12-04T11:00:00.000-07:00'
        }
      }

    result = google_api_client.execute(:api_method => google_calendar_api.events.import,
                            :parameters => {'calendarId' => 'primary'},
                            :body => JSON.dump(@event),
                            :headers => {'Content-Type' => 'application/json'})

    if result.response.status == 200
      flash[:success] = "All events have been successfully exported"
    else
      flash[:error] = "Something went wrong"
    end

    head :ok
  end

  private

  def client_id
    Rails.application.secrets.google_client_id
  end

  def client_secret
    Rails.application.secrets.google_client_secret
  end
end
