require "resolv-replace.rb"

class GoogleCalendarApiWorker
  @queue = :google_calendar_api_queue

  def self.perform(session_access_token)

    google_api_client = ::Google::APIClient.new({
      application_name: 'District Sports',
      application_version: '1.0.0'
    })

    google_api_client.authorization = ::Signet::OAuth2::Client.new({
      client_id: Rails.application.secrets.google_client_id,
      client_secret: Rails.application.secrets.google_client_secret,
      access_token: session_access_token
    })

    google_calendar_api = google_api_client.discovered_api('calendar', 'v3')

    google_api_client.execute(:api_method => google_calendar_api.calendars.clear,
                            :parameters => {'calendarId' => 'primary'},
                            :headers => {'Content-Type' => 'application/json'})

    programs ||= ::Program.get_live
    events = ::GameBuilder.new(programs).build_games_for_export_between(ExportDate.last.start_time, ExportDate.last.end_time)
    events.each do |event|
      google_api_client.execute(:api_method => google_calendar_api.events.import,
                              :parameters => {'calendarId' => 'primary'},
                              :body => JSON.dump(event),
                              :colorId => event["colorId"],
                              :headers => {'Content-Type' => 'application/json'})
    end
  end
end
