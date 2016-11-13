defmodule Day17Test do
  use ExUnit.Case
  doctest Day17

  test "the truth" do
    s = fn (l) -> Enum.sort(Enum.map(l, &Enum.sort/1)) end
    assert s.([
      [15, 10],
      [20, 5],
      [20, 5],
      [15, 5, 5]
    ]) == s.(Day17.combinations([20, 15, 10, 5, 5], 25))
  end
end
