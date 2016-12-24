ExUnit.start

defmodule Day24 do
  use ExUnit.Case
  @moduledoc """
  8 distinct points;
  can easily use BFS to calculate shortest path between all pairs
  which are 8+7+6+5+4+3+2+1 (pairs are interchangeable)

  given that info, calculate all the possible paths which are however quite
  a lot: 7! / 2 according to wikipedia = 2520 combinations

  so probably not impossible to do
  """

  defmodule Maze do
    defstruct maze: %{}, w: 0, h: 0, pois: []
  end


  def parse_input(file) do
    lines =
      File.read!(file)
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_charlist/1)

    h = length(lines)
    w = length(Enum.at(lines, 0))

    maze =
      Enum.with_index(lines)
      |> Enum.flat_map(fn({line, y}) ->
          Enum.map(Enum.with_index(line), fn({cell, x}) ->
            {{x, y}, cell}
          end)
        end)
      |> Map.new()

    pois =
      Map.to_list(maze)
      |> Enum.filter(fn({_, cell}) ->
          cell != ?# and cell != ?.
         end)
    %Maze{maze: maze, w: w, h: h, pois: pois}
  end

  def print_maze(%Maze{maze: maze, w: w, h: h}) do
    for y <- 0..h-1 do
      IO.puts Enum.map(0..w-1, &(Map.get(maze, {&1, y})))
    end
  end

  def get_poi_distances(%Maze{maze: maze, pois: pois}) do
    pairs(pois)
    |> Enum.flat_map(fn({{p1, a}, {p2, b}}) ->
        d = distance(p1, p2, maze)
      [{{a, b}, d}, {{b, a}, d}]
      end)
    |> Map.new()
  end

  def distance({x, y}, {w, z}, maze) do
    require BFS
    get_next = fn({x, y}) ->
      [{x-1, y}, {x+1, y}, {x, y-1}, {x, y+1}]
      |> Enum.filter(fn(p) ->
          case Map.get(maze, p) do
            ?# -> false
            ?. -> true
            nil -> false
            _ -> true
          end
        end)
    end

    end_check = fn({x, y}) -> {x, y} == {w, z} end

    BFS.walk_bfs({x, y}, get_next, end_check)
  end

  def solve(maze, path_length) do
    distances = get_poi_distances(maze)
    pois = Enum.map(maze.pois, fn({_, poi}) -> poi end)

    perms(pois)
    |> Enum.filter(&(Enum.at(&1, 0) == ?0))
    |> IO.inspect
    |> Enum.map(&(path_length.(&1, distances)))
    |> Enum.min()
  end

  def get_path_distance(path, distances) do
    path
    |> Enum.chunk(2, 1)
    |> Enum.reduce(0, fn([p1, p2], acc) ->
      acc + Map.get(distances, {p1, p2})
    end)
  end

  def get_closed_path_distance(path, distances) do
    path
    |> Enum.chunk(2, 1, '0')
    |> Enum.reduce(0, fn([p1, p2], acc) ->
      acc + Map.get(distances, {p1, p2})
    end)
  end

  def pairs([h|t]) do
    p = for e <- t, do: {h, e}
    p ++ pairs(t)
  end
  def pairs([]), do: []

  def perms([]), do: [[]]
  def perms(list) do
    for h <- list, t <- perms(list -- [h]), do: [h|t]
  end

  test "parse" do
    maze = parse_input("day24.test.txt")
    print_maze(maze)
  end

  test "distances" do
    maze = parse_input("day24.test.txt")
    distances = get_poi_distances(maze)
    assert Map.get(distances, {?0, ?1}) == 2
    assert Map.get(distances, {?1, ?0}) == 2
    assert Map.get(distances, {?0, ?4}) == 2
    assert Map.get(distances, {?4, ?0}) == 2
    assert Map.get(distances, {?4, ?1}) == 4
    assert Map.get(distances, {?2, ?1}) == 6
    assert Map.get(distances, {?4, ?3}) == 8
  end

  @tag :skip
  test "part 1 sample" do
    maze = parse_input("day24.test.txt")
    assert solve(maze, &get_path_distance/2) == 14
  end

  @tag :skip
  test "part 1" do
    maze = parse_input("day24.txt")
    assert solve(maze, &get_path_distance/2) == 448
  end

  test "part 2" do
    maze = parse_input("day24.txt")
    assert solve(maze, &get_closed_path_distance/2) == -1
  end


end
