defmodule Day20 do
  def parse(input) do
    input
    |> String.split()
    |> Stream.map(fn(r) ->
            String.split(r, "-")
            |> Enum.map(&String.to_integer/1)
       end)
    |> Stream.map(fn([l, h]) -> l..h end)
    |> Enum.sort()
  end

  defp is_valid(ip, ranges) do
    Enum.all?(ranges, fn(r) -> not ip in r end)
  end

  def lowest_naive(ranges) do
    Stream.iterate(0, &(&1 + 1))
    |> Stream.filter(fn(ip) -> is_valid(ip, ranges) end)
    |> Enum.take(1)
    |> Enum.at(0)
  end

  def lowest(ranges, low \\ 0)
  def lowest([], low), do: low
  def lowest([range|rest], low) do
    if low in range do
      lowest(rest, range.last + 1)
    else
      lowest(rest, low)
    end
  end


  def count_valid(ranges, maximum) do
    low = lowest(ranges)
    upper = upper_valid(ranges, low, maximum)
    count_valid(ranges, maximum, upper, upper-low+1)
  end

  def count_valid(_ranges, maximum, last_upper_valid, count) when maximum == last_upper_valid, do: count
  def count_valid(ranges, maximum, last_upper_valid, count) do
    {l, upper} = get_next_range(ranges, last_upper_valid, maximum)
    |> IO.inspect
    count_valid(ranges, maximum, upper, count+l)
  end

  def get_next_range(ranges, last_upper_valid, maximum) do
    low = lowest(ranges, last_upper_valid+1)
    upper = upper_valid(ranges, low, maximum)
    {upper-low+1, upper}
  end

  def upper_valid(ranges, low, high) do
    ranges = Enum.reject(ranges, fn(r) -> low > r.last end)
    upper_valid(ranges, high)
  end

  def upper_valid([], high), do: high
  def upper_valid([range|rest], high) do
    # we assume that there is NO range that low is a member.
    if high >= range.first do
      upper_valid(rest, range.first-1)
    else
      upper_valid(rest, high)
    end
  end

  def contains?(r1, r2) do
    r1.first <= r2.first and r1.last >= r2.last
  end


  def combine(r1, r2) do
    cond do
      contains?(r1, r2) -> r1
      contains?(r2, r1) -> r2
      :else -> cond do
          r1.last + 1 >= r2.first and r1.first <= r2.last -> r1.first..r2.last
          r2.last + 1 >= r1.first and r2.first <= r1.last -> r2.first..r1.last
          :else -> false
        end
    end
  end

  def merge(ranges) do
    ranges
  end

end

ExUnit.start

defmodule Day20Test do
  use ExUnit.Case
  import Day20

  @sample_input """
  5-8
  0-2
  4-7
  """

  test "parse" do
    assert parse(@sample_input) == [0..2, 4..7, 5..8]
    assert parse("0-7\n1-3") == [0..7, 1..3]
  end

  @tag :skip
  test "merge" do
    assert merge([0..2, 4..7, 5..8]) == [0..2, 4..8]
    assert merge([0..7, 1..3]) == [0..7]
  end

  test "combine" do
    assert combine(0..7, 0..3) == 0..7
    assert combine(0..3, 0..7) == 0..7
    assert combine(0..7, 1..3) == 0..7
    assert combine(1..3, 0..7) == 0..7
    assert combine(0..3, 3..7) == 0..7
    assert combine(1..5, 3..7) == 1..7
    assert combine(1..2, 3..7) == 1..7
    assert combine(1..2, 4..7) == false
  end

  test "contains" do
    assert contains?(0..7, 0..3) == true
    assert contains?(0..7, 0..7) == true
    assert contains?(0..7, 1..5) == true
    assert contains?(0..7, 1..7) == true
    assert contains?(2..5, 1..7) == false
    assert contains?(2..5, 0..3) == false
    assert contains?(2..5, 3..6) == false
  end

  test "sample" do
    assert lowest(parse(@sample_input)) == 3
  end

  test "kind of input" do
    #ranges = parse(File.read!("day20.txt"))
  end

  @tag :skip
  test "part1" do
    assert lowest(parse(File.read!("day20.txt"))) == -1
  end

  test "upper valid" do
    # we assume no overlaps
    ranges = [0..2, 16..19, 7..13, 30..40]
    assert upper_valid(ranges, 3, 99) == 6
    # therefore, one valid range is 3..6
    # the next one should be:
    low = lowest(ranges, 7)
    assert low == 14
    assert upper_valid(ranges, 14, 99) == 15
    # therefore the next valid range is 14..15
    low = lowest(ranges, 16)
    assert low == 20
    assert upper_valid(ranges, 20, 99) == 29
    # next valid range 20..29
    low = lowest(ranges, 30)
    assert low == 41
    assert upper_valid(ranges, 41, 99) == 99
  end

  test "part 2 sample" do
    assert count_valid(parse(@sample_input), 9) == 2
  end

  test "part 2 actual" do
    assert count_valid(parse(File.read!("day20.txt")), 4294967295) == -1
  end
end
