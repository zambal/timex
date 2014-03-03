# Planned API

Time
=========================

### Creation
- new
- now
- epoch

### Conversion
- to (:usecs | :msecs | :secs | :mins | :hours | :days | :weeks)
- to_timestamp
- from (:usecs | :msecs | :secs | :mins | :hours | :days | :weeks)

### Manipulation
- add
- subtract
- scale

### Comparison
- elapsed
- measure
- diff

Timezone
=========================

- get
- local
- diff

Date
=========================

### Creation
- new
- today
- zero
- epoch

### Informational
- weekday         ("Monday")
- weekday(:short) ("Mon")
- weekday(:iso)   (1)
- day             (of year)
- week            (of year)
- month           ("March")
- month(:short)   ("Mar")
- month(:iso)     (3)
- iso_triplet
- days_in_month   (31)
- is_leap?        (false)
- is_valid?

### Manipulation
- set
- shift

### Comparison
- compare
- diff


DateTime
=========================

### Creation
now
universal
local
epoch
zero

### Informational

Delegates to Date API

### Manipulation
- set
- shift

### Comparison
- compare
- diff


DateTime.Format (protocol)
=========================

- format
- parse


DateTime.Convert (protocol)
=========================

- to_gregorian
- to_erlang
- from_gregorian
- from_erlang

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
