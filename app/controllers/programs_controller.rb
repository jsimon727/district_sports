class ProgramsController < ApplicationController

  def index
    programs ||= Program.get_live

    if params[:dates].present?
      start_date = params[:dates][:start_date].present? ?
        DateHelper.convert_date_to_datetime(params[:dates][:start_date]) : Date.today
      end_date = params[:dates][:end_date].present? ?
        DateHelper.convert_date_to_datetime(params[:dates][:end_date]) : Date.today + 7.days
    else
      start_date = Date.today
      end_date = Date.today + 7.days
    end

    filtered_games = GameBuilder.new(programs).build_games_between(start_date, end_date)
    sorted_games = filtered_games.sort_by { |game| game["start"]["dateTime"].to_datetime }.group_by { |game| game["start"]["dateTime"].to_datetime.strftime("%B %e") }

    render "index", locals: { games: sorted_games }
  end
end

