defmodule Day1 do
  def santa(s) do
    l = String.codepoints(s)
    santa(l, 0)
  end

  defp santa([], n) do
    n
  end

  defp santa(["(" | tail], n) do
    santa(tail, n + 1)
  end

  defp santa([")" | tail], n) do
    santa(tail, n - 1)
  end

  def test_santa do 
    IO.puts(santa("(())") == 0)
    IO.puts(santa("()()") == 0)
    IO.puts(santa("(((") == 3)
    IO.puts(santa("(()(()(") == 3)
    IO.puts(santa("))(((((") == 3)
    IO.puts(santa("())") == -1)
    IO.puts(santa("))(") == -1)
    IO.puts(santa(")))") == -3)
    IO.puts(santa(")())())") == -3)
  end

  def solve do 
    IO.puts "and now, the punchline"
    {:ok, input} = File.read "day1.input.txt"
    IO.puts(santa input)
    IO.puts(basement input)
  end

  def basement(s) do
    basement(String.codepoints(s), 0, 0)
  end

  def basement(_, pos, -1) do
    pos
  end

  def basement(["(" | tail], pos, floor) do
    basement(tail, pos + 1, floor + 1)
  end

  def basement([")" | tail], pos, floor) do
    basement(tail, pos + 1, floor - 1)
  end

  def test_basement do
    IO.puts(basement(")") == 1)
    IO.puts(basement("()())") == 5)
  end

end


Day1.solve

