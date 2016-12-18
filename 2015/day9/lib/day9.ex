defmodule Day9 do
  def parse(line) do
    r = ~r/(?<from>\w+) to (?<to>\w+) = (?<distance>\d+)/
    [_, from, to, distance] = Regex.run(r, line)
    %{from: from, to: to, distance: String.to_integer(distance)}
  end

  def min_dist(distances) do
    locations = locations distances
    IO.inspect(locations)
    routes = routes locations
    IO.inspect(routes)
    dist_map = dist_map distances
    IO.inspect(dist_map)
    with_dist = for route <- routes, into: %{}, do: {route, dist(route, dist_map)}
    IO.inspect(with_dist)

    Enum.max(Map.values(with_dist))
  end




  def dist_map(distances) do
    dist_map_f = Map.new(distances, fn(d) -> {{d.from, d.to}, d.distance} end)
    dist_map_r = Map.new(distances, fn(d) -> {{d.to, d.from}, d.distance} end)
    dist_map = Map.merge(dist_map_f, dist_map_r)
    dist_map
  end

  def between(from, to, dist_map) do
    Map.get(dist_map, {from, to})
  end

  def dist(route, dist_map) do
    [curr|rest] = route
    dist(curr, rest, dist_map, 0)
  end

  def dist(curr, [], _, d), do: d
  def dist(curr, rest, dist_map, d) do
    [next|rest] = rest
    d = d + between(curr, next, dist_map)
    dist(next, rest, dist_map, d)
  end

  def locations(distances) do
    Enum.reduce(distances, MapSet.new, fn(d, acc) -> MapSet.put(acc, d.from) |> MapSet.put(d.to) end)
  end

  def routes(locations) do
    Combination.permutate locations
  end

  def read(file) do
    {:ok, input} = File.read(file)
    lines = Regex.split(~r/\R/, input)
    lines
  end

  def solve(file) do
    read(file)
    |> Enum.map(&parse/1)
    #|> IO.inspect
    |> min_dist
    |> IO.inspect
  end

end

982 = Day9.solve "day9.test.txt"
Day9.solve "day9.input.txt"