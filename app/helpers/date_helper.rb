module DateHelper
  def self.convert_time_to_date(time)
    Time.at(time/1000).to_datetime
  end

  def self.convert_date_to_datetime(date)
   DateTime.strptime(date, '%m/%d/%Y')
  end
end
