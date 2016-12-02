defmodule Day2 do
  defmodule KeypadSimple do
    @keypad [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9]
    ]

    def get_idx(key, keypad \\ @keypad) do
      indexed_rows = Enum.with_index(keypad)
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

    def get_key({x, y}, keypad \\ @keypad) do
      row = Enum.at(keypad, y)
      Enum.at(row, x)
    end

    def next_key(current, inst, keypad \\ @keypad) do
      {x, y} = get_idx(current, keypad)
      case inst do
        "U" -> {x, y-1}
        "D" -> {x, y+1}
        "L" -> {x-1, y}
        "R" -> {x+1, y}
      end
      |> normalize_idx()
      |> get_key(keypad)
    end

  end

  defmodule KeypadWeird do
    @keypad [
      [2, 3, 4],
      [6, 7, 8],
      [0xA, 0xB, 0xC],
    ]
    def next_key(1, "D"), do: 3
    def next_key(3, "U"), do: 1
    def next_key(1, _), do: 1

    def next_key(5, "R"), do: 6
    def next_key(6, "L"), do: 5
    def next_key(5, _), do: 5

    def next_key(9, "L"), do: 8
    def next_key(8, "R"), do: 9
    def next_key(9, _), do: 9

    def next_key(0xD, "U"), do: 0xB
    def next_key(0xB, "D"), do: 0xD
    def next_key(0xD, _), do: 0xD

    def next_key(current, inst) do
      KeypadSimple.next_key(current, inst, @keypad)
    end
  end

  def bathroom_code(instructions, mod \\ Day2.KeypadSimple) do
    Enum.scan(instructions, 5, fn(line, key) -> follow(line, key, mod) end) 
  end

  def follow(inst, button, mod \\ Day2.KeypadSimple)
  def follow("", button, _), do: button
  def follow(<<i::binary - 1, rest::binary>>, current_button, mod) do
    follow(rest, apply(mod, :next_key, [current_button, i]), mod)
  end


  def input do
    File.stream!("input.txt")
    |> Enum.map(&String.trim/1)
  end

  def solve do
    bathroom_code(input())
    |> IO.inspect
  end

  def solve2 do
    bathroom_code(input(), Day2.KeypadWeird)
    |> IO.inspect
  end

end
