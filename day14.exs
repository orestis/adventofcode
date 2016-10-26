defmodule Day14 do

  def distance(deer, second) do
    {_, speed, runtime, rest} = deer
    run = for _ <- Range.new(1, runtime), do: speed
    sleep = for _ <- Range.new(1, rest), do: 0
    m = run ++ sleep
    _go(m, m, second, 0)
  end

  def _go(_, _, 0, dist), do: dist
  def _go(orig, [], remaining, dist) do
    _go(orig, orig, remaining, dist)
  end
  def _go(orig, m, remaining, dist) do
    [d| m] = m
    _go(orig, m, remaining-1, dist+d)
  end

  def test do
    deers = [{"Comet", 14, 10, 127}, {"Dancer", 16, 11, 162}]
    [1120, 1056] = Enum.map(deers, &(distance(&1, 1000)))
  end

  def parse(line) do
    r = ~r/(\w+) can fly (\d+).+ for (\d+).+must rest for (\d+).*/
    IO.inspect line
    [name|tail] = Regex.run(r, line, capture: :all_but_first)
    List.to_tuple [name|Enum.map(tail, &String.to_integer/1)]
  end

  def solve do 
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
    |> IO.inspect
    |> Enum.map(&(distance(&1, 2503)))
    |> IO.inspect
    |> Enum.max
  end
end

Day14.test
Day14.solve |> IO.puts