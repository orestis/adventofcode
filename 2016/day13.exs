defmodule Day13 do
  use Bitwise

  @n 1364
  def f(x, y, c) do
    x*x + 3*x + 2*x*y + y + y*y + c
  end

  def wall?(n) do
    bits = Integer.digits(n, 2)
    rem(Enum.sum(bits), 2) == 1
  end

  def print_maze(xr, yr, c, route \\ [{1, 1}]) do
    x_axis_rows = Enum.chunk(xr, 10)
    x_axis = Stream.repeatedly(fn->Enum.join(0..9) end) |> Enum.take(length(x_axis_rows))

    IO.puts "    " <> Enum.join(x_axis, "")
    for y <- yr do
      IO.puts String.pad_leading("#{y}  ", 4) <> Enum.join(Enum.map(xr, fn(x) ->
            if {x, y} in route, do: "O", else:
            if wall?(f(x, y, c)), do: "#", else: "." end)
          )
    end
  end

  def next(x, y, c) do
    [{x-1, y}, {x+1, y}, {x, y+1}, {x, y-1}]
    |> Enum.filter(fn({x, y}) -> x >= 0 and y >= 0 end)
    |> Enum.filter(fn({x, y}) -> not wall?(f(x, y, c)) end)
  end

  def walk_bfs(start_pos, end_pos, c) do
    seen = MapSet.new()
    steps = 0
    q = :queue.from_list([start_pos])
    nq = :queue.new()
    walk_bfs(q, nq, end_pos, c, seen, steps)
  end

  def walk_bfs(q, nq, end_pos, c, seen, steps) do
    if steps == 50 do
      IO.puts "at 50 steps, have seen #{MapSet.size(seen)}"
    end
    case :queue.peek(q) do
      {:value, curr} ->
        q = :queue.drop(q)
        if curr == end_pos do
          IO.puts "FOUND #{inspect(end_pos)} at steps #{steps}"
          steps
        else
          seen = MapSet.put(seen, curr)
          {x, y} = curr
          n = next(x, y, c) |> Enum.reject(&(MapSet.member?(seen, &1))) |> :queue.from_list()
          nq = :queue.join(nq, n)
          walk_bfs(q, nq, end_pos, c, seen, steps)
        end
      :empty ->
        IO.puts ">>exhausted depth #{steps}, going deeper<<"
        if :queue.peek(nq) != :empty do
          walk_bfs(nq, :queue.new(), end_pos, c, seen, steps+1)
        else
          IO.puts "could not find; giving up"
          -1
        end
    end
  end

  def solve do
    steps = walk_bfs({1, 1}, {31, 39}, @n)
    IO.puts "found with steps #{steps}"
  end
end

ExUnit.start

defmodule Day13Test do
  use ExUnit.Case, async: true

  import Day13

  #@tag :skip
  test "print" do
    print_maze(0..9, 0..6, 10, [{31, 39}])
    print_maze(0..40, 0..40, 1364, [{31, 39}])
  end

  @tag :skip
  test "sample" do
    assert 11 == walk_bfs({1, 1}, {7, 4}, 10)
  end


end
