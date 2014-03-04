defmodule DateTime.Utils do
  @moduledoc """
  Internal utilities used for a variety of tasks inside Timex
  """

  @doc """
  Normalize an Erlang date to ensure it is within valid bounds.
  """
  def validate({year, month, day}) do
    # Check if we got past the last day of the month
    max_day = Date.days_in_month(year, month)
    if day > max_day do
      day = max_day
    end
    {year, month, day}
  end

  @doc """
  Given an arbitrary number of months, this function maps
  the month of the year it represents. If the number given
  is negative, it wraps it around to the previous year. If
  the number is greater than 12, wraps around to the next.

  # Examples
    interpolate_month(-1) #=> 11
    interpolate_month(0)  #=> 12
    interpolate_month(5)  #=> 5
    interpolate_month(12) #=> 12
    interpolate_month(23) #=> 11
  """
  defp interpolate_month(m) do
    case rem(rem(m, 12) + 12, 12) do
      0     -> 12
      other -> other
    end
  end
end