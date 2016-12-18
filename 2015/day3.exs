defmodule Day3 do

  def visit(s) do
    instructions = String.codepoints(s)
    visited = walk(instructions, {0, 0}, MapSet.new)
    MapSet.size visited
  end

  def walk([], position, visited) do 
    visited = MapSet.put(visited, position)
    visited
  end

  def walk([head | tail], position, visited) do
    visited = MapSet.put(visited, position)
    newpos = visit(head, position)
    walk(tail, newpos, visited)
  end

  def robovisit(s) do
    instructions = String.codepoints(s)
    santa1 = Enum.take_every(instructions, 2)
    [_ | santa2] = Enum.take_every([" " | instructions], 2)
    visited = walk(santa1, {0, 0}, MapSet.new)
    visited = walk(santa2, {0, 0}, visited)
    MapSet.size(visited)
  end

  def visit(">", {x, y}) do
    {x + 1, y}
  end

  def visit("<", {x, y}) do
    {x - 1, y}
  end

  def visit("^", {x, y}) do
    {x, y + 1}
  end

  def visit("v", {x, y}) do
    {x, y - 1}
  end

  def test_visit do
    2 = visit(">")
    4 = visit("^>v<")
    2 = visit("^v^v^v^v")
  end

  def test_robovisit do
    3 = robovisit("^v")
    3 = robovisit("^>v<")
    11 = robovisit("^v^v^v^v^v")
  end


  def solve do
    {:ok, input} = File.read "day3.input.txt"
    IO.puts "Visited houses:"
    IO.puts visit(input)
    IO.puts "RoboVisited houses:"
    IO.puts robovisit(input)
  end

end

Day3.test_visit
Day3.test_robovisit
Day3.solve
