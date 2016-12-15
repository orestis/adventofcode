defmodule Day15 do
  def pos(t, n, offset, len) do
    rem(t + n + offset, len) 
  end

  def discs_in_place?(t, discs) do
    Enum.map(discs, fn(d) -> apply(__MODULE__, :pos, [t|d]) end)
    |> Enum.all?(&(&1 == 0))
  end

  def solve(discs) do
    Stream.iterate(0, &(&1 + 1))
    |> Stream.map(fn(t) -> {t, discs_in_place?(t, discs)} end)
    |> Stream.drop_while(fn({t, done}) -> done != true end)
    |> Stream.map(fn({t, done}) -> t end)
    |> Enum.take(1)
    |> List.first()
  end
end

ExUnit.start

defmodule Day15Test do
  use ExUnit.Case

  import Day15

  @test_input """
  Disc #1 has 5 positions; at time=0, it is at position 4.
  Disc #2 has 2 positions; at time=0, it is at position 1.
  """

  test "test input" do
    t = 0
    assert pos(t, 1, 4, 5) == 0
    assert pos(t, 2, 1, 2) == 1
    t = 5
    assert pos(t, 1, 4, 5) == 0
    assert pos(t, 2, 1, 2) == 0
  end

  test "solve test" do
    discs = [
      [1, 4, 5],
      [2, 1, 2],
      ]
    assert false == discs_in_place?(0, discs)
    assert true == discs_in_place?(5, discs)
    assert 5 == solve(discs)
  end

  @input """
  Disc #1 has 13 positions; at time=0, it is at position 11.
  Disc #2 has 5 positions; at time=0, it is at position 0.
  Disc #3 has 17 positions; at time=0, it is at position 11.
  Disc #4 has 3 positions; at time=0, it is at position 0.
  Disc #5 has 7 positions; at time=0, it is at position 2.
  Disc #6 has 19 positions; at time=0, it is at position 17.
  """


  test "solve actual" do
    discs = [
      [1, 11, 13],
      [2, 0, 5],
      [3, 11, 17],
      [4, 0, 3],
      [5, 2, 7],
      [6, 17, 19],
    ]
    assert -1 == solve(discs)
  end

  test "solve part2" do
    discs = [
      [1, 11, 13],
      [2, 0, 5],
      [3, 11, 17],
      [4, 0, 3],
      [5, 2, 7],
      [6, 17, 19],
      [7, 0, 11],
    ]
    assert -1 == solve(discs)
  end
end
