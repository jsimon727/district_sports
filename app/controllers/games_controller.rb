class GamesController < ApplicationController
  def index
    response = Game.get_current
    render locals: { games: response }
  end
end
