defmodule BFS do
  @verbose false
  defmacro debug(body) do
    if @verbose do
      body
    end
  end
  def walk_bfs(start, get_next, end_check) do
    seen = MapSet.new()
    steps = 0
    walk_bfs([start], [], get_next, end_check, seen, steps)
  end

  def walk_bfs([], [], _get_next, _end_check, _seen, _steps) do
    debug IO.puts "giving up at steps #{_steps}"
    -1
  end
  def walk_bfs([], nq, get_next, end_check, seen, steps) do
    debug IO.puts ">>exhausted depth #{steps}, going deeper, next check: #{length(nq)} nodes<<"
    debug IO.puts "have seen so far #{MapSet.size(seen)}"
      walk_bfs(nq, [], get_next, end_check, seen, steps+1)
  end
  def walk_bfs([curr|rest], nq, get_next, end_check, seen, steps) do
    if end_check.(curr) do
      debug IO.puts "FOUND #{inspect(curr)} at steps #{steps}"
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
