defmodule Day12b do
  def sum(s) do
    
    case Poison.Parser.parse(s) do
      {:ok, result} ->
        result
      {:error, :invalid} ->
        IO.puts("NOOOOOOOO")
      {:error, {:invalid, error}} ->
        IO.puts(error)
    end
    #|> IO.inspect
    |> numbers([])
    |> Enum.sum
  end

  def numbers([], acc), do: acc
  def numbers(g, acc) when is_list(g) do
    [h|t] = g
    acc = numbers(h, acc)
    numbers(t, acc)
  end
  def numbers(g, acc) when is_map(g) do
    values = Map.values(g)
    if Enum.member?(values, "red") do
      acc
    else
      numbers(values, acc)
    end
  end
  def numbers(g, acc) when is_integer(g) do
    [g|acc]
  end
  def numbers(g, acc) when is_binary(g) do
    acc
  end

  def test do
    6 = sum(~s([1, 2, 3]))
    4 = sum(~s([1,{"c":"red","b":2},3]))
    0 = sum(~s({"d":"red","e":[1,2,3,4],"f":5}))
    6 = sum(~s([1,"red",5]))
    14 = sum(~s([1,"red",5, {"a":8}]))
    14 = sum(~s([1,"red", 5, {"a":8}]))
  end

  def solve do
    {:ok, input} = File.read("../day12.input.txt")
    Day12b.sum input
  end
end

Day12b.test
Day12b.solve
|> IO.puts
