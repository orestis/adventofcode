defmodule Day6 do

  def gen_lights (size) do
    r1 = Range.new(0, size)
    r2 = Range.new(0, size)
    for x <- r1, y <- r2, into: %{}, do: {{x, y}, false}
  end

  def count_lit(lights) do
    Enum.count(Map.values(lights), fn (x) -> x end)
  end

  def test do
    lights = gen_lights 9
    lights = instruction("turn on 0,0 through 9,9", lights)
    100 = count_lit(lights)
    lights = instruction("toggle 0,0 through 9,0", lights)
    90 = count_lit(lights)
    lights = instruction("turn off 3,3 through 4,4", lights)
    90 - 4 = count_lit(lights)
  end

  def instruction(s, lights) do
    case s do
      "turn on " <> rest -> instruction(:on, parse(rest), lights)
      "turn off " <> rest -> instruction(:off, parse(rest), lights)
      "toggle " <> rest -> instruction(:toggle, parse(rest), lights)
    end
  end

  def parse(s) do
    [s1, s2] = String.split(s, " through ") 
    p1 = String.split(s1, ",") |> Enum.map(&String.to_integer/1) |> List.to_tuple
    p2 = String.split(s2, ",") |> Enum.map(&String.to_integer/1) |> List.to_tuple 
    {p1, p2}
  end

  defp instruction(:on, {{x1, y1}, {x2, y2}}, lights) do
    r1 = Range.new(x1, x2)
    r2 = Range.new(y1, y2)
    for x <- r1, y <- r2, into: lights, do: {{x, y}, true}
  end

  defp instruction(:off, {{x1, y1}, {x2, y2}}, lights) do
    r1 = Range.new(x1, x2)
    r2 = Range.new(y1, y2)
    for x <- r1, y <- r2, into: lights, do: {{x, y}, false}
  end

  defp instruction(:toggle, {{x1, y1}, {x2, y2}}, lights) do
    r1 = Range.new(x1, x2)
    r2 = Range.new(y1, y2)
    for x <- r1, y <- r2, into: lights, do: {{x, y}, not Map.get(lights, {x, y})}
  end

  def process(lights, []), do: lights
  def process(lights, [head|tail]) do
    lights = instruction(head, lights)
    process(lights, tail)
  end

  def solve do
    {:ok, input} = File.read("day6.input.txt")
    lines = Regex.split(~r/\R/, input)
    IO.puts "lit lights:"
    gen_lights(999)
    |> process(lines)
    |> count_lit
    |> IO.puts
    
  end

end

defmodule Day6b do

  def gen_lights (size) do
    r1 = Range.new(0, size)
    r2 = Range.new(0, size)
    for x <- r1, y <- r2, into: %{}, do: {{x, y}, 0}
  end

  def total_brightness(lights) do
    Enum.sum(Map.values(lights))
  end

  def test do
    lights = gen_lights 9
    lights = instruction("turn on 0,0 through 0,0", lights)
    1 = total_brightness(lights)
    lights = instruction("turn off 0,0 through 9,9", lights)
    0 = total_brightness(lights)
    lights = instruction("toggle 0,0 through 9,9", lights)
    200 = total_brightness(lights)
  end

  def instruction(s, lights) do
    case s do
      "turn on " <> rest -> instruction(:on, parse(rest), lights)
      "turn off " <> rest -> instruction(:off, parse(rest), lights)
      "toggle " <> rest -> instruction(:toggle, parse(rest), lights)
    end
  end

  def parse(s) do
    [s1, s2] = String.split(s, " through ") 
    p1 = String.split(s1, ",") |> Enum.map(&String.to_integer/1) |> List.to_tuple
    p2 = String.split(s2, ",") |> Enum.map(&String.to_integer/1) |> List.to_tuple 
    {p1, p2}
  end

  defp instruction(:on, {{x1, y1}, {x2, y2}}, lights) do
    r1 = Range.new(x1, x2)
    r2 = Range.new(y1, y2)
    for x <- r1, y <- r2, into: lights, do: {{x, y}, Map.get(lights, {x, y}) + 1}
  end

  defp instruction(:off, {{x1, y1}, {x2, y2}}, lights) do
    r1 = Range.new(x1, x2)
    r2 = Range.new(y1, y2)
    for x <- r1, y <- r2, into: lights, do: {{x, y}, Enum.max([0, Map.get(lights, {x, y}) - 1])}
  end

  defp instruction(:toggle, {{x1, y1}, {x2, y2}}, lights) do
    r1 = Range.new(x1, x2)
    r2 = Range.new(y1, y2)
    for x <- r1, y <- r2, into: lights, do: {{x, y}, Map.get(lights, {x, y}) + 2}
  end

  def process(lights, []), do: lights
  def process(lights, [head|tail]) do
    lights = instruction(head, lights)
    process(lights, tail)
  end

  def solve do
    {:ok, input} = File.read("day6.input.txt")
    lines = Regex.split(~r/\R/, input)
    IO.puts "total brightness:"
    gen_lights(999)
    |> process(lines)
    |> total_brightness
    |> IO.puts
    
  end

end

Day6.test
#Day6.solve
Day6b.test
Day6b.solve