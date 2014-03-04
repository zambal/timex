# Planned API

### Types
unit_of_time = :usecs | :msecs | :secs | :mins | :hours | :days | :weeks | :timestamp
reference_date = :epoch | :zero

Time
=========================

### Creation
- new() :: Time
- now(reference_date) :: Time
- new(hours, minutes, seconds) :: Time
- new(hours, minutes, seconds, milliseconds) :: Time
- new(hours, minutes, seconds, milliseconds, microseconds) :: Time
- epoch() :: Time

### Conversion
- to(value, unit_of_time, reference_date) :: integer
- from(value, unit_of_time, reference_date) :: Time

### Manipulation
- add(value, unit_of_time) :: Time
- subtract(value, unit_of_time) :: Time
- scale(multiplier) :: Time

### Comparison
- elapsed(Time) :: Time
- measure(action) :: Time
- diff(Time, Time) :: Time

### Parsing/Formatting
- Delegates to DateFormat

Timezone
=========================

- get() :: Timezone
- get(name) :: Timezone
- utc() :: Timezone
- local()
- diff(Timezone, Timezone) :: offset_from_utc_minutes
- convert(DateTime, Timezone) :: DateTime

Date (done)
=========================

### Creation
- new()
- new(year, month, day)
- today()
- zero()
- epoch()

### Informational
- weekday(integer)         # ("Monday")
- weekday(integer, :short) # ("Mon")
- iso_weekday(name)        # (1)
- day(Date)                # (of year)
- week(Date)               # (of year)
- month(integer)           # ("March")
- month(integer, :short)   # ("Mar")
- iso_month(name)          # (3)
- iso_triplet(Date)        # ({year, week_num, day_num})
- days_in_month(Date)      # (31)
- is_leap?(year)           # (false)
- is_valid?(Date)

### Manipulation
- set(Date, [{datetime_property: integer}])
- add(Date, [{datetime_property: integer}])
- subtract(Date, [{datetime_property: integer}])

### Comparison
- compare(Date, Date) :: -1 | 0 | 1
- equal(Date, Date) :: boolean
- diff(Date, Date) :: difference_in_days


### Parsing/Formatting
- Delegates to DateFormat


DateTime
=========================

### Creation
new()
new(year, month, day)
new(year, month, day, timezone)
new(year, month, day, hours, minutes, seconds)
new(year, month, day, hours, minutes, seconds, timezone)
now()
universal()
local()
epoch()
zero()

### Informational

- Delegates to Date API where applicable.

### Manipulation
- set(DateTime, [{datetime_property: integer}])
- add(DateTime, [{datetime_property: integer}])
- subtract(DateTime, [{datetime_property: integer}])

### Comparison
- compare(DateTime, DateTime) :: -1 | 0 | 1
- diff(DateTime, DateTime) :: difference_in_microseconds

### Parsing/Formatting
- Delegates to DateFormat


DateTime.Format (protocol)
=========================

- format
- parse


DateTime.Convert (protocol)
=========================

- to_gregorian
- to_erlang
- to_julian_day
- from_gregorian
- from_erlang
- from_julian_day

Time.Convert (protocol)
=========================

- to_timestamp
- to_seconds
- to_days
- from_timestamp
- from_seconds
- from_days

TimeRange (protocol)
=========================

- within


DateTime.Recur
=========================

## Data

defrecordp :recurrence
  start:  :infinite | DateTime
  end:    :infinite | DateTime
  type:   :hours | :days | :weeks | :months
  every:  [integer] | [day_name] | [month_name]
  except: [DateTime]

## API

- create
- match?
- next
- previous
