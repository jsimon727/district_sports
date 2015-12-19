class GameBuilder
  def initialize(programs)
    @programs = programs
  end

  def build_games_for(location, days, dates)
    games = []
    programs.take(10).each do |program|
      response = HTTParty.get("http://api.leagueapps.com/v1/sites/#{Api::LEAGUE_APPS_SITE_ID}/programs/#{program["programId"]}/schedule?x-api-key=#{Api::LEAGUE_APPS_API}&state=LIVE")

      return unless response["games"].present?
      games << response["games"].select { |game| game["locationName"] == location } if location.present?
      games << response["games"].select { |game| days.include?(::DateHelper.convert_time_to_date(game["startTime"]).strftime("%a")) } if days.present?
      games << response["games"].select { |game| ::DateHelper.convert_time_to_date(game["startTime"]).between?(::DateHelper.convert_date_to_datetime(dates[:start_date]), ::DateHelper.convert_date_to_datetime(dates[:end_date])) } if dates.present?
      games << response["games"] unless (location.present? || days.present?)
    end

    games
  end

  private

  attr_reader :programs
end
