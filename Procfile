web: bundle exec rails server -p $PORT
redis: redis-server
worker: env QUEUE=* bundle exec rake environment resque:work
