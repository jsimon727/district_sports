require "resolv-replace.rb"

class OmniauthController < ApplicationController
  def redirect
    if params[:dates].present? && params[:dates][:start_date].present? && params[:dates][:end_date].present?
      start_time = Date.strptime(params[:dates][:start_date], '%m/%d/%Y')
      end_time = Date.strptime(params[:dates][:end_date], '%m/%d/%Y')
    else
      start_time = Date.today
      end_time = Date.today + 60.days
    end

    ::ExportDate.create(start_time: start_time, end_time: end_time)

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
    session_access_token = session[:access_token]
    ::Resque.enqueue(::GoogleCalendarApiWorker, session_access_token.to_s)
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
