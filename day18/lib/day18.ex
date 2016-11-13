defmodule Day18 do
  def make_grid(w, h) do
    for x <- 1..w, y <- 1..h, into: %{}, do: {{x, y}, 0}
  end

  def parse_light(c) do
     case c do
       "#" -> 1
       "." -> 0
       '#' -> 1
       '.' -> 0
       35 -> 1
       46 -> 0
      end
  end

  def neighbors({0, 0}, {_, _}) do
    [
      {0, 1}, {1, 1}, {1, 0},
    ]
  end
  def neighbors({0, y}, {_, _}) do
    [
      {0, y-1}, {0+1, y-1},
      {1, y},
      {0, y+1}, {0+1, y+1},
    ]
  end
  def neighbors({x, 0}, {_, _}) do
    [
      {x-1, 0}, {x+1, 0},
      {x-1, 1}, {x, 1}, {x+1, 1},
    ]
  end
  def neighbors({x, y}, {w, h}) when (x==w and y==h)do
    [
      {x-1, y-1}, {x, y-1},
      {x-1, y}, 
    ]
  end
  def neighbors({x, y}, {w, h}) when (x==w) do
    [
      {x-1, y-1}, {x, y-1},
      {x-1, y}, 
      {x-1, y+1}, {x, y+1}, 
    ]
  end
  def neighbors({x, y}, {w, h}) when (y==h) do
    [
      {x-1, y-1}, {x, y-1}, {x+1, y-1},
      {x-1, y}, {x+1, y},
    ]
  end
  def neighbors({x, y}, {_, _}) do
    [
      {x-1, y-1}, {x, y-1}, {x+1, y-1},
      {x-1, y}, {x+1, y},
      {x-1, y+1}, {x, y+1}, {x+1, y+1},
    ]
  end

  def parse_line({value, y}, acc) do
    Enum.with_index(value, 1)
    |> Enum.reduce(acc, fn ({v, x}, acc) -> Map.put(acc, {x, y}, parse_light(v)) end)
  end

  def parse_lines(s) do
    s
    |> Stream.map(&String.trim/1)
    |> Enum.with_index(1)    
    |> Enum.reduce(%{}, fn ({value, y}, acc) -> parse_line({String.codepoints(value), y}, acc) end)
  end

  def input(filename) do
    File.stream!(filename) |> parse_lines
  end


  def next(0, nbrs) do
    case Enum.sum(nbrs) do
      3 -> 1
      _ -> 0 
    end
  end

  def next(1, nbrs) do
    case Enum.sum(nbrs) do
      2 -> 1
      3 -> 1
      _ -> 0 
    end
  end

  def get_neighbors_state({x, y}, grid, {w, h}) do
    Map.take(grid, neighbors({x, y}, {w, h})) |> Map.values
  end

  def step(grid, {w, h}) do
    Enum.map(grid, fn ({{x, y}, v}) -> 
      nbrs = get_neighbors_state({x, y}, grid, {w, h})
      n = case {x, y} do
        {1, 1} -> 1
        {^w, 1} -> 1
        {1, ^h} -> 1
        {^w, ^h} -> 1
        _ -> next(v, nbrs)
      end
      {{x, y}, n}
    end)
    |> Map.new
  end

  def solve do
    start = input("input.txt")
    Enum.reduce(1..100, start, fn (x, acc) -> step(acc, {100, 100}) end)
    |> Map.values
    |> Enum.sum
    |> IO.inspect
  end
end
