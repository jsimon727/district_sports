class AutomaticExportWorker
  @queue = :google_calendar_api_queue

  def self.perform
    google_api_client = ::Google::APIClient.new({
      application_name: 'District Sports',
      application_version: '1.0.0'
    })

    keypath = Rails.root.join('config','google_service_key.p12').to_s
    key = Google::APIClient::KeyUtils.load_from_pkcs12(keypath, "notasecret")

    google_api_client.authorization = ::Signet::OAuth2::Client.new({
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      audience: 'https://accounts.google.com/o/oauth2/token',
      scope: 'https://www.googleapis.com/auth/calendar',
      issuer: 'events@district-sports-calendar.iam.gserviceaccount.com',
      signing_key: key,
    })

    google_api_client.authorization.fetch_access_token!

    google_calendar_api = google_api_client.discovered_api('calendar', 'v3')

    existing_events = google_api_client.execute(:api_method => google_calendar_api.events.list,
                                                :parameters => {'calendarId' => 'primary',
                                                                'timeMax' => (Date.today + 1.months).rfc3339,
                                                                'timeMin'=> (Date.today - 1.months).rfc3339,
                                                                'maxResults' => 2500 },
                                                :headers => {'Content-Type' => 'application/json'})



    event_ids = JSON.parse(existing_events.body)["items"].map { |event| event["id"] }

    event_ids.each do |id|
      google_api_client.execute(:api_method => google_calendar_api.events.delete,
                                :parameters => {'calendarId' => 'primary', 'eventId' => id},
                                :headers => {'Content-Type' => 'application/json'})
    end

    programs ||= ::Program.get_live
    events = ::GameBuilder.new(programs).build_games_between(Date.today - 1.months, Date.today + 1.months)
    events.each do |event|
      google_api_client.execute(:api_method => google_calendar_api.events.import,
                                :parameters => {'calendarId' => 'primary'},
                                :body => JSON.dump(event),
                                :colorId => event["colorId"],
                                :headers => {'Content-Type' => 'application/json'})
    end
  end
end
