defmodule Time do
  @module """
  Functions for performing conversion and arithmetic on times down to microsecond precision.
  Time does not contain any date or timezone information.
  """

  # Easier to read names for common values
  @microsecs_per_sec 1_000_000
  @millisecs_per_sec 1000
  @seconds_per_min   60
  @seconds_per_hour  3600
  @seconds_per_day   (3600 * 24)
  @seconds_per_week  (3600 * 24 * 7)
  @epoch_timestamp   {{1970,1,1},{0,0,0}}

  @type unit_of_time :: :usecs | :msecs | :secs | :mins | :hours | :days | :weeks
  @type megaseconds  :: integer
  @type seconds      :: integer
  @type microseconds :: integer
  @type timestamp    :: {megaseconds, seconds, microseconds}

  ####
  # This structure is used to represent either a static point in time,
  # or the difference in time between two points. For example:
  # 
  # t = Time.now
  # Time.elapsed(t) #=> %Time{hours: 0, minutes: 0, seconds: 10, ms: 245, ns: 890}
  # Wait one hour...
  # t2 = Time.now
  # Time.elapsed(t, t2) #=> %Time{hours: 1, minutes: 2, seconds: 37, ms: 10, ns: 301}
  ####
  defstruct hours: 0, minutes: 0, seconds: 0, ms: 0, us: 0

  @doc """
  Create a new Time object.

  Called with no parameters will return zero time (00:00:00:000:000),
  or you can provide a time tuple from :erlang.now or :os.timestamp,
  or one of your own construction elsewhere in your application.
  """
  #@spec new() :: Time.t
  #@spec new(timestamp) :: Time.t
  def new() do
    %Time{hours: 0, minutes: 0, seconds: 0, ms: 0, us: 0}
  end
  def new({_, _, _} = timestamp) do
    period = convert(timestamp, :hours)
    hours  = trunc(period)
    period = to_mins(period - hours, :hours)
    mins   = trunc(period)
    period = to_secs(period - mins, :mins)
    secs   = trunc(period)
    period = to_msecs(period - secs, :secs)
    msecs  = trunc(period)
    period = to_usecs(period - msecs, :msecs)
    usecs  = period |> Float.round(0) |> trunc
    %Time{hours: hours, minutes: mins, seconds: secs, ms: msecs, us: usecs}
  end
  def new({{_,_,_},{_,_,_} = time}), do: new(time)

  @doc """
  Return a value representing the time interval between Epoch and now.

  The argument is an atom indicating the type of time units to return:

  :usecs, :msecs, :secs, :mins, :hours, :days, :weeks

  When no argument is provided, a Time struct is returned by default
  """
  #@spec now() :: Time.t
  #@spec now(unit_of_time) :: integer
  def now(),     do: :os.timestamp |> new
  def now(type), do: :os.timestamp |> convert(type)

  @doc """
  Return a Time struct representing the time interval since the first day of year 0 to Epoch.
  """
  #@spec epoch() :: Time.t
  #@spec epoch(unit_of_time) :: integer
  def epoch(),     do: convert_epoch_seconds(:timestamp) |> new
  def epoch(type), do: convert_epoch_seconds(:timestamp) |> convert(type)

  ####
  # Time Conversions
  ####

  @doc """
  Convert a number in the given unit of measurement, to the equivalent number of microseconds
  """
  @spec to_usecs(integer, atom()) :: integer
  @doc """
  Convert a number in the given unit of measurement, to the equivalent number of milliseconds
  """
  @spec to_msecs(integer, atom()) :: integer
  @doc """
  Convert a number in the given unit of measurement, to the equivalent number of seconds
  """
  @spec to_secs(integer, atom()) :: integer
  @doc """
  Convert a number in the given unit of measurement, to the equivalent number of minutes
  """
  @spec to_mins(integer, atom()) :: integer
  @doc """
  Convert a number in the given unit of measurement, to the equivalent number of hours
  """
  @spec to_hours(integer, atom()) :: integer
  @doc """
  Convert a number in the given unit of measurement, to the equivalent number of days
  """
  @spec to_days(integer, atom()) :: integer
  @doc """
  Convert a number in the given unit of measurement, to the equivalent number of weeks
  """
  @spec to_weeks(integer, atom()) :: integer

  # Construct the conversions
  Enum.each [usecs: @microsecs_per_sec, msecs: @millisecs_per_sec], fn {type, coef} ->
    if type != :usecs do
      def to_usecs(value, unquote(type)), do: value * @microsecs_per_sec / unquote(coef)
    end
    if type != :msecs do
      def to_msecs(value, unquote(type)), do: value * @millisecs_per_sec / unquote(coef)
    end
    def to_secs(value, unquote(type)),  do: value / unquote(coef)
    def to_mins(value, unquote(type)),  do: value / unquote(coef) / @seconds_per_min
    def to_hours(value, unquote(type)), do: value / unquote(coef) / @seconds_per_hour
    def to_days(value, unquote(type)),  do: value / unquote(coef) / @seconds_per_day
    def to_weeks(value, unquote(type)), do: value / unquote(coef) / @seconds_per_week
  end
  Enum.each [secs: 1, mins: @seconds_per_min, hours: @seconds_per_hour, days: @seconds_per_day, weeks: @seconds_per_week], fn {type, coef} ->
    def unquote(type)(value), do: value * unquote(coef)
    def to_usecs(value, unquote(type)), do: value * unquote(coef) * @microsecs_per_sec
    def to_msecs(value, unquote(type)), do: value * unquote(coef) * @millisecs_per_sec
    if type != :secs do
      def to_secs(value, unquote(type)),  do: value * unquote(coef)
    end
    if type != :mins do
      def to_mins(value, unquote(type)),  do: value * unquote(coef) / @seconds_per_min
    end
    if type != :hours do
      def to_hours(value, unquote(type)), do: value * unquote(coef) / @seconds_per_hour
    end
    if type != :days do
      def to_days(value, unquote(type)),  do: value * unquote(coef) / @seconds_per_day
    end
    if type != :weeks do
      def to_weeks(value, unquote(type)), do: value * unquote(coef) / @seconds_per_week
    end
  end

  @doc """
  Convert a Time object to microseconds
  """
  #@spec to_usecs(Time.t | timestamp) :: integer
  def to_usecs({mega, sec, micro}), do: (mega * @microsecs_per_sec + sec) * @microsecs_per_sec + micro
  def to_usecs(%{:hours => h, :minutes => m, :seconds => s, :ms => ms, :us => us}) do
    (h * @seconds_per_hour * @microsecs_per_sec) +
    (m * @seconds_per_min  * @microsecs_per_sec) +
    (s * @microsecs_per_sec) +
    (ms * @microsecs_per_sec / 1_000) + us
  end
  @doc """
  Convert a Time object to milliseconds
  """
  #@spec to_msecs(Time.t | timestamp) :: integer
  def to_msecs({mega, sec, micro}), do: (mega * @microsecs_per_sec + sec) * 1000 + micro / 1000
  def to_msecs(time), do: to_usecs(time) / 1_000
  @doc """
  Convert a Time object to seconds
  """
  #@spec to_secs(Time.t | timestamp) :: integer
  def to_secs({mega, sec, micro}),  do: mega * @microsecs_per_sec + sec + micro / @microsecs_per_sec
  def to_secs(time), do: to_usecs(time) / @microsecs_per_sec
  @doc """
  Convert a Time object to minutes
  """
  #@spec to_mins(Time.t | timestamp) :: integer
  def to_mins({_,_,_} = timestamp), do: to_secs(timestamp) / @seconds_per_min
  def to_mins(time), do: to_secs(time) / @seconds_per_min
  @doc """
  Convert a Time object to hours
  """
  #@spec to_hours(Time.t | timestamp) :: integer
  def to_hours({_,_,_} = timestamp), do: to_secs(timestamp) / @seconds_per_hour
  def to_hours(time), do: to_secs(time) / @seconds_per_hour
  @doc """
  Convert a Time object to days
  """
  #@spec to_days(Time.t | timestamp) :: integer
  def to_days({_,_,_} = timestamp), do: to_secs(timestamp) / @seconds_per_day
  def to_days(time), do: to_secs(time) / @seconds_per_day
  @doc """
  Convert a Time object to weeks
  """
  #@spec to_weeks(Time.t | timestamp) :: integer
  def to_weeks({_,_,_} = timestamp), do: to_secs(timestamp) / @seconds_per_week
  def to_weeks(time), do: to_secs(time) / @seconds_per_week


  @doc """
  Convert either a Time struct, or an integer value in the given unit of time
  to an Erlang timestamp: {megaseconds, seconds, microseconds}
  """
  #@spec to_timestamp(Time.t) :: timestamp
  #@spec to_timestamp(integer, unit_of_time) :: timestamp

  def to_timestamp(%{} = time), do: time |> to_usecs |> to_timestamp(:usecs)
  def to_timestamp(value, :usecs) do
    { secs, microsecs } = mdivmod(value)
    { megasecs, secs }  = mdivmod(secs)
    {megasecs, secs, microsecs}
  end
  def to_timestamp(value, :msecs) do
    { secs, microsecs } = divmod(value, 1000)
    { megasecs, secs }  = mdivmod(secs)
    {megasecs, secs, microsecs}
  end
  def to_timestamp(value, :secs) do
    secs      = trunc(value)
    microsecs = trunc((value - secs) * @microsecs_per_sec)
    { megasecs, secs } = mdivmod(secs)
    {megasecs, secs, microsecs}
  end
  def to_timestamp(value, :mins),  do: to_timestamp(value * @seconds_per_min, :secs)
  def to_timestamp(value, :hours), do: to_timestamp(value * @seconds_per_hour, :secs)
  def to_timestamp(value, :days),  do: to_timestamp(value * @seconds_per_day, :secs)
  def to_timestamp(value, :weeks), do: to_timestamp(value * @seconds_per_week, :secs)


  @doc """
  Convert from a value in the given unit of time to a Time struct
  """
  #@spec from(integer, unit_of_time) :: Time.t
  def from(value, :usecs) do
    { sec, micro } = mdivmod(value)
    { mega, sec }  = mdivmod(sec)
    { mega, sec, micro } |> new
  end
  def from(value, :msecs) do
    #micro = value * 1000
    { sec, micro } = divmod(value, 1000)
    { mega, sec }  = mdivmod(sec)
    { mega, sec, micro } |> new
  end
  def from(value, :secs) do
    # trunc ...
    { sec, micro } = mdivmod(value)
    { mega, sec }  = mdivmod(sec)
    { mega, sec, micro } |> new
  end
  def from(value, :hours), do: value |> to_usecs(:hours) |> from(:usecs)
  def from(value, :days),  do: value |> to_usecs(:days)  |> from(:usecs)
  def from(value, :weeks), do: value |> to_usecs(:weeks) |> from(:usecs)

  ####
  # Time Arithmetic
  # Add, Subtract, Scale, Invert, Absolute Value
  ####

  @doc """
  Add one time to another.
  The first parameter is the time to add to, the second one, the value to add.
  """
  #@spec add(Time.t, Time.t) :: Time.t
  def add(%{} = time1, %{} = time2) do
    time1_usecs = time1 |> to_usecs
    time2_usecs = time2 |> to_usecs
    (time1_usecs + time2_usecs) |> from(:usecs)
  end

  @doc """
  Subtract one time from another.
  The first parameter is the time to subtract from, the second one, the value to subtract.
  """
  #@spec subtract(Time.t, Time.t) :: Time.t
  def subtract(%{} = time1, %{} = time2) do
    time1_usecs = time1 |> to_usecs
    time2_usecs = time2 |> to_usecs
    (time1_usecs - time2_usecs) |> from(:usecs)
  end

  @doc """
  Scale a time by the given amount.
  """
  #@spec scale(Time.t, integer) :: Time.t
  def scale(%{} = time, factor) do
    cond do
      factor == 0 -> Time.new
      true        -> (to_usecs(time) * factor) |> from(:usecs)
    end
  end

  ####
  # Time Intervals
  # - Determine the difference between two times.
  # - Get the time elapsed between a given time and now.
  # - Measure the time it takes to execute a function.
  ####

  @doc """
  Time interval between the given time and now. If the time is in the future the
  return value will be negative.

  The second argument is an atom indicating the type of time units to return:
  microseconds (:usec), milliseconds (:msec), seconds (:sec), minutes (:min),
  or hours (:hour).

  When the second argument is omitted, the return value's format is a new Time struct.
  """
  #@spec elapsed(Time.t, unit_of_time) :: integer
  def elapsed(%{} = time, type \\ nil) do
    cond do
      type == nil -> now |> diff(time)
      true        -> now |> diff(time, type)
    end
  end

  @doc """
  Time interval between two timestamps. If the first timestamp comes before the
  second one in time, the return value will be negative.

  The third argument is an atom indicating the type of time units to return:
  microseconds (:usec), milliseconds (:msec), seconds (:sec), minutes (:min),
  or hours (:hour).

  When the third argument is omitted, the return value's format is { megasecs,
  seconds, microsecs }.
  """
  #@spec diff(Time.t, Time.t) :: Time.t
  #@spec diff(Time.t, Time.t, unit_of_time) :: integer

  def diff(%{} = t1, %{} = t2) do
    ((t1 |> to_usecs) - (t2 |> to_usecs)) |> from(:usecs)
  end
  def diff(%{} = t1, %{} = t2, type) do
    diff(t1, t2) |> to_timestamp |> convert(type)
  end

  @doc """
  Measure the time it takes to execute the given function.
  """
  #@spec measure(fun, [term] | nil) :: Time.t
  #@spec measure(term, fun, [term] | nil) :: Time.t

  def measure(fun),                  do: measure_result(:timer.tc(fun))
  def measure(fun, args),            do: measure_result(:timer.tc(fun, args))
  def measure(module, fun, args),    do: measure_result(:timer.tc(module, fun, args))
  defp measure_result({micro, ret}), do: { from(micro, :usecs), ret }

  # Conver the seconds from year zero to Epoch to a timestamp tuple
  defp convert_epoch_seconds(:timestamp) do
    seconds = :calendar.datetime_to_gregorian_seconds(@epoch_timestamp)
    { mega, sec } = mdivmod(seconds)
    { mega, sec, 0 }
  end

  ####
  # Convert timestamp in the form { megasecs, seconds, microsecs } to the
  # specified time units.
  #
  # Supported units: microseconds (:usec), milliseconds (:msec), seconds (:sec),
  # minutes (:min), hours (:hour), days (:day), or weeks (:week).
  ####
  defp convert(timestamp, :usecs), do: to_usecs(timestamp)
  defp convert(timestamp, :msecs), do: to_msecs(timestamp)
  defp convert(timestamp, :secs),  do: to_secs(timestamp)
  defp convert(timestamp, :mins),  do: to_mins(timestamp)
  defp convert(timestamp, :hours), do: to_hours(timestamp)
  defp convert(timestamp, :days),  do: to_days(timestamp)
  defp convert(timestamp, :weeks), do: to_weeks(timestamp)

  defp divmod(a, b) do
    { div(a |> trunc, b |> trunc), rem(a |> trunc, b |> trunc) }
  end

  defp mdivmod(a) do
    divmod(a, @microsecs_per_sec)
  end
end
