ExUnit.start
defmodule Day25 do
  use ExUnit.Case


  @input [row: 2978, column: 3083]

  @first 20151125

  @mul 252533
  @rem 33554393

  def next(curr) do
    rem(curr * @mul, @rem)
  end

  def code_at(first, n) do
    Stream.iterate(first, &(next(&1)))
    |> Stream.drop(n-1)
    |> Enum.take(1)
    |> hd()
  end

  def index(1, 1), do: 1
  def index(1, column), do: Enum.sum(1..column)
  def index(row, 1), do: Enum.sum(1..row) - (row - 1)
  def index(row, column) do
    1 + index(row+1, column-1)
  end

  test "next" do
    assert next(@first) == 31916031
    assert next(31916031) == 18749137
  end

  test "index" do
    assert index(4, 1) == 7
    assert index(1, 4) == 10
    assert index(4, 3) == 18
    assert index(2, 5) == 20
  end

  test "sample 1" do
    assert code_at(@first, index(4, 4)) == 9380097
    assert code_at(@first, index(2, 6)) == 4041754
  end

  @moduledoc "To continue, please consult the code grid in the manual.  Enter the code at row 2978, column 3083."

  test "part 1" do
    assert code_at(@first, index(2978, 3083)) == -1
  end

end
