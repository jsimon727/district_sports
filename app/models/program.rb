class Program < ActiveRecord::Base
  CURRENT_GAMES_URL = "http://api.leagueapps.com/v1/sites/#{Api::LEAGUE_APPS_SITE_ID}/programs/current?x-api-key=#{Api::LEAGUE_APPS_API}"

  def self.get_current
    HTTParty.get(CURRENT_GAMES_URL)
  end

end
