class Game
  LEAGUE_APPS_API = Rails.application.secrets.league_apps_api
  LEAGUE_APPS_SITE_ID = Rails.application.secrets.league_apps_site_id
  CURRENT_GAMES_URL = "http://api.leagueapps.com/v1/sites/#{LEAGUE_APPS_SITE_ID}/programs/current?x-api-key=#{LEAGUE_APPS_API}"

  def self.get_current
    HTTParty.get(CURRENT_GAMES_URL)
  end
end
