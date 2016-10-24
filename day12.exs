defmodule Day12 do
  def allnumbers(s) do
    r = ~r/(-?\d+)/
    Regex.scan(r, s)
    #|> IO.inspect
    |> Enum.map(fn([x|_]) -> String.to_integer(x) end)
    #|> IO.inspect
  end

  def test do
    [2, 4, 6] = allnumbers(~s({"a":2,"b":4, "C":[6]}))
    [0, 4, -624] = allnumbers(~s({"a":0,"b":4, "C":[-624]}))
    
  end

  def read(file) do
    {:ok, input} = File.read(file)
    input
  end
end

Day12.test
Day12.read("day12.input.txt")
|> Day12.allnumbers
|> Enum.sum
|> IO.puts