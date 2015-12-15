class ProgramsController < ApplicationController
  def index
    programs ||= Program.build_live

    if params[:location]
      filtered_games = GameBuilder.new(programs).build_games_for(params[:location])
      games = sort_by_day(filtered_games)
    else
      filtered_games = GameBuilder.new(programs).build_games
      games = sort_by_day(filtered_games)
    end

    render locals: { games: games, locations: programs.map(&:location).compact.uniq, programs: programs }
  end

  private

  def sort_by_day(filtered_games)
    sorted_games = Hash.new
    day_games = Array.new

    filtered_games.map do |game|
      sorted_games[game.start_time.strftime("%a")] = (day_games << game)
    end

    sorted_games
  end
end
