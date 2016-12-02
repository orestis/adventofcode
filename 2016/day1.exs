defmodule Day1 do
  @directions "R1, R3, L2, L5, L2, L1, R3, L4, R2, L2, L4, R2, L1, R1, L2, R3, L1, L4, R2, L5, R3, R4, L1, R2, L1, R3, L4, R5, L4, L5, R5, L3, R2, L3, L3, R1, R3, L4, R2, R5, L4, R1, L1, L1, R5, L2, R1, L2, R188, L5, L3, R5, R1, L2, L4, R3, R5, L3, R3, R45, L4, R4, R72, R2, R3, L1, R1, L1, L1, R192, L1, L1, L1, L4, R1, L2, L5, L3, R5, L3, R3, L4, L3, R1, R4, L2, R2, R3, L5, R3, L1, R1, R4, L2, L3, R1, R3, L4, L3, L4, L2, L2, R1, R3, L5, L1, R4, R2, L4, L1, R3, R3, R1, L5, L2, R4, R4, R2, R1, R5, R5, L4, L1, R5, R3, R4, R5, R3, L1, L2, L4, R1, R4, R5, L2, L3, R4, L4, R2, L2, L4, L2, R5, R1, R4, R3, R5, L4, L4, L5, L5, R3, R4, L1, L3, R2, L2, R1, L3, L5, R5, R5, R3, L4, L2, R4, R5, R1, R4, L3"
  @dirs [:north, :east, :south, :west]

  def directions(s), do: String.split(s, ", ")

  def follow(d) do
    follow(d, :north, {0, 0})
  end


  def follow(directions, facing, pos, move \\ &move/3)
  def follow([], _, acc, _), do: acc
  def follow([h|t], facing, {x, y}, move) do
    <<direction::binary - 1, steps::binary>> = h
    steps = String.to_integer(steps)
    new_face = turn(direction, facing)
    {newx, newy} = move.({x, y}, new_face, steps)
    follow(t, new_face, {newx, newy}, move)
  end

  def move({x, y}, facing, steps) do
    case facing do
      :north -> {x, y + steps}
      :south -> {x, y - steps}
      :west -> {x - steps, y}
      :east -> {x + steps, y}
    end
  end

  def turn(t, facing) do
    i = Enum.find_index(@dirs, &(&1 == facing))
    i = case t do
          "R" -> i + 1
          "L" -> i - 1
    end
    Enum.at(@dirs, rem(i, length(@dirs)))
  end
  def solve do
    x = follow(directions(@directions))
    IO.inspect x
  end

  def solve2(input \\ @directions) do
    Agent.start_link(fn -> MapSet.new end, name: __MODULE__)
    stateful_move = fn({x, y}, facing, steps) ->
      {newx, newy} = move({x, y}, facing, steps)
      newset = for xx <- x..newx, yy <- y..newy, into: MapSet.new, do: {xx, yy}
      visit_list = newset
        |> MapSet.delete({newx, newy})
        |> MapSet.to_list
      visit_list = if facing == :west or facing == :south do
        Enum.reverse(visit_list)
      else
        visit_list
      end
      IO.inspect visit_list
      Enum.each(visit_list, fn({xx, yy}) ->
        IO.puts "checking #{inspect({xx, yy})}"
        already_visited = Agent.get_and_update(__MODULE__, fn(set) ->
          {MapSet.member?(set, {xx, yy}), MapSet.put(set, {xx, yy})}
        end)
        if already_visited do
          IO.puts "throwing"
          throw {:finished, {xx, yy}}
        end
      end)
      {newx, newy}
    end

    s = try do
      follow(directions(input), :north, {0, 0}, stateful_move)
    catch
      {:finished, {x, y}} -> {x, y}
    end
    Agent.stop(__MODULE__)
    IO.inspect(s)
  end

  def test do
    :east = Day1.turn("R", :north)
    :west = Day1.turn("L", :north)
    :north = Day1.turn("R", :west)

    ["R2", "L3"] = Day1.directions("R2, L3")
    {2, 3} = Day1.follow(Day1.directions("R2, L3"))
    {0, -2} = Day1.follow(Day1.directions("R2, R2, R2"))
    {10, 2} = Day1.follow(Day1.directions("R5, L5, R5, R3"))

    {4, 0} = Day1.solve2("R8, R4, R4, R8")
  end
end


Day1.test
Day1.solve2
