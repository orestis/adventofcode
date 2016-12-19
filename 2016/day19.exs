defmodule Day19 do
  @moduledoc """
  Each Elf brings a present. They all sit in a circle, numbered starting with position 1. Then, starting with the first Elf, they take turns stealing all the presents from the Elf to their left. An Elf with no presents is removed from the circle and does not take turns.

    1
  5   2
   4 3

  Elf 1 takes Elf 2's present.
  Elf 2 has no presents and is skipped.
  Elf 3 takes Elf 4's present.
  Elf 4 has no presents and is also skipped.
  Elf 5 takes Elf 1's two presents.
  Neither Elf 1 nor Elf 2 have any presents, so both are skipped.
  Elf 3 takes Elf 5's three presents.

  [1, 2, 3, 4, 5]
  [1, 3, 4, 5]
  [1, 3, 5]
  [3, 5]
  [3]

  0, [1, 2, 3, 4, 5] -> 1, [1, 0, 3, 4, 5]
  1, [1, 0, 3, 4, 5] -> 2, [1, 0, 3, 4, 5]
  2, [1, 0, 3, 4, 5] -> 3, [1, 0, 3, 0, 5]
  3, [1, 0, 3, 0, 5] -> 4, [1, 0, 3, 0, 5]
  4, [1, 0, 3, 0, 5] -> 0, [0, 0, 3, 0, 5]
  0, [0, 0, 3, 0, 5] -> 1, [0, 0, 3, 0, 5]
  1, [0, 0, 3, 0, 5] -> 2, [0, 0, 3, 0, 5]
  2, [0, 0, 3, 0, 5] -> 3, [0, 0, 3, 0, 0]

  """

  def winner(n, fun \\ &next/2, start \\ 1) do
    circle = :ets.new(:circle, [:ordered_set, :named_table])
    elfs = for elf <- 1..n, do: {elf, true}
    :ets.insert(circle, elfs)

    try do
      fun.(circle, start)
    after
      :ets.delete(circle)
    end
  end

  def next_in_line(table, player) do
    case :ets.next(table, player) do
      :"$end_of_table" -> :ets.first(table)
      key -> key
    end
  end

  def next(table, player) do
    left = next_in_line(table, player)

    case left do
      ^player -> player # last one!
      other ->
        :ets.delete(table, other)
        next(table, next_in_line(table, player))
    end
  end

  def next_index(table, idx, n) do
    rem(idx + 1, n)
  end

  def next_across(table, idx) do
    size = :ets.info(table, :size)
    next_across(table, idx, size)
  end

  def next_across(table, idx, 1), do: :ets.first(table)
  def next_across(table, idx, n) do
    size = :ets.info(table, :size)
    IO.puts "table size is now #{n}"
    across = rem(round(Float.floor(n/2 + idx)), n)
    #IO.puts "player at idx #{idx} with circle size #{n} has across #{across}"
    [{key, _}] = :ets.slot(table, across)
    #[{curr, _}] = :ets.slot(table, idx)
    #IO.puts "that is, #{curr} steals from #{key} when cirxle size is #{n}"
    :ets.delete(table, key)
    next_across(table, next_index(table, idx, n), n-1)
  end
end

ExUnit.start

defmodule Day19Test do
  use ExUnit.Case

  import Day19

  @puzzle_input 3005290

  test "sample" do
    assert winner(5) == 3
  end

  @tag :skip
  test "part 1" do
    assert winner(@puzzle_input) == -1
  end

  @tag timeout: 60_000_000
  test "part 2" do
    assert winner(@puzzle_input, &next_across/2, 0) == -1
  end

  test "sample 2" do
    assert winner(5, &next_across/2, 0) == 2
  end

end
