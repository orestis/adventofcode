defmodule Day13Test do
  use ExUnit.Case
  doctest Day13

  test "its true" do
    assert 1 + 1 == 2
  end

  test "test input" do
    potential = Day13.read("input.test.txt")
    assert Day13.happiness(["David", "Alice"], potential) == 44
    assert Day13.happiness(["David", "Alice", "Bob", "Carol"], potential) == 330
  end
end
