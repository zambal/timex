defprotocol DateTime.Convert do
  def to_gregorian(date)
  def to_erlang_datetime(date)
end