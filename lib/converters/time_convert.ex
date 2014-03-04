defprotocol Time.Convert do
  def to_secs(date_or_time, reference_date)
  def to_days(date_or_time, reference_date)
end