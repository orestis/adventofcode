defmodule Day9 do
  def decompress(input) do
    parse(input, [])
  end

  def parse("", acc), do: Enum.join(Enum.reverse(acc))
  def parse(<<"(", rest::binary>>, acc) do
    instruction(rest, acc, [])
  end
  def parse(<<c, other::binary>>, acc) do
    parse(other, [<<c>>|acc])
  end

  def instruction(<<")", rest::binary>>, acc, inst) do
    inst = inst|> Enum.reverse() |> Enum.join()
    [length, times] = String.split(inst, "x") |> Enum.map(&String.to_integer/1)
    consume(rest, acc, length, times)
  end
  def instruction(<<c, rest::binary>>, acc, inst) do
    instruction(rest, acc, [<<c>>|inst])
  end

  def consume(s, acc, length, times) do
    to_decompress = String.slice(s, 0, length)
    rest = String.slice(s, length..-1)
    decompressed = Enum.join(List.duplicate(to_decompress, times))
    parse(rest, [decompressed|acc])
  end

  def solve() do
    input = File.read!("day9.txt") |> String.replace("\n", "")
    output = decompress(input)
    IO.puts "output is #{String.length(output)}"
  end
end

defmodule Day9Part2 do
  def decompress2_length(input) do
    tree = parse(input, 0)
    #IO.inspect tree
    Enum.reduce(tree, 0, fn
      ({:leaf, n}, acc) -> acc + n
      ({:node, times, s}, acc) -> acc + (times * decompress2_length(s))
      end)
  end

  def parse("", acc), do: [{:leaf, acc}]
  def parse(<<"(", rest::binary>>, acc) do
    instruction(rest, acc, [])
  end
  def parse(<<c, other::binary>>, acc) do
    parse(other, acc+1)
  end

  def instruction(<<")", rest::binary>>, acc, inst) do
    inst = inst|> Enum.reverse() |> Enum.join()
    [length, times] = String.split(inst, "x") |> Enum.map(&String.to_integer/1)
    consume(rest, acc, length, times)
  end
  def instruction(<<c, rest::binary>>, acc, inst) do
    instruction(rest, acc, [<<c>>|inst])
  end

  def consume(s, acc, length, times) do
    <<to_decompress::bytes-size(length), rest::binary>> = s
    [{:leaf, acc}, {:node, times, to_decompress}| parse(rest, 0)]
  end

  def solve() do
    input = File.read!("day9.txt") |> String.replace("\n", "")
    output = decompress2_length(input)
    IO.puts "output is #{output}"
  end
end

ExUnit.start

defmodule Day9Test do
  use ExUnit.Case, async: true
  import Day9
  import Day9Part2

  @input [
    {"ADVENT", "ADVENT"},
    {"A(1x5)BC", "ABBBBBC"},
    {"(3x3)XYZ", "XYZXYZXYZ"},
    {"A(2x2)BCD(2x2)EFG", "ABCBCDEFEFG"},
    {"(6x1)(1x3)A", "(1x3)A"},
    {"X(8x2)(3x3)ABCY", "X(3x3)ABC(3x3)ABCY"},
  ]
  for {input, output} <- @input do
    test input do
      assert unquote(output) == decompress(unquote(input))
    end
  end

  @input_2 [
    {"(3x3)XYZ", String.length("XYZXYZXYZ")},
    {"X(8x2)(3x3)ABCY", String.length("XABCABCABCABCABCABCY")},
    {"(27x12)(20x12)(13x14)(7x10)(1x12)A", 241920},
  ]
  for {input, output} <- @input_2 do
    test input <> "_2" do
      assert unquote(output) == decompress2_length(unquote(input))
    end
  end

  test "length" do
    assert 445 = decompress2_length("(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN")
  end

end
