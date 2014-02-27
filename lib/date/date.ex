defmodule Date do
  @moduledoc """
  This module defines behavior for calendar dates.
  """
  defstruct year: 0, month: 0, day: 1, calendar: :gregorian

  # Date types
  @type year     :: non_neg_integer
  @type month    :: 1..12
  @type day      :: 1..31
  @type date     :: {year, month, day}
  @type datetime :: {{year, month, day}, {non_neg_integer, non_neg_integer, non_neg_integer}}

  @doc """
  Create a new Date struct
  """
  #@spec new() :: Date.t
  #@spec new(year, month, day) :: Date.t
  #@spec new(date) :: Date.t
  #@spec new(datetime) :: Date.t
  def new(),                              do: %Date{}
  def new(year, month, day),              do: %Date{year: year, month: month, day: day}
  def new({year, month, day}),            do: new(year, month, day)
  def new({{year, month, day}, {_,_,_}}), do: new(year, month, day)
end
