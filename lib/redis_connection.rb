class RedisConnection

  def self.close
    connection.quit
  end

  def self.connection
    @connection ||= new_connection
  end

  private

  def self.new_connection
		host = URI.parse(ENV["REDISCLOUD_URL"]).try(:host)
		port = URI.parse(ENV["REDISCLOUD_URL"]).try(:port)
		password = URI.parse(ENV["REDISCLOUD_URL"]).try(:password)
		Redis.new(:host => host, :port => port, :password => password)
  end
end
