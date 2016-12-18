defmodule Day19 do
  @input "CRnSiRnCaPTiMgYCaPTiRnFArSiThFArCaSiThSiThPBCaCaSiRnSiRnTiTiMgArPBCaPMgYPTiRnFArFArCaSiRnBPMgArPRnCaPTiRnFArCaSiThCaCaFArPBCaCaPTiTiRnFArCaSiRnSiAlYSiThRnFArArCaSiRnBFArCaCaSiRnSiThCaCaCaFYCaPTiBCaSiThCaSiThPMgArSiRnCaPBFYCaCaFArCaCaCaCaSiThCaSiRnPRnFArPBSiThPRnFArSiRnMgArCaFYFArCaSiRnSiAlArTiTiTiTiTiTiTiRnPMgArPTiTiTiBSiRnSiAlArTiTiRnPMgArCaFYBPBPTiRnSiRnMgArSiThCaFArCaSiThFArPRnFArCaSiRnTiBSiThSiRnSiAlYCaFArPRnFArSiThCaFArCaCaSiThCaCaCaSiRnPRnCaFArFYPMgArCaPBCaPBSiRnFYPBCaFArCaSiAl"

  def generate(starting, replacements) do
    parts = split(starting, replacements)
    Enum.map(replacements, fn ({k,v}) -> replace(parts, {k,v}) end)
    |> List.flatten
  end

  def replace(parts, {key, value}), do: replace([], parts, {key, value}, [])
  def replace(_prefix, [], _, acc), do: acc
  def replace(prefix, suffix, {key, value}, acc) do
    {prev, next} = Enum.split_while(suffix, &(key != &1))
    case next do
      [] -> acc
      [^key|rest] ->
        current = Enum.join(prefix ++ prev ++ [value] ++ rest)
        replace(prefix ++ prev ++ [key], rest, {key, value}, [current|acc])
     end
  end

  def split(s, replacements) do
    keys = Enum.map(replacements, &(elem(&1, 0))) |> Enum.uniq 
    r = Regex.compile! "(" <> Enum.join(keys, "|") <> ")"
    Regex.split(r, s, include_captures: true, trim: true)
  end

  def parse(line) do
    Regex.run(~r/(.+) => (.+)/, line, capture: :all_but_first)
    |> List.to_tuple
  end

  def input do
    File.stream!("input.txt")
    |> Stream.map(&parse/1)
    |> Enum.into([])
    |> IO.inspect
  end

  def solve2_brute do
    replacements = input()
    # start with "e" and count the steps to generate the @input
    hunt(@input, replacements)
  end

  def hunt(s, replacements) do
    rev = for {k, v} <- replacements, do: {v, k}
    rev = Enum.sort(rev, fn ({k1, _}, {k2, _})-> String.length(k1) > String.length(k2) end)
    seen = spawn(fn () -> seen_proc(MapSet.new([])) end)
    try do
      _hunt([s], rev, 0, seen)
    catch
      {:done, count} -> count
    end
  end

  def seen_proc(seen) do

    seen = receive do
      {:seen, s, pid} -> 
        send(pid, MapSet.member?(seen, s))
        seen
      {:put, s, pid} -> 
        send(pid, :ok)
        MapSet.put(seen, s)
      m -> IO.puts :stderr, "UNKNOWN MESSAGE #{m}"
    end

if false do
    s = MapSet.size(seen)
    if rem(s, 1000) == 0 do
      IO.puts "seen size #{MapSet.size(seen)}"
    end
end
    seen_proc(seen)
  end

  def add_to_seen(seen, p) do
      send(seen, {:put, p, self()})
      receive do
        :ok -> :ok
        x -> IO.puts :stderr, "UNKOWN put RECV #{x}"
      end
  end

  def is_seen?(seen, p) do
    send(seen, {:seen, p, self()})
    receive do
      true -> true
      false -> false
      x -> IO.puts :stderr, "UNKOWN RECV #{x}"
    end
  end

  def _hunt(["e"|_], _, count, _seen), do: throw {:done, count}
  def _hunt([s|t], repl, count, seen) do
      # l = String.length(s)
      IO.puts "String length: #{String.length(s)}, count #{count}, s: #{s}"
      if is_seen?(seen, s) or count > 1000 do
        IO.puts "PRUNE"
        _hunt(t, repl, count, seen)
      else
        add_to_seen(seen, s) 
        possibles = generate(s, repl)
        # possibles = Enum.sort(possibles, fn (p1, p2) -> String.length(p1) < String.length(p2) end)
        repl = Enum.shuffle(repl)
        _hunt(possibles ++ t, repl, count + 1, seen)
      end

      # Enum.each(possibles, fn (p) -> _hunt(p, repl, count + 1, seen) end)
    # IO.puts "hunting #{s}"
  end


  def solve2 do
    # stolen from reddit
    # TODO thing about how this works more
    # and/or investigate the A* algorithm
    replacements = input()
    #rev = for {k, v} <- replacements, do: {v, k}
    keys = Enum.map(replacements, &(elem(&1, 0))) |> Enum.uniq 
    keys = keys ++ ["Ar", "Rn", "Y"]
    r = Regex.compile! "(" <> Enum.join(keys, "|") <> ")"
    parts = Regex.split(r, @input, include_captures: true, trim: true)
    l = length(parts)
    rn_ar = length(Enum.filter(parts, &(&1 == "Ar" or &1 == "Rn")))
    y = length(Enum.filter(parts, &(&1 == "Y")))

    steps = l - rn_ar - 2 * y - 1
    IO.puts "steps #{steps}"


  end



  def solve do
    replacements = input()
    generate(@input, replacements)
    |> List.flatten
    |> Enum.uniq
    |> Enum.count
    |> IO.inspect
  end
end
