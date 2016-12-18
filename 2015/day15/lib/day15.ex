defmodule Day15 do
  @test_ingredients [
      {"Butterscotch", -1, -2, 6, 3, 8},
      {"Cinnamon", 2, 3, -2, -1, 3},
    ]

  @ingredients [
      {"Sprinkles", 5, -1, 0, 0, 5},
      {"PeanutButter", -1, 3, 0, 0, 1},
      {"Frosting", 0, -1, 4, 0, 6},
      {"Sugar", -1, 0, 0, 2, 8},
    ]
  
  def test_calc do
    cookie = properties(@test_ingredients, [44, 56]) 
    [68, 80, 152, 76] = cookie
    62842880 = score(cookie)
  end


  def solve do
    active = Enum.map(@ingredients, &(Enum.map(1..4, fn(i) -> elem(&1, i) end)))
    combinations(active, 100)
    |> Stream.filter(fn (c) -> Enum.sum(c) == 100 end)
    |> Stream.map(&(properties(active, &1)))
    |> Stream.filter(fn (l) -> Enum.all?(l, &(&1 > 0)) end)
    |> Stream.map(&score/1)
    |> Enum.max
    |> IO.inspect
  end

  def solve2 do
    active = Enum.map(@ingredients, &(Enum.map(1..5, fn(i) -> elem(&1, i) end)))
    combinations(active, 100)
    |> Stream.filter(fn (c) -> Enum.sum(c) == 100 end)
    |> Stream.map(&(properties(active, &1)))
    |> Stream.map(&Enum.reverse/1)
    |> Stream.filter(fn ([calories|_]) -> calories == 500 end)
    |> Stream.filter(fn (l) -> Enum.all?(l, &(&1 > 0)) end)
    |> Stream.map(fn ([_|t]) -> t end)
    |> Stream.map(&Enum.reverse/1)
    |> Stream.map(&score/1)
    |> Enum.max
    |> IO.inspect
  end

  def combinations(ing, start \\ 100) do
    num = length(ing)
    l = for _ <- 1..num, do: start
    count = :math.pow(start+1, num) |> round
    Stream.iterate(l, &(_next(&1, start)))
    |> Stream.take(count)
  end

  
  def _next([0|[]], _) do
    throw :StopIteration
  end
  def _next([0|rest], start) do
    [start| _next(rest, start)]
  end

  def _next([h|t], _) do
    [h-1|t]
  end


  def _combinations(ing) do
    num = length(ing)
    Combination.combine(0..100, num) ++ Combination.combine(100..0, num)
    |> Enum.filter(fn (c) -> Enum.sum(c) == 100 end)
  end

  def test_generation do
    active = Enum.map(@test_ingredients, &(Enum.map(1..4, fn(i) -> elem(&1, i) end)))
    combinations(@test_ingredients)
    |> IO.inspect
    |> Enum.map(&(properties(active, &1)))
    |> Enum.filter(fn (l) -> Enum.all?(l, &(&1 != 0)) end)
    |> IO.inspect
    |> Enum.map(&score/1)
    |> IO.inspect
    |> Enum.max
    |> IO.inspect

  end

  def transpose([[]|_]), do: []
  def transpose(a) do
    [Enum.map(a, &hd/1) | transpose(Enum.map(a, &tl/1))]
  end

  def properties(ingredients, quantities) do
    props = transpose(Enum.map(Enum.zip(ingredients, quantities), fn ({ing, q}) -> _prop(ing, q) end))
    props = for p <- props, do: Enum.sum(p)
    props
  end

  def _prop(ing, quantity) do
    Enum.map(ing, fn(x) -> x * quantity end)
  end

  def score(cookie) do
    Enum.reduce(cookie, 1, fn (x, acc) -> x * acc end)
  end
end
