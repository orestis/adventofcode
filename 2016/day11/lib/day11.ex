defmodule Day11 do
  use Bitwise
  def chip(el), do: {:chip, el}
  def gen(el), do: {:gen, el}

  def f2p(floor, el2p) do
    Enum.map(floor, fn({kind, el}) -> {kind, el, 1 <<< (el2p[el])} end)
  end

  def elements_to_powers(floors) do
    elements =
      Enum.flat_map(floors, fn(floor) -> floor end)
      |> Enum.map(fn({_t, el}) -> el end)
      |> Enum.uniq()
      |> Enum.sort()
    counter = Stream.iterate(0, &(&1+1))
    Map.new(Enum.zip(elements, counter))
  end

  def test_input do
    floors = [[chip("H"), chip("L")], [gen("L")], [gen("H")], []]
    el2p = elements_to_powers(floors)
    floors = Enum.map(floors, &(f2p(&1, el2p)))
    {0, floors}
  end

  def puzzle_input do
    floors = [[gen("P"), gen("S"), gen("T"), chip("T")], [chip("P"), chip("S")], [gen("Q"), gen("R"), chip("Q"), chip("R")], []]
    el2p = elements_to_powers(floors)
    floors = Enum.map(floors, &(f2p(&1, el2p)))
    {0, floors}
  end

  def valid?([_]), do: true
  def valid?(floor) do
    {gens, chips} = Enum.partition(floor, fn({kind, _, _}) -> kind == :gen end)
    g_n = Enum.map(gens, fn({:gen, _, n}) -> n end) |> Enum.sum()
    if g_n == 0 do
      true
    else
      m_n = Enum.map(chips, fn({:chip, _, n}) -> n end) |> Enum.sum()
      protected = g_n &&& m_n
      unprotected = m_n - protected
      unprotected == 0
    end
  end

  def generate_new_state({elev, floors}) do
    curr_floor = Enum.at(floors, elev)
    passengers = pairs(curr_floor) ++ Enum.map(curr_floor, &List.wrap/1)
    new_positions = Enum.filter([elev + 1, elev - 1], fn(x) -> (x >= 0) and (x <= 3) end)
    new_floors = 
      for p <- new_positions,
        pass <- passengers,
        floor = Enum.at(floors, p) ++ pass,
        new_curr = curr_floor -- pass,
        valid?(pass) and valid?(floor) and valid?(new_curr) do
          {p, floor, new_curr}
      end

    Enum.map(new_floors, fn({p, floor, new_curr}) ->
      new_floors =
        List.replace_at(floors, elev, new_curr)
        |> List.replace_at(p, floor)
      {p, new_floors}
    end)
  end

  def pairs([]), do: []
  def pairs([_]), do: []
  def pairs([h|t]) do
    p = for e <- t, do: [h, e]
    p ++ pairs(t)
  end

  def hash({elev, floors}) do
    {gen, chips} = Enum.map(floors, fn(floor) -> Enum.partition(floor, fn({kind, _, _}) -> kind == :gen end) end)
    |> Enum.unzip()

    gen = Enum.flat_map(Enum.with_index(gen), fn({floor, idx}) ->
      Enum.map(floor, fn({:gen, el, _}) -> {el, idx} end)
    end) |> Enum.sort()

    chips = Enum.flat_map(Enum.with_index(chips), fn({floor, idx}) ->
      Enum.map(floor, fn({:chip, el, _}) -> {el, idx} end)
    end) |> Enum.sort()

    floors = Enum.zip(chips, gen)
    |> Enum.map(fn({{_chip, i1}, {_gen, i2}}) -> {i1, i2} end)
    |> Enum.sort()

    {elev, floors}
  end

  def put(seen, curr) do
    MapSet.put(seen, hash(curr))
    #true = :ets.insert(seen, hash(curr))
    #seen
  end

  def member?(seen, curr) do
    MapSet.member?(seen, hash(curr))
    # :ets.member(seen, hash(curr))  
  end

  def walk_bfs(start, end_check) do
    # seen = :ets.new(:argh, [])
    seen = MapSet.new()
    steps = 0
    q = :queue.from_list([start])
    nq = :queue.new()
    walk_bfs(q, nq, end_check, seen, steps)
  end

  def walk_bfs(q, nq, end_check, seen, steps) do
    case :queue.peek(q) do
      {:value, curr} ->
        q = :queue.drop(q)
        if end_check.(curr) do
          IO.puts "FOUND #{inspect(curr)} at steps #{steps}"
          steps
        else
          seen = put(seen, curr)
          children =
            generate_new_state(curr)
            |> Enum.reject(&(member?(seen, &1)))
            |> :queue.from_list()
          nq = :queue.join(nq, children)
          walk_bfs(q, nq, end_check, seen, steps)
        end
      :empty ->
        IO.puts ">>exhausted depth #{steps}, going deeper, next check: #{:queue.len(nq)} nodes<<"
        if :queue.peek(nq) != :empty do
          if steps == 10 do
            -100
          else
            walk_bfs(nq, :queue.new(), end_check, seen, steps+1)
          end
        else
          IO.puts "could not find; giving up"
          -1
        end
    end
  end

  def solve_bfs(input, l) do
    check = fn({el, floors}) ->
      #IO.puts "checking #{inspect({el, floors})}"
      length(Enum.at(floors, 3)) == l
    end
    walk_bfs(input, check)
  end

  def solve() do
    steps = solve_bfs(puzzle_input(), 10)
    IO.puts "solved in #{steps}"
  end

end

