defmodule Day17 do
  @moduledoc ~S"""
  #########
  #S| | | #
  #-#-#-#-#
  # | | | #
  #-#-#-#-#
  # | | | #
  #-#-#-#-#
  # | | |  
  ####### V
  """

  @doors [?U, ?D, ?L, ?R]
  def doors(password, path) do
    h = :crypto.hash(:md5, password ++ path)
    <<a::4, b::4, c::4, d::4, _rest::binary>> = h
    Enum.zip(@doors, [a, b, c, d])
    |> Enum.filter(fn({_d, x}) -> x > 10 end)
    |> Enum.map(fn({d, _x}) -> d end)
  end

  def valid_move({_, y}, ?U) when y == 0, do: false
  def valid_move({_, y}, ?D) when y == 3, do: false
  def valid_move({x, _}, ?L) when x == 0, do: false
  def valid_move({x, _}, ?R) when x == 3, do: false
  def valid_move({x, y}, door) do
    #IO.puts "valid move #{inspect({x, y})}, door #{[door]}"
    true
  end

  def go({x, y}, ?U), do: {x, y-1}
  def go({x, y}, ?D), do: {x, y+1}
  def go({x, y}, ?L), do: {x-1, y}
  def go({x, y}, ?R), do: {x+1, y}

  def shortest(password) do
    pos = {0, 0}
    state = {pos, password, []}

    get_next = &move/1
    # end_check = fn({pos, pass, path}) ->
    #   IO.puts "checking #{inspect(pos)}, path so far #{path}"
    #   pos == target end
    end_check = fn({pos, _, _}) -> pos == {3, 3} end

    walk_bfs([state], [], get_next, end_check, 0)
  end

  def longest(password) do
    pos = {0, 0}
    state = {pos, password, []}
    get_next = &move/1
    end_check = fn({pos, _, _}) -> pos == {3, 3} end

    exhaust_bfs([state], [], get_next, end_check, 0, [])
    |> Enum.sort_by(fn({{3, 3}, _, path}) -> length(path) end, &>=/2)
    |> Enum.take(1)
    |> Enum.map(fn({_, _, path})-> length(path) end)
    |> Enum.at(0)
  end



  def move({pos, password, path}) do
    possible_doors = doors(password, path) |> Enum.filter(&(valid_move(pos, &1)))
    next_states = Enum.map(possible_doors, fn(d) ->
      {go(pos, d), password, path ++ [d]}
      end)
    next_states
  end

  def exhaust_bfs([], [], _get_next, _end_check, steps, paths) do
    IO.puts "giving up at steps #{steps}"
    paths
  end
  def exhaust_bfs([], nq, get_next, end_check, steps, paths) do
    #IO.puts ">>exhausted depth #{steps}, going deeper, next check: #{length(nq)} nodes<<"
    exhaust_bfs(nq, [], get_next, end_check, steps+1, paths)
  end
  def exhaust_bfs([curr|rest], nq, get_next, end_check, steps, paths) do
    {paths, children} = if end_check.(curr) do
      #IO.puts "FOUND #{inspect(curr)} at steps #{steps}"
      {[curr|paths], []}
    else
      {paths, get_next.(curr)}
    end
    exhaust_bfs(rest, children ++ nq, get_next, end_check, steps, paths)
  end

  def walk_bfs([], [], _get_next, _end_check, steps) do
    IO.puts "giving up at steps #{steps}"
  end
  def walk_bfs([], nq, get_next, end_check, steps) do
    #IO.puts ">>exhausted depth #{steps}, going deeper, next check: #{length(nq)} nodes<<"
    walk_bfs(nq, [], get_next, end_check, steps+1)
  end
  def walk_bfs([curr|rest], nq, get_next, end_check, steps) do
    if end_check.(curr) do
      IO.puts "FOUND #{inspect(curr)} at steos #{steps}"
      curr
    else
      children = get_next.(curr)
      walk_bfs(rest, children ++ nq, get_next, end_check, steps)
    end
  end

end

ExUnit.start

defmodule Day17Test do
  use ExUnit.Case

  @puzzle_input 'mmsxrhfx'
  import Day17

  test "get doors" do
    assert doors('hijkl', '') == [?U, ?D, ?L]
    assert doors('hijkl', 'D') == [?U, ?L, ?R]
    assert doors('hijkl', 'DR') == []
    assert doors('hijkl', 'DU') == [?R]
    assert doors('hijkl', 'DUR') == []
  end

  test "shortest" do
    {{3, 3}, _pass, path} = shortest('ihgpwlah')
    assert path == 'DDRRRD'
  end

  test "shortest 2" do
    {{3, 3}, _pass, path} = shortest('kglvqrro')
    assert path == 'DDUDRLRRUDRD'
  end

  test "shortest 3" do
    {{3, 3}, _pass, path} = shortest('ulqzkmiv')
    assert path == 'DRURDRUDDLLDLUURRDULRLDUUDDDRR'
  end

  @tag :skip
  test "longest" do
    assert 370 == longest('ihgpwlah')
  end

  @tag :skip
  test "longest 2" do
    assert 492 == longest('kglvqrro')
  end

  @tag :skip
  test "longest 3" do
    assert 830 == longest('ulqzkmiv')
  end

  @tag :skip
  test "actual" do
    {{3, 3}, _pass, path} = shortest(@puzzle_input)
    assert path == nil
  end

  test "actual longest" do
    l = longest(@puzzle_input)
    assert l == 0
  end

end
