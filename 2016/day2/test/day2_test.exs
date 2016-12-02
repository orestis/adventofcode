defmodule Day2Test do
  use ExUnit.Case
  doctest Day2

  test "full test" do
    assert [1, 9, 8, 5] == Day2.bathroom_code(["ULL", "RRDDD", "LURDL", "UUUUD"])
  end

  test "follow" do
    assert 1 == Day2.follow("ULL", 5)
    assert 9 == Day2.follow("RRDDD", 1)
    assert 8 == Day2.follow("LURDL", 9)
    assert 5 == Day2.follow("UUUUD", 8)
  end

  test "next key" do
    assert 2 == Day2.next_key(5, "U")
    assert 1 == Day2.next_key(2, "L")
    assert 1 == Day2.next_key(1, "L")
  end
end
