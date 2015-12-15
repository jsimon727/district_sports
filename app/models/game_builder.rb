class GameBuilder
  def initialize(programs)
    @programs = programs
  end

  def build_games
    programs.take(10).each do |program|
      response = HTTParty.get("http://api.leagueapps.com/v1/sites/#{Api::LEAGUE_APPS_SITE_ID}/programs/#{program.program_id}/schedule?x-api-key=#{Api::LEAGUE_APPS_API}&state=LIVE")
      return unless response["games"].present?
      game_ids = response["games"].map { |game| game["gameId"] }
      @games = ::Game.where("game_id IN (?)", game_ids)

      if game_ids.count > @games.count
        games = []
        response["games"].each do |game|
          games << ::Game.where(game_id: game["gameId"]).first_or_create( game_id: game["gameId"],
                                                                          location: game["locationName"],
                                                                          start_time: converted_start_time(game["startTime"]),
                                                                          program_id: program.id
                                                                        )
        end
      end
    end

    @games
  end

  def build_games_for(location)
    games = []
    programs.take(10).each do |program|
      response = HTTParty.get("http://api.leagueapps.com/v1/sites/#{Api::LEAGUE_APPS_SITE_ID}/programs/#{program.program_id}/schedule?x-api-key=#{Api::LEAGUE_APPS_API}&state=LIVE")
      return unless response["games"].present?
      games << response["games"].select { |game| game["locationName"] == location }
    end

    game_ids = games.flatten.map { |game| game["gameId"] }
    @games = ::Game.where("game_id IN (?)", game_ids)
  end

  private

  attr_reader :programs

  def converted_start_time(time)
    Time.at((time/1000)).to_datetime
  end
end
