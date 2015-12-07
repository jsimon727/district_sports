class ProgramsController < ApplicationController
  def index
    programs ||= Program.build_current
    games ||= Game.build_for(programs)

    render locals: { games: games }
  end
end
