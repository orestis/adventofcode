defmodule Day3 do
  def possible?([a, b, c]) do
    a + b > c and a + c > b and b + c > a
  end

  def solve do
    File.stream!("day3.txt")
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn(line) -> String.split(line) |> Enum.map(&String.to_integer/1) end)
    |> Enum.map(&possible?/1)
    |> Enum.count(&(&1))
    |> IO.puts
  end

  def vertical_triangles(l) do
    Enum.chunk(l, 3)
    |> Enum.map(&List.zip/1) #transpose
    |> List.flatten()
    |> Enum.map(&Tuple.to_list/1)
  end

  def solve2 do
    File.stream!("day3.txt")
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn(line) -> String.split(line) |> Enum.map(&String.to_integer/1) end)
    |> vertical_triangles()
    |> Enum.map(&possible?/1)
    |> Enum.count(&(&1))
    |> IO.inspect
  end
end

ExUnit.start

defmodule Day3Test do
  use ExUnit.Case
  import Day3

  test "possible" do
    assert true == possible?([4, 5, 6])
    assert false == possible?([5, 10, 25])
  end

  test "threes" do
    assert [[101, 102, 103], [301, 302, 303], [501, 502, 503]] == vertical_triangles([
      [101, 301, 501], [102, 302, 502], [103, 303, 503]])
  end

  test "part2" do
    assert 1649 == solve2()
  end
end
