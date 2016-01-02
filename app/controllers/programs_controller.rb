class ProgramsController < ApplicationController

  def index
    if params[:dates] && params[:dates][:start_date] && params[:dates][:end_date]
      programs = Program.get_for(params[:dates])
    else
      programs ||= Program.get_live
    end

    filtered_games = GameBuilder.new(programs).build_games_for(params[:location], params[:days], params[:dates])

    sorted_games = sort_by_day(filtered_games)
    location_names = Program.get_live.map { |program| program["location"] }

    render locals: { games: sorted_games, locations: (location_names).compact.uniq, programs: programs }
  end

  private

  def sort_by_day(filtered_games)
    return unless filtered_games
    filtered_games.flatten.group_by { |game| ::DateHelper.convert_time_to_date(game["startTime"]).strftime("%a") }
  end
end
