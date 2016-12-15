
defmodule Day11Test do
  use ExUnit.Case, async: true
  @moduletag :skip

  import Day11

  test "valid floor" do
    floors = [[chip("H"), chip("L")], [gen("H")], [gen("L")], []]
    el2p = elements_to_powers(floors)
    assert true == valid?(f2p([gen("H"), chip("H")], el2p))
    assert false == valid?(f2p([gen("H"), chip("H"), chip("L")], el2p))
    assert true == valid?(f2p([gen("L"), gen("H"), chip("H")], el2p))
    assert true == valid?(f2p([gen("L"), gen("H")], el2p))
    assert true == valid?(f2p([chip("L"), chip("H")], el2p))
  end

  test "hash" do
    h = hash(test_input())
    assert {0, [{0, 1}, {0, 2}]} == h

    h = hash(puzzle_input())
    assert {0, [{0, 0}, {1, 0}, {1, 0}, {2, 2}, {2, 2}]} == h
  end


  test "sample" do
    assert 11 == solve_bfs(test_input(), 4)
  end

  @tag :skip
  test "part1" do
    assert 31 == solve_bfs(puzzle_input(), 10)
  end

end
