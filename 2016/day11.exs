defmodule Day11 do
  def new_graph() do
    :digraph.new([:acyclic])
  end

  def puzzle_input do
    {0, {["MT", "GP", "GS"], ["MP", "MS"], ["GQ", "MQ", "GR", "MR"], []}}
  end

  def walk(initial, curr, microchips, g) do
    #Process.sleep(2000)
    {curr_vertex, _label} = :digraph.vertex(g, curr)
    IO.puts "current is #{inspect(curr)}, vertex: #{inspect(curr_vertex)}"
    next_states = generate_new_state(curr)
    IO.puts "next states is #{inspect(next_states)}"
    found = Enum.any?(next_states, fn({elev, floors}) ->
          last_floor = MapSet.new(Enum.at(floors, 3))
          MapSet.equal?(MapSet.intersection(last_floor, microchips), microchips)
    end)
    if found do
      short_path = :digraph.get_short_path(g, initial, curr_vertex)
      IO.puts "DONE #{inspect(short_path)}"
      IO.puts "steps #{length(short_path)}"
      System.halt(0)
    else
      Enum.each(next_states, fn(s) ->
        v = :digraph.add_vertex(g, s)
        #IO.puts "added next state #{inspect(s)}, vertex: #{inspect(v)}"
        :digraph.add_edge(g, curr_vertex, v) 
      end)
      neighbours = :digraph.out_neighbours(g, curr_vertex)
      IO.puts "neighbours are #{inspect(neighbours)}"
      Enum.each(neighbours, &(walk(initial, &1, microchips, g)))
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

  def test_input do
    {0, [["MH", "ML"], ["GH"], ["GL"], []]}
  end

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

  test "walk" do
    g = new_graph()
    initial = test_input()
    microchips = Enum.reduce(elem(initial, 1), [], fn(floor, acc) ->
      acc ++ Enum.filter(floor, & String.starts_with?(&1, "M"))
    end) |> MapSet.new()
    :digraph.add_vertex(g, initial) |> IO.inspect
    walk(initial, initial, microchips, g)
  end
end
