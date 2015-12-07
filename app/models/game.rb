class Game < ActiveRecord::Base

  def self.build_for(programs)
    games ||= []
    programs.take(4).each do |program|
      response = HTTParty.get("http://api.leagueapps.com/v1/sites/#{Api::LEAGUE_APPS_SITE_ID}/programs/#{program.program_id}/schedule?x-api-key=#{Api::LEAGUE_APPS_API}")
      return unless response["games"].present?
      response["games"].each do |game|
        games << Game.where(game_id: game["gameId"]).first_or_create( game_id: game["gameId"],
                                                                      location: game["locationName"],
                                                                      start_time: Time.at((game["startTime"]/1000)).to_datetime,
                                                                      program_id: program.id
                                                                    )
      end
    end

    games
  end

  private

  def self.converted_start_time(time)
    Time.at((time/100)).to_datetime
  end
end
