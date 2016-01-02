class Program < ActiveRecord::Base
  LIVE_PROGRAMS_URL = "http://api.leagueapps.com/v1/sites/#{Api::LEAGUE_APPS_SITE_ID}/programs/current?x-api-key=#{Api::LEAGUE_APPS_API}&state=LIVE"

  def self.get_live
    HTTParty.get(LIVE_PROGRAMS_URL)
  end

  def self.get_for(dates)
    programs = []
    response = HTTParty.get(LIVE_PROGRAMS_URL)
    response.select do |program|
      start_date = ::DateHelper.convert_date_to_datetime(dates[:start_date])
      end_date = ::DateHelper.convert_date_to_datetime(dates[:end_date])
      programs << program if ::DateHelper.convert_time_to_date(program["startTime"]).between?(start_date, end_date)
    end
    programs
  end

  def self.build_for_days(days)
    response = HTTParty.get(LIVE_PROGRAMS_URL)

    programs = response.select do |program|
      days.to_set.superset?(program["scheduleDays"].split(",").to_set)
    end

    programs
  end
end
