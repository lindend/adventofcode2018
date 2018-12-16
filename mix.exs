defmodule AOC18.Mixfile do
  use Mix.Project

  def application do
    [applications: []]
  end

  def project do
    [app: :aoc18,
     version: "1.0.0",
     deps: deps()]
  end

  defp deps do
     [{:exprof, "~> 0.2.0"}]
  end
end