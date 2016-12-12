defmodule Day11 do
  def new_graph() do
    :digraph.new([:acyclic])
  end

  def puzzle_input do
    {0, [["GP", "GS", "GT", "MT"], ["MP", "MS"], ["GQ", "GR", "MQ", "MR"], []]}
  end

  def found?({elev, floors}, end_state) do
    last_floor = MapSet.new(Enum.at(floors, 3))
    MapSet.equal?(end_state, last_floor)
  end

  # def walk_again(possibles, end_state, seen, g) do
  #   found = Enum.any?(possibles, fn(s) -> found?(s, end_state) end)
  #   IO.puts "at step #{steps}, contemplating #{length(possibles)}"
  #   if found do
  #     IO.puts "DONE #{steps}"
  #     steps
  #   else
  #     seen = Enum.reduce(possibles, seen, fn(s, acc) -> MapSet.put(acc, s) end)
  #     next_states = Enum.flat_map(possibles, &generate_new_state/1)
  #     Enum.each(next_states, fn(s) ->
  #       v = :digraph.add_vertex(g, s)
  #       :digraph.add_edge(g, curr_vertex, v) 
  #     end)
  #   end
  # end

  def walk(possibles, end_state, seen, steps) do
    found = Enum.any?(possibles, fn(s) -> found?(s, end_state) end)
    IO.puts "at step #{steps}" #, contemplating #{length(possibles)}"
    if found do
      IO.puts "DONE #{steps}"
      steps
    else
      seen = Enum.reduce(possibles, seen, fn(s, acc) -> MapSet.put(acc, s) end)
      next_states = Stream.flat_map(possibles, &generate_new_state/1)
      unseen_states = Stream.filter(next_states, fn(s) ->
        not MapSet.member?(seen, s)
      end)
      unseen_states = Enum.sort_by(unseen_states, fn({_elev, floors}) ->
        floors
        |> Enum.map(&length/1)
        |> Enum.with_index(1)
        |> Enum.reduce(0, fn({len, fl}, acc) -> acc + len * fl * fl * fl * fl end)
      end, &>=/2)
      walk(unseen_states, end_state, seen, steps + 1)
    end
  end

  def walk_graph(initial, curr, end_state, g, steps \\ 0) do
    {curr_vertex, _label} = :digraph.vertex(g, curr)
    if found?(curr, end_state) do
      IO.puts "DONE #{inspect(curr)}"
      short_path = :digraph.get_short_path(g, initial, curr_vertex)
      #for s <- short_path, do: IO.inspect s
      IO.puts "steps #{length(short_path) - 1} or #{steps}"
      #System.halt(0)
    else
      next_states = generate_new_state(curr)
      Enum.each(next_states, fn(s) ->
        v = case :digraph.vertex(g, s) do
          false -> :digraph.add_vertex(g, s)
          {v, _} -> v
        end
        unless v in :digraph.out_neighbours(g, curr_vertex) do
          :digraph.add_edge(g, curr_vertex, v)
        end
      end)
      neighbours = :digraph.out_neighbours(g, curr_vertex)
      #IO.puts "neighbours were #{inspect(neighbours)}"
      neighbours = Enum.sort_by(neighbours, fn({_elev, floors}) ->
        floors
          |> Enum.map(&length/1)
          |> Enum.with_index(1)
          |> Enum.reduce(0, fn({len, fl}, acc) -> acc + len * fl * fl * fl * fl end)
      end, &>=/2)
      #IO.puts "neighbours are #{inspect(neighbours)}"
      Enum.each(neighbours, fn(n) -> walk_graph(initial, n, end_state, g, steps + 1) end)
    end
  end

  def generate_new_state({elev, floors} = current) do
    curr_floor = Enum.at(floors, elev)
    passengers = valid_passengers(current)
    new_positions = Enum.filter([elev + 1, elev - 1], fn(x) -> (x >= 0) and (x <= 3) end)
    new_floors =
      (for p <- new_positions, pass <- passengers, do: {p, Enum.at(floors, p) ++ pass, pass})
      |> Enum.filter(fn ({_el, floor, _pass}) -> valid_floor(floor) end)

    Enum.map(new_floors, fn({p, floor, pass}) ->
      new_curr_floor = curr_floor -- pass
      new_floors =
        List.replace_at(floors, elev, new_curr_floor)
        |> List.replace_at(p, floor)
        |> Enum.map(&Enum.sort/1)
      {p, new_floors}
    end)
    |> Enum.sort()
  end

  def valid_passengers({elev, floors}) do
    curr_floor = Enum.at(floors, elev)
    possible_passengers =
      (pairs(curr_floor) ++ Enum.map(curr_floor, &List.wrap/1))
      |> Enum.filter(&valid_pair/1)
      |> Enum.filter(fn(pass) -> valid_floor(curr_floor -- pass) end)
    possible_passengers
  end

  def valid_floor(floor) do
    paired = pairs(floor)
    shielded_microchips =
      Enum.filter(paired, &shielded_pair/1)
      |> List.flatten()
      |> Enum.filter(fn
          ("M" <> _) -> true
          (_) -> false
        end)
    Enum.all?(pairs(floor -- shielded_microchips), &valid_pair/1)
  end

  def shielded_pair(["G" <> a, "M" <> a]), do: true
  def shielded_pair(["M" <> a, "G" <> a]), do: true
  def shielded_pair(_), do: false

  def valid_pair([_]), do: true
  def valid_pair(["G" <> a, "M" <> a]), do: true
  def valid_pair(["M" <> a, "G" <> a]), do: true
  def valid_pair(["G" <> _, "G" <> _]), do: true
  def valid_pair(["M" <> _, "M" <> _]), do: true
  def valid_pair(_), do: false


  def pairs([]), do: []
  def pairs([_]), do: []
  def pairs([h|t]) do
    p = for e <- t, do: [h, e]
    p ++ pairs(t)
  end

  def solve_breadth(initial) do
    final_state = Enum.reduce(elem(initial, 1), [], fn(floor, acc) ->
      acc ++ floor
    end) |> MapSet.new() |> IO.inspect
    walk([initial], final_state, MapSet.new(), 0)
  end

  def solve_graph(initial \\ puzzle_input()) do
    g = new_graph()
    microchips = Enum.reduce(elem(initial, 1), [], fn(floor, acc) ->
      acc ++ floor
    end) |> MapSet.new() |> IO.inspect
    :digraph.add_vertex(g, initial) |> IO.inspect
    walk_graph(initial, initial, microchips, g)
  end


  def test_input do
    {0, [["MH", "ML"], ["GH"], ["GL"], []]}
  end

end

ExUnit.start

defmodule Day11Test do
  use ExUnit.Case, async: true

  import Day11

  @input """
  The first floor contains a hydrogen-compatible microchip and a lithium-compatible microchip.
  The second floor contains a hydrogen generator.
  The third floor contains a lithium generator.
  The fourth floor contains nothing relevant.
  """

  @puzzle_input """
  The first floor contains a thulium generator, a thulium-compatible microchip, a plutonium generator, and a strontium generator.
  The second floor contains a plutonium-compatible microchip and a strontium-compatible microchip.
  The third floor contains a promethium generator, a promethium-compatible microchip, a ruthenium generator, and a ruthenium-compatible microchip.
  The fourth floor contains nothing relevant.
  """

  test "newstate" do
    curr = test_input()
    next = {1, [["ML"], ["GH", "MH"], ["GL"], []]}
    assert [next] == generate_new_state(curr)
    assert [
      curr,
      {2, [["ML"], [], ["GH", "GL", "MH"], []]},
      {2, [["ML"], ["MH"], ["GH", "GL"], []]},
    ] == generate_new_state(next)
  end

  test "valid passengers" do
    curr = test_input()
    assert [["MH", "ML"], ["MH"], ["ML"]] == valid_passengers(curr)

    assert [["GH", "MH"], ["GH", "GL"], ["MH"], ["GL"]] == valid_passengers({0, [["GH", "MH", "GL"], [], [], []]})
  end

  test "valid pairs" do
    assert true == valid_pair(["MH", "ML"])
    assert false == valid_pair(["GH", "ML"])
  end

  test "shielded pair" do
    assert true == shielded_pair(["MH", "GH"])
    assert false == shielded_pair(["ML", "GH"])
  end

  test "valid floor" do
    assert true == valid_floor(["GH", "MH"])
    assert false == valid_floor(["GH", "MH", "ML"])
    assert true == valid_floor(["GL", "GH", "MH"])
    assert true == valid_floor(["GL", "GS"])
    assert true == valid_floor(["ML", "MS"])
  end

  test "pairs" do
    assert pairs([:a, :b, :c, :d]) == [[:a, :b], [:a, :c], [:a, :d], [:b, :c], [:b, :d], [:c, :d]]
  end

  @tag :skip
  test "check" do
    assert [] == generate_new_state({2, [["ML"], [], ["GH", "GL", "MH"], []]})
  end

  test "sample" do
    assert 9 == solve_breadth(test_input())
  end

end
