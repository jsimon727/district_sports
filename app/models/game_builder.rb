class GameBuilder
  def initialize(programs)
    @programs = programs
  end

  def build_games_between(start_date, end_date)
    games = []
    programs.select { |program| program["state"] == "LIVE"}.reject { |program| program["name"].split(" - ").first == "Free Agent Pool" }.each do |program|
      response = HTTParty.get("http://api.leagueapps.com/v1/sites/#{Api::LEAGUE_APPS_SITE_ID}/programs/#{program["programId"]}/schedule?x-api-key=#{Api::LEAGUE_APPS_API}")
      blk = lambda {|h,k| h[k] = Hash.new(&blk)}

      next unless response["games"].present?
      response["games"].select { |game| ::DateHelper.convert_time_to_date(game["startTime"]).between?(start_date, end_date) }.each do |game_response|
        game = Hash.new(&blk)
        game["summary"] = game_response["locationName"]
        game["description"] = "#{program["name"]} - #{game_response["team1"]} v. #{game_response["team2"]}"
        game["location"] = game_response["locationName"]
        game["iCalUID"] = game_response["gameId"]
        game["colorId"] = find_color_id(game_response["locationName"])
        game["start"]["dateTime"] = ::DateHelper.convert_time_to_date(game_response["startTime"]).strftime("%FT%T%:z")
        game["end"]["dateTime"] = end_date_time(program, game_response["startTime"]).strftime("%FT%T%:z")
        games << game
      end
    end

    games
  end

  private

  attr_reader :programs

  def end_date_time(program, start_time)
    if program["name"] == "11v11 - 2016 Fall Sunday - Men's D1"
      ::DateHelper.convert_time_to_date(start_time) + 1.hours + 45.minutes
    else
      case program["name"].split(" -").first
      when "11v11"
        ::DateHelper.convert_time_to_date(start_time) + 1.hours + 20.minutes
      else
        ::DateHelper.convert_time_to_date(start_time) + 1.hours
      end
    end
  end

  def find_color_id(location)
    colors = { "Cardozo High School" => 1,
               "Stead Field" => 2,
               "Bell Field" => 3,
               "Thomson Elementary School" => 4,
               "Bundy Field" => 5,
               "Roosevelt High School" => 6,
               "Maret School" => 1,
               "Tubman Elementary" => 2,
               "St. Alban's" => 3
              }

    colors.fetch(location, 4)
  end
end
