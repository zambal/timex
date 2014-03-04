defmodule Date do
  @moduledoc """
  This module defines behavior for calendar dates.
  """
  defstruct year: 0, month: 1, day: 1, calendar: :gregorian

  ### Date types

  @type year     :: non_neg_integer
  @type month    :: 1..12
  @type day      :: 1..31
  @type daynum   :: 1..366
  @type date     :: {year, month, day}
  @type weekday  :: 1..7
  @type weeknum  :: 1..53
  @type datetime :: {{year, month, day}, {non_neg_integer, non_neg_integer, non_neg_integer}}

  ### Constants

  @million 1_000_000
  @weekdays [ 
    {"Monday", 1}, {"Tuesday", 2}, {"Wednesday", 3}, {"Thursday", 4},
    {"Friday", 5}, {"Saturday", 6}, {"Sunday", 7}
  ]
  @months [ 
    {"January", 1},  {"February", 2},  {"March", 3},
    {"April", 4},    {"May", 5},       {"June", 6},
    {"July", 7},     {"August", 8},    {"September", 9},
    {"October", 10}, {"November", 11}, {"December", 12}
  ]

  ### Creation

  @doc """
  Create a new Date struct
  """
  #@spec new() :: Date.t
  #@spec new(year, month, day) :: Date.t
  def new(), do: %Date{}
  def new(year, month, day), do: %Date{year: year, month: month, day: day}

  @doc """
  Get today's date.
  """
  #@spec today() :: Date.t
  def today(), do: :calendar.local_time |> datetime_to_date

  @doc """
  Get the date representing the start of the Gregorian calendar.
  """
  #@spec zero() :: Date.t
  def zero(), do: %Date{year: 0, month: 1, day: 1}

  @doc """
  Get the date representing the start of Epoch
  """
  #@spec epoch() :: Date.t
  def epoch(), do: %Date{year: 1970, month: 1, day: 1}

  ### Informational

  @doc """
  Convert the integer representation of a weekday, to it's proper name.
  Pass :short, if you want the abbreviated name.

  ## Examples

    Date.weekday(1)         #=> "Monday"
    Date.weekday(1, :short) #=> "Mon"

  """
  @spec weekday(weekday) :: binary
  @spec weekday(weekday, :short) :: binary
  @weekdays |> Enum.each fn {name, day_num} ->
    def weekday(unquote(day_num)),         do: unquote(name)
    def weekday(unquote(day_num), :short), do: unquote(name) |> String.slice(0..2)
  end
  def weekday(x), do: raise("Invalid weekday value!", x)

  @doc """
  Get the ordinal number of the day of the week corresponding to the given name.

  ## Examples

    Date.iso_weekday("Monday")  => 1
    Date.iso_weekday("Mon")     => 1
    Date.iso_weekday("monday")  => 1
    Date.iso_weekday("mon")     => 1

  """
  @spec iso_weekday(binary) :: integer
  @weekdays |> Enum.each fn {day_name, day_num} ->
    lower      = day_name |> String.downcase
    abbr_cased = day_name |> String.slice(0..2)
    abbr_lower = lower |> String.slice(0..2)

    day_quoted = quote do
      def iso_weekday(unquote(day_name)),   do: unquote(day_num)
      def iso_weekday(unquote(lower)),      do: unquote(day_num)
      def iso_weekday(unquote(abbr_cased)), do: unquote(day_num)
      def iso_weekday(unquote(abbr_lower)), do: unquote(day_num)
    end
    Module.eval_quoted __MODULE__, day_quoted, [], __ENV__
  end
  def iso_weekday(x), do: raise("Invalid name for a day of the week!", x)

  @doc """
  Returns the ordinal day number of the date.
  """
  #@spec day(Date.t) :: daynum
  def day(%Date{} = date) do
    start_of_year = %Date{date | :month => 1, :day => 1}
    1 + diff(start_of_year, date, :days)
  end

  @doc """
  Return a pair {year, week number} (as defined by ISO 8601) that date falls
  on.

  ## Examples

      Date.epoch |> Date.iso_week  #=> {1970,1}

  """
  #@spec week(Date.t) :: {year, weeknum}
  def week(%Date{:year => y, :month => m, :day => d}) do
    :calendar.iso_week_number({y, m, d})
  end

  @doc """
  Convert the integer representation of a month, to it's proper name.
  Pass :short, if you want the abbreviated name.

  ## Examples

    Date.month(1)         #=> "January"
    Date.month(1, :short) #=> "Jan"

  """
  @spec month(integer) :: binary
  @spec month(integer, :short) :: binary
  @months |> Enum.each fn {name, month_num} ->
    def month(unquote(month_num)),         do: unquote(name)
    def month(unquote(month_num), :short), do: unquote(name) |> String.slice(0..2)
  end
  def month(x), do: raise("Invalid month number!", x)

  @doc """
  Get the number of the month corresponding to the given name.

  ## Examples

    Date.iso_month("January") => 1
    Date.iso_month("Jan")     => 1
    Date.iso_month("january") => 1
    Date.iso_month("jan")     => 1

  """
  @spec iso_month(binary) :: integer
  @months |> Enum.each fn {month_name, month_num} ->
    lower      = month_name |> String.downcase
    abbr_cased = month_name |> String.slice(0..2)
    abbr_lower = lower      |> String.slice(0..2)

    month_quoted = quote do
      def iso_month(unquote(month_name)), do: unquote(month_num)
      def iso_month(unquote(lower)),      do: unquote(month_num)
      def iso_month(unquote(abbr_cased)), do: unquote(month_num)
      def iso_month(unquote(abbr_lower)), do: unquote(month_num)
    end
    Module.eval_quoted __MODULE__, month_quoted, [], __ENV__
  end
  def iso_month(x), do: raise("Invalid month name!", x)

  @doc """
  Return a 3-tuple {year, week number, weekday} for the given date.

  ## Examples

      Date.epoch |> Date.iso_triplet  #=> {1970, 1, 4}

  """
  #@spec iso_triplet(DateTime.t) :: {year, weeknum, weekday}

  def iso_triplet(%Date{} = date) do
    { iso_year, iso_week } = week(date)
    { iso_year, iso_week, weekday(date.day) }
  end

  @doc """
  Return the number of days in the month which the date falls on.

  ## Examples

      Date.epoch |> Date.days_in_month  #=> 31

  """
  #@spec days_in_month(Date.t) :: day
  #@spec days_in_month(year, month) :: day
  def days_in_month(%Date{:year => year, :month => month}) do
    :calendar.last_day_of_the_month(year, month)
  end
  def days_in_month(year, month) do
    :calendar.last_day_of_the_month(year, month)
  end

  @doc """
  Return a boolean indicating whether the given year is a leap year. You may
  pase a date or a year number.

  ## Examples

      Date.epoch |> Date.is_leap?  #=> false
      Date.is_leap?(2012)          #=> true

  """
  #@spec is_leap?(Date.t | year) :: boolean
  def is_leap?(year) when is_integer(year), do: :calendar.is_leap_year(year)
  def is_leap?(%Date{:year => year}),       do: is_leap?(year)

  @doc """
  Return a boolean indicating whether the given date is valid.
  """
  @spec is_valid?(Date.t) :: boolean
  def is_valid?(%Date{:year => year, :month => month, :day => day}) do
    :calendar.valid_date({year, month, day})
  end

  ### Manipulation

  @doc """
  Convenience function for updating a date's values.

  ## Examples

    Date.epoch |> Date.set(year: 1980)           #=> %Date{year: 1980, month: 1, day: 1}
    Date.epoch |> Date.set([year: 1980, day: 5]) #=> %Date{year: 1980, month: 1, day: 5}
  """
  #@spec set(Date.t, [{:year | :month | :day, integer}])
  def set(%Date{} => date, args) do
    args |> Enum.reduce date, fn
      {:year, year}   -> %Date{date | :year => year}
      {:month, month} -> %Date{date | :month => month}
      {:day, day}     -> %Date{date | :day => day}
    end
  end

  @doc """
  Add time to a date using a timestamp, i.e. {megasecs, secs, microsecs}
  Same as shift(date, Time.to_timestamp(5, :mins), :timestamp).
  """
  @spec add(Date.t, [{:years | :months | :days, integer}])
  defp add(%Date{} = date, args) do
    date |> shift(args)
  end

  @doc """
  Subtract time from a date using a timestamp, i.e. {megasecs, secs, microsecs}
  Same as shift(date, Time.to_timestamp(5, :mins) |> Time.invert, :timestamp).
  """
  @spec subtract(Date.t, [{:years | :months | :days, integer}])
  defp subtract(%Date{} = date, args) do
    date |> shift(date, args)
  end

  ### Comparison

  @doc """
  Compare two dates returning one of the following values:

   * `-1` -- `this` comes after `other`
   * `0`  -- Both arguments represent the same date when coalesced to the same timezone.
   * `1`  -- `this` comes before `other`

  """
  #@spec compare(Date.t, Date.t | :epoch | :zero | :distant_past | :distant_future) :: -1 | 0 | 1

  def compare(%Date{} = date, :epoch),  do: compare(date, epoch())
  def compare(%Date{} = date, :zero),   do: compare(date, zero())
  def compare(_, :distant_past),        do: -1
  def compare(_, :distant_future),      do: 1
  def compare(date, date),              do: 0
  def compare(%Date{} = this, %Date{} = other) do
    difference = diff(this, other, :days)
    cond do
      difference < 0  -> -1
      difference == 0 -> 0
      difference > 0  -> 1
    end
  end

  @doc """
  Determine if two dates represent the same point in time
  """
  #@spec equal?(Date.t, Date.t) :: boolean
  def equal?(this, other), do: compare(this, other) == 0

  @doc """
  Calculate time interval between two dates. If the second date comes after the
  first one in time, return value will be positive; and negative otherwise.
  """
  #@spec diff(Date.t, Date.t, :timestamp) :: timestamp
  #@spec diff(Date.t, Date.t, :secs | :days | :weeks | :months | :years) :: integer

  def diff(this, other, :timestamp) do
    diff(this, other, :secs) |> Time.from_sec
  end
  def diff(this, other, :secs) do
    to_secs(other, :zero) - Time.Convert.to_secs(this, :zero)
  end
  def diff(this, other, :mins) do
    (to_secs(other, :zero) - Time.Convert.to_secs(this, :zero)) |> div(60)
  end
  def diff(this, other, :hours) do
    (to_secs(other, :zero) - Time.Convert.to_secs(this, :zero)) |> div(60) |> div(60)
  end
  def diff(this, other, :days) do
    to_days(other, :zero) - Time.Convert.to_days(this, :zero)
  end
  def diff(this, other, :weeks) do
    # TODO: think of a more accurate method
    diff(this, other, :days) |> div(7)
  end
  def diff(%Date{:year => y1, :month => m1}, %Date{:year => y2, :month => m2}, :months) do
    ((y2 - y1) * 12) + (m2 - m1)
  end
  def diff(%Date{:year => y1}, %Date{:year => y2}, :years) do
    y2 - y1
  end


  ### Private

  #################
  # A single function for adjusting the date using various units: timestamp,
  # seconds, minutes, hours, days, weeks, months, years.
  #
  # When shifting by timestamps, microseconds are ignored.
  #
  # If the list contains `:months` and at least one other unit, an ArgumentError
  # is raised (due to ambiguity of such shifts). You can still shift by months
  # separately.
  #
  # If `:years` is present, it is applied in the last turn.
  #
  # The returned date is always valid. If after adding months or years the day
  # exceeds maximum number of days in the resulting month, that month's last day
  # is used.
  #
  # To prevent day skew, fix up the date after shifting. For example, if you want
  # to land on the last day of the next month, do the following:
  #
  #     shift(date, months: 1) |> set(month: 31)
  #
  ################
  #@spec shift(Date.t, list({atom(), {integer,integer,integer} | integer})) :: Date.t

  defp shift(date, [{_, 0}]),                    do: date
  defp shift(date, [timestamp: {0,0,0}]),        do: date
  defp shift(date, [timestamp: {mega, sec, _}]), do: date |> shift(secs: (mega * @million) + sec)
  defp shift(date, [{type, value}]) when type in [:secs, :mins, :hours] do
    secs = to_secs(date)
    secs = secs + case type do
      :secs   -> value
      :mins   -> value * 60
      :hours  -> value * 3600
    end
    from(secs, :secs)
  end
  defp shift(date, [days: value]) do
    days = Time.Convert.to_days(date)
    days = days + value
    from(days, :days)
  end
  defp shift(date, [weeks: value]) do
    date |> shift([days: value * 7])
  end
  defp shift(%Date{:year => y, :month => m, :day => d}, [months: value]) do
    month = m + value
    # Calculate a valid year value
    year = cond do
      month == 0 -> y - 1
      month < 0  -> y + div(month, 12) - 1
      month > 12 -> y + div(month - 1, 12)
      true       -> y
    end

    {year, DateTime.Utils.interpolate_month(month), day} |> DateTime.Utils.validate |> datetime_to_date
  end
  defp shift(%Date{:year => y, :month => m, :day => d}, [years: value]) do
    {y + value, month, day} |> DateTime.Utils.validate |> datetime_to_date
  end

  defrecordp :shift_rec, secs: 0, days: 0, years: 0

  # This clause will match lists with at least 2 values
  defp shift(date, spec) when is_list(spec) do
    shift_rec(secs: sec, days: day, years: year)
      = Enum.reduce spec, shift_rec(), fn
        ({:timestamp, {mega, tsec, _}}, shift_rec(secs: sec) = rec) ->
          shift_rec(rec, [secs: sec + mega * @million + tsec])

        ({:secs, tsec}, shift_rec(secs: sec) = rec) ->
          shift_rec(rec, [secs: sec + tsec])

        ({:mins, min}, shift_rec(secs: sec) = rec) ->
          shift_rec(rec, [secs: sec + min * 60])

        ({:hours, hrs}, shift_rec(secs: sec) = rec) ->
          shift_rec(rec, [secs: sec + hrs * 3600])

        ({:days, days}, shift_rec(days: day) = rec) ->
          shift_rec(rec, [days: day + days])

        ({:weeks, weeks}, shift_rec(days: day) = rec) ->
          shift_rec(rec, [days: day + weeks * 7])

        ({:years, years}, shift_rec(years: year) = rec) ->
          shift_rec(rec, [years: year + years])

        ({:months, _}, _) ->
          raise ArgumentError, message: ":months not supported in bulk shifts"
      end

    # The order in which we apply secs and days is not important.
    # The year shift must always go last though.
    date |> shift([secs: sec]) |> shift([days: day]) |> shift([years: year])
  end

  defp datetime_to_date({y,m,d}), do: %Date{year: y, month: m, day: d}
  defp datetime_to_date({{y, m, d}, {_,_,_}}), do: %Date{year: y, month: m, day: d}

end
