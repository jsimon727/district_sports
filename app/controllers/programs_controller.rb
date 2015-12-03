class ProgramsController < ApplicationController
  def index
    response = Program.get_current

    program_ids = response.map do |program|
      program["programId"]
    end

    programs = Program.where("program_id IN (?)", program_ids)

    if program_ids.count > programs.count
      programs = []
      response.each do |program|
        programs << Program.where(program_id: program["programId"]).first_or_create(name: program["name"],
                                                                        location: program["location"],
                                                                        schedule_days: program["scheduleDays"],
                                                                        location_id: program["locationId"])
      end
    end

    games  = fetch_games(programs)
    render locals: { games: games }
  end

  private

  def fetch_games(programs)
    games = []
    # TODO: Optimize and run through all programs
    programs.take(2).each do |program|
      games << HTTParty.get("http://api.leagueapps.com/v1/sites/#{Api::LEAGUE_APPS_SITE_ID}/programs/#{program.program_id}/schedule?x-api-key=#{Api::LEAGUE_APPS_API}")
    end

    games
  end
end
