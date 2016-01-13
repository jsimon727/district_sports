class GameBuilder
  def initialize(programs)
    @programs = programs
  end

  def build_games_for(location, days, dates)
    games = []
    return unless programs.present?
    programs.select { |program| program["state"] == "LIVE"}.last(10).each do |program|
      response = HTTParty.get("http://api.leagueapps.com/v1/sites/#{Api::LEAGUE_APPS_SITE_ID}/programs/#{program["programId"]}/schedule?x-api-key=#{Api::LEAGUE_APPS_API}&state=LIVE")

      next unless response["games"].present?
      games << response["games"].select { |game| game["locationName"] == location } if location.present?
      games << response["games"].select { |game| days.include?(::DateHelper.convert_time_to_date(game["startTime"]).strftime("%a")) } if days.present?
      games << response["games"].select { |game| ::DateHelper.convert_time_to_date(game["startTime"]).between?(::DateHelper.convert_date_to_datetime(dates[:start_date]), ::DateHelper.convert_date_to_datetime(dates[:end_date])) } if dates.present? && dates[:start_date].present? && dates[:end_date].present?
      games << response["games"] unless (location.present? || days.present?)
    end

    games
  end

  def build_games_between(bow, eow)
    games = []
    return unless programs.present?

    programs.last(20).each do |program|
      response = HTTParty.get("http://api.leagueapps.com/v1/sites/#{Api::LEAGUE_APPS_SITE_ID}/programs/#{program["programId"]}/schedule?x-api-key=#{Api::LEAGUE_APPS_API}&state=LIVE")
      next unless response["games"].present?
      games << response["games"].select { |game| ::DateHelper.convert_time_to_date(game["startTime"]).between?(bow, eow) && !game_time_present?(game, games.flatten) }
    end

    games
  end

  def build_games_for_export
    games = []
    programs.select { |program| program["state"] == "LIVE"}.reject { |program| program["name"].split(" - ").first == "Free Agent Pool" }.last(20).each do |program|
      response = HTTParty.get("http://api.leagueapps.com/v1/sites/#{Api::LEAGUE_APPS_SITE_ID}/programs/#{program["programId"]}/schedule?x-api-key=#{Api::LEAGUE_APPS_API}&state=LIVE")
      blk = lambda {|h,k| h[k] = Hash.new(&blk)}

      next unless response["games"].present?
      response["games"].last(10).each do |game_response|
        next if event_game_time_present?(game_response, games)
        game = Hash.new(&blk)
        game["summary"] = game_response["locationName"]
        game["description"] = game_response["locationName"]
        game["location"] = game_response["locationName"]
        game["iCalUID"] = "#{game_response["startTime"]}_#{game_response["locationName"]}"
        game["start"]["dateTime"] = ::DateHelper.convert_time_to_date(game_response["startTime"])
        game["end"]["dateTime"] = end_date_time(program, game_response["startTime"])
        games << game
      end
    end

    games
  end

  private

  attr_reader :programs

  def event_game_time_present?(game_response, games)
    games.map { |game| game["start"]["dateTime"] }.include?(::DateHelper.convert_time_to_date(game_response["startTime"])) && games.map { |game| game["location"] }.include?(game_response["locationName"])
  end

  def game_time_present?(game_response, games)
    games.map { |game| game["startTime"] }.include?(game_response["startTime"]) && games.map { |game| game["locationName"] }.include?(game_response["locationName"])
  end

  def end_date_time(program, start_time)
    case program["name"].split(" -").first
    when "11v11"
      ::DateHelper.convert_time_to_date(start_time) + 1.hours + 20.minutes
    else
      ::DateHelper.convert_time_to_date(start_time) + 1.hours
    end
  end
end
