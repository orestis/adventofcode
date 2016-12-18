defmodule Day8 do
  
  def llen(c) do
    s = to_string c
    s = String.replace(s, "\\\\", "*")
    s = String.replace(s, ~r(\\x[0-9a-f][0-9a-f]), "*")
    s = String.replace(s, "\\\"", "*")
    IO.puts(c)
    IO.puts(s)
    
    {length(c), String.length(s) - 2}
  end

  def diff(s) do
    {c, m} = llen(to_charlist(s))
    IO.inspect({c, m})
    c - m
  end

  def solve do
    {:ok, input} = File.read("day8.input.txt")
    lines = Regex.split(~r/\R/, input)
    IO.puts(solve(lines))
  end

  def solve(lines) do
    lines
    |> Enum.map(&diff/1)
    |> Enum.sum
  end

  def test do
    {2, 0} = llen('""')
    {5, 3} = llen('"abc"')
    {10, 7} = llen('"aaa\\"aaa"')
    {6, 1} = llen('"\\x27"')

    {:ok, input} = File.read("day8.test.txt")
    lines = Regex.split(~r/\R/, input)
    12 = solve(lines)
    

  end

end

defmodule Day8b do

  def llen(c) do
    s = to_string c
    s = String.replace(s, "\\", "**")
    s = String.replace(s, "\"", "**")
    
    {length(c), String.length(s) + 2}
  end

  def diff(s) do
    {c, m} = llen(to_charlist(s))
    m - c
  end

  def test do
    {2, 6} = llen('""')
    {5, 9} = llen('"abc"')
    {10, 16} = llen('"aaa\\"aaa"')
    {6, 11} = llen('"\\x27"')
    
  end

  def solve do
    {:ok, input} = File.read("day8.input.txt")
    lines = Regex.split(~r/\R/, input)
    IO.puts(solve(lines))
  end

  def solve(lines) do
    lines
    |> Enum.map(&diff/1)
    |> Enum.sum
  end
end

#Day8.test
#Day8.solve
Day8b.test
Day8b.solve