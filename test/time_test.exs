defmodule TimeTests do
  use ExUnit.Case, async: true

  test :new do
    assert %Time{hours: 0, minutes: 0, seconds: 0, ms: 0, us: 0} = Time.new
    assert %Time{hours: 378491, minutes: 21, seconds: 43, ms: 363, us: 960} = {1362,568903,363960} |> Time.new
  end

  test :epoch do
    assert 62167219200   = {{1970,1,1},{0,0,0}} |> :calendar.datetime_to_gregorian_seconds
    assert 62167219200.0 = Time.epoch |> Time.to_secs
  end

  test :to_timestamp do
    assert {1362,568903,363960} = {1362,568903,363960} |> Time.new |> Time.to_timestamp
  end

  test :add do
    t1 = %Time{hours: 5, minutes: 10, seconds: 20, ms: 15, us: 300}
    t2 = %Time{hours: 5, minutes: 31, seconds: 10, ms: 0, us: 110}
    t3 = %Time{hours: -3, minutes: 10, seconds: 10, ms: 13, us: 100}

    assert %Time{hours: 10, minutes: 41, seconds: 30, ms: 15, us: 410} = Time.add(t1, t2)
    # Even though we subtracted hours, some components still had time added, don't be fooled by the negative on the 3!
    assert %Time{hours: 2, minutes: 20, seconds: 30, ms: 28, us: 400} = Time.add(t1, t3)
  end

  test :subtract do
    t1 = %Time{hours: 5, minutes: 10, seconds: 20, ms: 15, us: 300}
    t2 = %Time{hours: 5, minutes: 31, seconds: 10, ms: 0, us: 110}
    t3 = %Time{hours: -3, minutes: 10, seconds: 10, ms: 13, us: 100}

    # Subtracting a larger time from a smaller one will result in a negative time interval
    assert %Time{hours: 0, minutes: -20, seconds: -49, ms: -984, us: -810} = Time.subtract(t1, t2)
    # Subtracting a negative number acts just like you'd expect: adds a positive number
    assert %Time{hours: 8, minutes: 0, seconds: 10, ms: 2, us: 200} = Time.subtract(t1, t3)
  end

  test :scale do
    t1 = %Time{hours: 5, minutes: 10, seconds: 20, ms: 15, us: 300}

    assert %Time{hours: 10, minutes: 20, seconds: 40, ms: 30, us: 600} = Time.scale(t1, 2)
  end

  test :diff do
    t1 = {1362,568903,363960} |> Time.new
    t2 = {1362,568958,951099} |> Time.new
    assert Time.diff(t2, t1) == {0, 55, 587139} |> Time.new
    assert Time.diff(t2, t1, :usecs) == 55587139
    assert Time.diff(t2, t1, :msecs) == 55587.139
    assert Time.diff(t2, t1, :secs)  == 55.587139
    assert Time.diff(t2, t1, :mins)  == 55.587139 / 60
    assert Time.diff(t2, t1, :hours) == 55.587139 / 3600
  end

  test :to_usecs do
    assert {1362, 568903, 363960} |> Time.new |> Time.to_usecs == 1362568903363960
    assert Time.to_usecs(13, :msecs) == 13000
    assert Time.to_usecs(13, :secs)  == 13000000
    assert Time.to_usecs(13, :mins)  == 13000000 * 60
    assert Time.to_usecs(13, :hours) == 13000000 * 3600
  end

  test :to_msecs do
    assert {1362,568903,363960} |> Time.new |> Time.to_msecs == 1362568903363.960
    assert Time.to_msecs(13, :usecs) == 0.013
    assert Time.to_msecs(13, :secs)  == 13000
    assert Time.to_msecs(13, :mins)  == 13000 * 60
    assert Time.to_msecs(13, :hours) == 13000 * 3600
  end

  test :to_secs do
    assert {1362,568903,363960} |> Time.new |> Time.to_secs == 1362568903.363960
    assert Time.to_secs(13, :usecs) == 0.000013
    assert Time.to_secs(13, :msecs) == 0.013
    assert Time.to_secs(13, :mins)  == 13 * 60
    assert Time.to_secs(13, :hours) == 13 * 3600
  end
end
