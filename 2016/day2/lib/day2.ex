defmodule Day2 do
  @keypad [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
  ]

  def bathroom_code(instructions) do
    Enum.scan(instructions, 5, fn(line, key) -> follow(line, key) end) 
  end

  def follow("", button), do: button
  def follow(<<i::binary - 1, rest::binary>>, current_button) do
    follow(rest, next_key(current_button, i))
  end

  def next_key(current, inst) do
    {x, y} = get_idx(current)
    case inst do
      "U" -> {x, y-1}
      "D" -> {x, y+1}
      "L" -> {x-1, y}
      "R" -> {x+1, y}
    end
    |> normalize_idx()
    |> get_key()
  end

  def get_idx(key) do
    indexed_rows = Enum.with_index(@keypad)
    {x, y} = Enum.find_value(indexed_rows,
      fn({row, y}) ->
        if Enum.member?(row, key), do: {Enum.find_index(row, &(&1 == key)), y}
      end
    )
    {x, y}
  end

  def normalize_idx({x, y}) do
    clamp = fn (v, low, high) -> max(low, min(v, high)) end
    {clamp.(x, 0, 2), clamp.(y, 0, 2)}
  end

  def get_key({x, y}) do
    row = Enum.at(@keypad, y)
    Enum.at(row, x)
  end

  def input do
    File.stream!("input.txt")
    |> Enum.map(&String.trim/1)
  end

  def solve do
    bathroom_code(input())
    |> IO.inspect
  end

end
