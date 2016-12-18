defmodule Day13 do
  @doc ~S"""
  Parses the given `line` into a {subject, object, happiness} tuple.

  ## Examples

      iex> Day13.parse "Alice would gain 54 happiness units by sitting next to Bob."
      {"Alice", "Bob", 54}
      iex> Day13.parse "Bob would lose 7 happiness units by sitting next to Carol.."
      {"Bob", "Carol", -7}

  """
  def parse(line) do
    r = ~r/(\w+) would (gain|lose) (\d+) happiness units by sitting next to (\w+)\./
    [subject, gainlose, number, object] = Regex.run(r, line, capture: :all_but_first)
    sign = case gainlose do
      "gain" -> 1
      "lose" -> -1
    end
    number = String.to_integer number
    {subject, object, number * sign}
  end

  @doc ~S"""
  Converts a list of {subject, object, happiness} tuples to a %{{subject, object} => happiness} map.

  ## Examples

      iex> Day13.tuples_to_map([{"Alice", "Bob", 54}])
      %{{"Alice", "Bob"} => 54}

  """
  def tuples_to_map(l) do
    Map.new(l, fn {a, b, c} -> {{a, b}, c} end)
  end

  def read(file) do
    {:ok, input} = File.read(file)
    Regex.split(~r/\R/, input)
    |> Enum.map(&parse/1)
    |> tuples_to_map
  end


  def happiness(seating, potential) do
    _happiness(seating, potential, 0)
    
  end


  def make_circle(l) when length(l) <= 2, do: l
  def make_circle(l) do
    l ++ [hd(l)]
  end

  def _happiness([_|[]], _, total), do: total
  def _happiness(s, p, total) do
    full_list = make_circle(s) #++ r
    pairs = Enum.chunk(full_list, 2, 1)
    |> Enum.map(&(_happiness_pair(&1, p)))
    |> Enum.sum
    
  end

  def _happiness_pair([a, b], potential) do
    Map.get(potential, {a, b}) + Map.get(potential, {b, a})
  end

  def optimal_happiness(potential) do
    people = Map.keys(potential)
    |> Enum.map(fn {a, b} -> a end)
    |> Enum.uniq
    |> IO.inspect
    Combination.permutate(people)
    |> IO.inspect
    |> Enum.map(&(happiness(&1, potential)))
    |> Enum.max
  end

  def solve do
    potential = Day13.read("input.txt")
    IO.puts(optimal_happiness(potential))
  end

  def solve2 do
    potential = Day13.read("input.txt")
    people = Map.keys(potential)
    |> Enum.map(fn {a, b} -> a end)
    |> Enum.uniq
    new = for p <- people, into: %{}, do: {{"me", p}, 0}
    potential = Map.merge(potential, new)
    new = for p <- people, into: %{}, do: {{p, "me"}, 0}
    potential = Map.merge(potential, new)
    IO.puts(optimal_happiness(potential))

    
  end

end

#Day13.solve
