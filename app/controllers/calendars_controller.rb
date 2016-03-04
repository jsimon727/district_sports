class CalendarsController < ApplicationController
  def create
    ::Resque.enqueue(::AutomaticExportWorker)
    redirect_to :back
  end
end
