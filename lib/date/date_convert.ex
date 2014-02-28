defprotocol DateTime.Convert do
  def to_gregorian(date)
  def to_erlang_datetime(date)
end

defimpl DateTime.Convert, for: DateTime do
  def to_gregorian(%DateTime{:timezone => timezone} = datetime) do
    %Timezone{:standard_abbreviation => abbrev, :dst_abbreviation => dst_abbrev, :gmt_offset_std => std, :gmt_offset_dst => dst} = timezone

    # Use the correct abbreviation depending on whether we're in DST or not
    {date, time} = datetime |> to_erlang_datetime
    if Timezone.Dst.is_dst?(datetime) do
      {date, time, {(std + dst) / 60, dst_abbrev}}
    else
      {date, time, {std / 60, abbrev}}
    end
  end
  def to_erlang_datetime(%DateTime{:date => date, :time => time}) do
    %Date{:year => y, :month => m, :day => d}            = date
    %Time{:hours => h, :minutes => min, :seconds => sec} = time
    {{y, m, d}, {h, min, sec}}
  end
end

defimpl DateTime.Convert, for: Date do
  def to_gregorian(%Date{:year => y, :month => m, :day => d}) do
    {{y, m, d}, {0,0,0}, {0, "UTC"}}
  end
  def to_erlang_datetime(%Date{:year => y, :month => m, :day => d}) do
    {{y, m, d}, {0,0,0}}
  end
end