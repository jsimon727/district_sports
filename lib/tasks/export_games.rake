task :export_games => :environment do 
  ::Resque.enqueue(::AutomaticExportWorker)
end
