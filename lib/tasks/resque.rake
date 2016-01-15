require "resque/tasks"

task "resque:setup" => :environment do
  Resque.before_first_fork = Proc.new { ActiveRecord::Base.establish_connection }
end
