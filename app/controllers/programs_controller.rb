class ProgramsController < ApplicationController
  def index
    programs ||= Program.build_live
    games ||= GameBuilder.new(programs).sorted_games

    render locals: { games: games }
  end
end
