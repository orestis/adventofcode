defmodule Day14 do

  def distance(deer, second) do
    # m = _get_deer_table(deer)
    Enum.sum(_get_deer_distance_per_second(deer, second))
    # _go(m, m, second, 0)
  end

  def _get_deer_table(deer) do
    {_, speed, runtime, rest} = deer
    run = for _ <- Range.new(1, runtime), do: speed
    sleep = for _ <- Range.new(1, rest), do: 0
    run ++ sleep

  end

  def test do
    deers = [{"Comet", 14, 10, 127}, {"Dancer", 16, 11, 162}]
    [1120, 1056] = Enum.map(deers, &(distance(&1, 1000)))
  end

  def parse(line) do
    r = ~r/(\w+) can fly (\d+).+ for (\d+).+must rest for (\d+).*/
    # IO.inspect line
    [name|tail] = Regex.run(r, line, capture: :all_but_first)
    List.to_tuple [name|Enum.map(tail, &String.to_integer/1)]
  end

  def data do
    input  = ~s(Dancer can fly 27 km/s for 5 seconds, but then must rest for 132 seconds.
    Cupid can fly 22 km/s for 2 seconds, but then must rest for 41 seconds.
    Rudolph can fly 11 km/s for 5 seconds, but then must rest for 48 seconds.
    Donner can fly 28 km/s for 5 seconds, but then must rest for 134 seconds.
    Dasher can fly 4 km/s for 16 seconds, but then must rest for 55 seconds.
    Blitzen can fly 14 km/s for 3 seconds, but then must rest for 38 seconds.
    Prancer can fly 3 km/s for 21 seconds, but then must rest for 40 seconds.
    Comet can fly 18 km/s for 6 seconds, but then must rest for 103 seconds.
    Vixen can fly 18 km/s for 5 seconds, but then must rest for 84 seconds.)
    Regex.split(~r/\R/, input)
    |> Enum.map(&parse/1)
  end

  def solve do 
    data
    |> IO.inspect
    |> Enum.map(&(distance(&1, 2503)))
    |> IO.inspect
    |> Enum.max
  end

  def _get_deer_distance_per_second(deer, upto) do
    stream = Stream.cycle(_get_deer_table(deer))
    Enum.take(stream, upto)
  end

  def score(deer, runtime) do
    points = for _ <- deer, do: 0
    distances = for _ <- deer, do: 0
    tables = for d <- deer, do: _get_deer_distance_per_second(d, runtime) 
    tables = transpose(tables)
    _update_points(tables, distances, points)
  end

  def transpose([[]|_]), do: []
  def transpose(a) do
    [Enum.map(a, &hd/1) | transpose(Enum.map(a, &tl/1))]
  end

  def _update_points([], _, points), do: points
  def _update_points([current|next], distances_acc, points) do
    distances_acc = for {d, acc} <- Enum.zip(current, distances_acc), do: d+acc
    lead_dist = Enum.max(distances_acc)
    points = for {dist, point} <- Enum.zip(distances_acc, points), do: point + if dist == lead_dist, do: 1, else: 0
    _update_points(next, distances_acc, points)

  end


  def solve2 do
    data
    |> score(2503) 
    |> Enum.max

  end

  def test2 do
    deers = [{"Comet", 14, 10, 127}, {"Dancer", 16, 11, 162}]
    [312, 689] = score(deers, 1000)
  end
end

Day14.test
Day14.test2
Day14.solve2 |> IO.puts
# Day14.solve |> IO.puts