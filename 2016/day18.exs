defmodule Day18 do
  @moduledoc """
  Its left and center tiles are traps, but its right tile is not.
  Its center and right tiles are traps, but its left tile is not.
  Only its left tile is a trap.
  Only its right tile is a trap.


  The leftmost character on the next row considers the left (nonexistent, so we assume "safe"),
  center (the first ., which means "safe"), and right (the second ., also "safe") tiles on the
  previous row. Because all of the trap rules require a trap in at least one of the previous
  three tiles, the first tile on this new row is also safe, ..

  The second character on the next row considers its left (.), center (.), and right (^) tiles
  from the previous row. This matches the fourth rule: only the right tile is a trap. Therefore,
  the next tile in this new row is a trap, ^.

  The third character considers .^^, which matches the second trap rule: its center and right
  tiles are traps, but its left tile is not. Therefore, this tile is also a trap, ^.
  The last two characters in this new row match the first and third rules, respectively, and
  so they are both also traps, ^.
"""
  def next(c) do
    Enum.chunk([?.|c], 3, 1, '.')
    |> Enum.map(&trap_or_safe/1)
  end

  def trap_or_safe('^^.'), do: ?^
  def trap_or_safe('.^^'), do: ?^
  def trap_or_safe('^..'), do: ?^
  def trap_or_safe('..^'), do: ?^
  def trap_or_safe(_), do: ?.

  def solve(input, rows) do
    counter = fn(row) -> Enum.count(row, &(&1 == ?.)) end
    Enum.reduce(1..(rows-1), {input, counter.(input)}, fn(_, {row, c}) ->
      n = next(row)
      c = c + counter.(n)
      {n, c}
    end)
    |> elem(1)
  end
end

ExUnit.start

defmodule Day18Test do
  use ExUnit.Case

  import Day18

  @puzzle_input '.^^..^...^..^^.^^^.^^^.^^^^^^.^.^^^^.^^.^^^^^^.^...^......^...^^^..^^^.....^^^^^^^^^....^^...^^^^..^'

  test "sample" do
    assert next('..^^.') == '.^^^^'
    assert next('.^^^^') == '^^..^'
  end

  input = ~w(
    .^^.^.^^^^
  ^^^...^..^
    ^.^^.^.^^.
    ..^^...^^^
      .^^^^.^^.^
    ^^..^.^^..
    ^^^^..^^^.
    ^..^^^^.^^
    .^^^..^.^^
    ^^.^^^..^^
  )c


  for {[c, n], idx} <- Enum.with_index(Enum.chunk(input, 2, 1)) do
    @c c
    @n n
    test "sample #{idx}" do
      assert next(@c) == @n
    end
  end

  test "solve" do
    assert solve('..^^.', 3) == 6
  end

  @tag :skip
  test "actual part 1" do
    assert solve(@puzzle_input, 40) == -1
  end

  test "actual part 2" do
    assert solve(@puzzle_input, 400000) == -1
  end


end
