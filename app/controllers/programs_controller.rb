class ProgramsController < ApplicationController
  def index
    programs ||= Program.build_live

    filtered_games = GameBuilder.new(programs).build_games_for(params[:location], params[:days])

    sorted_games = sort_by_day(filtered_games)
    location_names = programs.map { |program| program["location"] }

    render locals: { games: sorted_games, locations: (location_names).compact.uniq, programs: programs }
  end

  private

  def sort_by_day(filtered_games)
    return unless filtered_games
    filtered_games.flatten.group_by { |game| (Time.at(game["startTime"]/1000).to_datetime).strftime("%a") }
  end
end
