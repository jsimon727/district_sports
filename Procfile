web: bundle exec rails server -p $PORT
redis: redis-server
worker: env TERM_CHILD=1 QUEUE=google_calendar_api_queue bundle exec rake environment resque:work
