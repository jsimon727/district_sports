class Program < ActiveRecord::Base
  LIVE_PROGRAMS_URL = "http://api.leagueapps.com/v1/sites/#{Api::LEAGUE_APPS_SITE_ID}/programs/current?x-api-key=#{Api::LEAGUE_APPS_API}&state=LIVE"

  def self.build_live
    response = HTTParty.get(LIVE_PROGRAMS_URL)

    program_ids = response.map do |program|
      program["programId"]
    end

    programs = Program.where("program_id IN (?)", program_ids)

    not_persisted_program_ids ||= (program_ids - programs.map(&:program_id))
    if not_persisted_program_ids.present?
      programs = []
      response.select { |program| not_persisted_program_ids.include?(program["programId"]) }.each do |program|
        programs << Program.where(program_id: program["programId"]).first_or_create(name: program["name"],
                                                                        program_id: program["programId"],
                                                                        location: program["location"],
                                                                        schedule_days: program["scheduleDays"],
                                                                        location_id: program["locationId"])
      end
    end
    programs
  end
end
