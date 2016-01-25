class ProgramsController < ApplicationController

  def index
    # if params[:dates].present? && params[:dates][:start_date].present? && params[:dates][:end_date].present?
      # programs = Program.get_for(params[:dates])
    # else
      # programs ||= Program.get_live
    # end

    programs ||= Program.get_live
    bow = requested_datetime.beginning_of_week
    eow = requested_datetime.end_of_week

    # filtered_games = GameBuilder.new(programs).build_games_for(params[:location], params[:days], params[:dates])

    filtered_games = GameBuilder.new(programs).build_games_between(bow, eow)
    sorted_games = filtered_games.group_by { |game| game["startTime"].strftime("%a") }

    # sorted_games = ::Resque.enqueue(::GameIndexWorker, bow, eow)

    # sorted_games = group_by_day(filtered_games)
    location_names = Program.get_live.map { |program| program["location"] }

    if request.xhr?
      render partial: "games/index", locals: { bow: bow, eow: eow, games: sorted_games }
    else
      render "index", locals: { bow: bow, eow: eow, games: sorted_games, locations: (location_names).compact.uniq, programs: programs }
    end
  end


  private

  # def group_by_day(filtered_games)
    # return unless filtered_games
    # filtered_games.group_by { |game| game["startTime"].strftime("%a") }
  # end

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

