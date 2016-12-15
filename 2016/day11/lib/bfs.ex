defmodule BFS do
  def walk_bfs(start, get_next, end_check) do
    seen = MapSet.new()
    steps = 0
    walk_bfs([start], [], get_next, end_check, seen, steps)
  end

  def walk_bfs([], [], get_next, _end_check, _seen, steps) do
    IO.puts "giving up at steps #{steps}"
    -1
  end
  def walk_bfs([], nq, get_next, end_check, seen, steps) do
    IO.puts ">>exhausted depth #{steps}, going deeper, next check: #{length(nq)} nodes<<"
    IO.puts "have seen so far #{MapSet.size(seen)}"
      walk_bfs(nq, [], get_next, end_check, seen, steps+1)
  end
  def walk_bfs([curr|rest], nq, get_next, end_check, seen, steps) do
    if end_check.(curr) do
      IO.puts "FOUND #{inspect(curr)} at steps #{steps}"
      steps
    else
      if not MapSet.member?(seen, curr) do
        seen = MapSet.put(seen, curr)
        children = get_next.(curr)
        walk_bfs(rest, children ++ nq, get_next, end_check, seen, steps)
      else
        walk_bfs(rest, nq, get_next, end_check, seen, steps)
      end
        #|> Enum.reject(&(MapSet.member?(seen, &1)))
 #     walk_bfs(rest, children ++ nq, get_next, end_check, seen, steps)
    end
  end

end
