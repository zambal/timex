defmodule Date.Mixfile do
  use Mix.Project

  def project do
    [ app: :"timex",
      version: "0.5.0",
      elixir: "~> 0.13.0-dev",
      deps: deps ]
  end

  def deps do
    []
  end
end
