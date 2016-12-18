defmodule Day2 do

  defp parse(s) do
    String.split(s, "x") |> Enum.map(&String.to_integer/1)
  end

  def wrap(s) do
    [l, w, h] = parse(s)
    wrap(l, w, h)
  end

  def area(l, w, h) do
    2 * l * w + 2 * w * h + 2 * h * l
  end

  defp smallest_side_area(l, w, h) do
    Enum.min([l*w, w*h, h*l])
  end

  def wrap(l, w, h) do
    area(l, w, h) + smallest_side_area(l, w, h)
  end

  def test_wrap() do 
    58 = wrap "2x3x4"
    43 = wrap "1x1x10"
  end

  def solve() do 
    {:ok, input} = File.read "day2.input.txt"
    
    lines = Regex.split(~r/\R/, input)
    IO.puts "Wrapping paper area:"
    lines 
    |> Enum.map(&wrap/1)
    |> Enum.sum
    |> IO.puts

    IO.puts "Ribbon length:"
    lines
    |> Enum.map(&ribbon/1)
    |> Enum.sum
    |> IO.puts
  end

  def ribbon(s) do
    [l, w, h] = parse(s)
    ribbon(l, w, h)
  end

  def ribbon(l, w, h) do
    smallest_perimeter(l, w, h) + volume(l, w, h)
  end

  def volume(l, w, h) do
    l * w * h
  end

  def perimeter(a, b) do
    a + a + b + b
  end

  def smallest_perimeter(l, w, h) do
    Enum.min([perimeter(l, w), perimeter(w, h), perimeter(h, l)])
  end

  def test_ribbon() do
      34 = ribbon "2x3x4"
      14 = ribbon "1x1x10"
  end

end

Day2.test_wrap
Day2.test_ribbon
Day2.solve