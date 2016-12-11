defmodule Day11 do
  def new_graph() do
    :digraph.new()
  end

  def puzzle_input do
    {0, {["MT", "GP", "GS"], ["MP", "MS"], ["GQ", "MQ", "GR", "MR"], []}}
  end

  def generate_new_state({elev, floors} = current) do
    passengers = valid_passengers(current)
    new_positions = Enum.filter([elev + 1, elev - 1], &(&1 >= 0 and &1 <= 3))
    new_floors = for p <- new_positions, pass <- passengers, do: {p, elem(p, floors) ++ pass}
    Enum.filter(new_floors, &valid_floor/1)
  end

  def valid_passengers({elev, floors}) do
    curr_floor = elem(floors, elev)
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
    {0, {["MH", "ML"], ["GH"], ["GL"], []}}
  end

  test "newstate" do
    curr = test_input()
    next = [{1, {["ML"], ["MH", "GH"], ["GL"], []}}]
    assert next == generate_new_state(curr)
  end

  test "valid passengers" do
    curr = test_input()
    assert [["MH", "ML"], ["MH"], ["ML"]] == valid_passengers(curr)

    assert [["GH", "MH"], ["GH", "GL"], ["MH"], ["GL"]] == valid_passengers({0, {["GH", "MH", "GL"], [], [], []}})
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
end
