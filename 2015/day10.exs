defmodule Day10 do
  
  def lookandsay(s) do
    i = Enum.map(String.codepoints(s), &String.to_integer/1)
    Enum.join(Enum.map(_lookandsay(i, []), &Integer.to_string/1))
    #|> IO.inspect
  end

  def _lookandsay([], acc) do 
    List.flatten(Enum.reverse(acc))
  end
  def _lookandsay(list, acc) do
    #IO.puts("---")
    [h|_] = list
    group = Enum.take_while(list, fn(x) -> x == h end)
    len = length(group)
    #IO.inspect(group)
    rest = Enum.drop(list, len)
    acc = [[len, h] | acc]
    #IO.inspect(acc)
    _lookandsay(rest, acc)
  end

  def test do
    "11" = lookandsay("1")
    "21" = lookandsay("11")
    "1211" = lookandsay("21")
    "111221" = lookandsay("1211")
    "312211" = lookandsay("111221")
  end

  def solve do
    i = Enum.map(String.codepoints("1113122113"), &String.to_integer/1)
    Enum.reduce(1..50, i, fn(_, s) -> _lookandsay(s, []) end)
    |> length
    |> IO.puts
  end

end

Day10.test
Day10.solve