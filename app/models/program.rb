class Program < ActiveRecord::Base
  LIVE_PROGRAMS_URL = "http://api.leagueapps.com/v1/sites/#{Api::LEAGUE_APPS_SITE_ID}/programs/current?x-api-key=#{Api::LEAGUE_APPS_API}&state=LIVE"

  def self.build_live
    HTTParty.get(LIVE_PROGRAMS_URL)
  end

  def self.build_for_days(days)
    response = HTTParty.get(LIVE_PROGRAMS_URL)

    programs = response.select do |program|
      days.to_set.superset?(program["scheduleDays"].split(",").to_set)
    end

    programs
  end
end
