defmodule Day18Test do
  use ExUnit.Case
  doctest Day18


  test "parse line" do
    map = Day18.parse_line({'#..', 3}, %{:a => :b})
    assert %{:a => :b, {1, 3} => 1, {2, 3} => 0, {3, 3} => 0} == map
  end

  test "steps" do
    s1 = """
.#.#.#
...##.
#....#
..#...
#.#..#
####..
"""
    map1 = String.split(s1) |> Day18.parse_lines 

    s2 = """
..##..
..##.#
...##.
......
#.....
#.##..
"""
    map2 = String.split(s2) |> Day18.parse_lines 
    assert map2 == Day18.step(map1, {6, 6})
  end
end
