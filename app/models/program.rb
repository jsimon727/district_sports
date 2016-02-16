class Program < ActiveRecord::Base
  PROGRAMS_URL = "http://api.leagueapps.com/v1/sites/#{Api::LEAGUE_APPS_SITE_ID}/programs/current?x-api-key=#{Api::LEAGUE_APPS_API}"

  def self.get_live
    response = HTTParty.get(PROGRAMS_URL)
    response.select { |program| program["state"] == "LIVE"}.reject { |program| program["name"].split(" - ").first == "Free Agent Pool" }
  end

  # def self.get_for(dates)
    # programs = []
    # response = HTTParty.get(PROGRAMS_URL)
    # response.select { |program| program["state"] == "LIVE"}.reject { |program| program["name"].split(" - ").first == "Free Agent Pool" }.select do |program|
      # start_date = ::DateHelper.convert_date_to_datetime(dates[:start_date])
      # end_date = ::DateHelper.convert_date_to_datetime(dates[:end_date])
      # programs << program if ::DateHelper.convert_time_to_date(program["startTime"]).between?(start_date, end_date)
    # end
    # programs
  # end
end
