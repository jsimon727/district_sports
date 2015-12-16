class GameBuilder
  def initialize(programs)
    @programs = programs
  end

  def build_games_for(location, days)
    games = []
    programs.take(10).each do |program|
      response = HTTParty.get("http://api.leagueapps.com/v1/sites/#{Api::LEAGUE_APPS_SITE_ID}/programs/#{program["programId"]}/schedule?x-api-key=#{Api::LEAGUE_APPS_API}&state=LIVE")

      return unless response["games"].present?
      games << response["games"].select { |game| game["locationName"] == location } if location.present?
      games << response["games"].select { |game| days.include?(converted_start_time(game["startTime"]).strftime("%a")) } if days.present?
      games << response["games"] unless (location.present? || days.present?)
    end

    games
  end

  private

  attr_reader :programs

  def converted_start_time(time)
    Time.at((time/1000)).to_datetime
  end
end
