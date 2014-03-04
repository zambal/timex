defimpl DateTime.Convert, for: Date do
  def to_gregorian(%Date{:year => y, :month => m, :day => d}) do
    {{y, m, d}, {0,0,0}, {0, "UTC"}}
  end
  def to_erlang_datetime(%Date{:year => y, :month => m, :day => d}) do
    {{y, m, d}, {0,0,0}}
  end
end

defimpl Time.Convert, for: Date do
  def to_secs(date, :epoch), do: to_secs(date, :zero) - Time.epoch(:secs)
  def to_secs(%Date{:year => y, :month => m, :day => d}, :zero) do
    :calendar.datetime_to_gregorian_seconds({{y, m, d}, {0, 0, 0}})
  end

  def to_days(date, :epoch), do: to_days(date, :zero) - Time.epoch(:days)
  def to_days(%Date{:year => y, :month => m, :day => d}, :zero) do
    :calendar.date_to_gregorian_days({y, m, d})
  end
end