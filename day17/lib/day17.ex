defmodule Day17 do
  def combinations(containers, liters) do
    n = length(containers)
    combs = for c <- 1..n, do: Combination.combine(containers, c)
    Enum.reduce(combs, [], &(&1 ++ &2))
    |> Enum.filter(&(Enum.sum(&1) == liters))
  end

  def input do
    File.stream!("day17.input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Enum.to_list
  end

  def solve do
    combinations(input(), 150)
    |> Enum.count
    |> IO.inspect
  end

  def solve2 do
    combs = combinations(input(), 150)
    min = length Enum.min_by(combs, &length/1)
    IO.inspect min
    combs
    |> Enum.filter(&(length(&1) == min))
    |> Enum.count
    |> IO.inspect
  end
end
