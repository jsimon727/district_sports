class ProgramsController < ApplicationController

  def index
    programs ||= Program.get_live

    start_date = requested_datetime.beginning_of_week
    end_date = requested_datetime.end_of_week

    filtered_games = GameBuilder.new(programs).build_games_between(start_date, end_date)
    sorted_games = filtered_games.group_by { |game| game["start"]["dateTime"].strftime("%a") }
    week_view = true

    location_names = Program.get_live.map { |program| program["location"] }

    if request.xhr?
      render partial: "games/index", locals: { week_view: week_view, bow: start_date, eow: end_date, games: sorted_games }
    else
      render "index", locals: { week_view: week_view, bow: start_date, eow: end_date, games: sorted_games, locations: (location_names).compact.uniq }
    end
  end


  private

  def requested_datetime
    if params[:week_dates].present?
      if params[:week_dates][:next] == "true"
        params[:week_dates][:bow].to_datetime + 7.days
      else
        params[:week_dates][:bow].to_datetime - 7.days
      end
    else
      Date.today
    end
  end
end

