defmodule Day19 do
  @moduledoc """
  Each Elf brings a present. They all sit in a circle, numbered starting with position 1. Then, starting with the first Elf, they take turns stealing all the presents from the Elf to their left. An Elf with no presents is removed from the circle and does not take turns.

    1
  5   2 [1, 2, 3, 4, 5]
   4 3  
        [1, 2, 0, 4, 5]

        [1, 2, 0, 4, 0]


    1
  5   2
   4 3

  1 -> (even) 3, 5
  2 -> (odd) 5, 1
  4 -> (even) 1, 4
  2 -> (odd) 4 -
 

  1 2 3 4 5 6 7 8 9 10

   1
 10  2
9     3
 8   4
  7 5
   6

  1 -> 6,7 (even size) (10/2 = 5 skips)
  2 -> 7,9 (odd size) (9/2 = 4 skip)
  3 -> 9,10 (even size) (8/2 = 4 skip)

  1
[10]  2
_     3
8   4
 _ 5
  _


  4 -> 10,2 (odd size) (7/2 = 3 skip)
  5 -> 2,3 (even size) (6/2) = 3 skip)
  8 -> 3,5 (odd size) (5/2) = 2 skip)

  1 -> 5,8 (even size) (4/2) = 2 skip)
  4 -> 8 (odd size) (3/2) = 1 skip)
  1 -> 4 (even size) (2/2) = 1 skip)

  1
_  _
_    3
8   4
 _ 5
  _

  1
_  _
_    _
_   4
_ _
  _


  """

  def winner(n) do
    circle = :ets.new(:circle, [:ordered_set, :named_table])
    elfs = for elf <- 1..n, do: {elf, true}
    :ets.insert(circle, elfs)

    try do
      next(circle, 1)
    after
      :ets.delete(circle)
    end
  end

  def next_in_line(table, player) do
    case :ets.next(table, player) do
      :"$end_of_table" -> :ets.first(table)
      key -> key
    end
  end

  def next(table, player) do
    left = next_in_line(table, player)

    case left do
      ^player -> player # last one!
      other ->
        :ets.delete(table, other)
        next(table, next_in_line(table, player))
    end
  end

  def winner2(n) do
    elfs = Enum.to_list(1..n)
    circle = Circle.new()
    {circle, first} = Circle.from_values(circle, elfs)
    first_casualty = find_across(circle, first, n)
    winner = next_across(circle, first, first_casualty, n)
    winner
  end

  def next_across(_circle, node, _, 2), do: node

  def next_across(circle, node, across, n) when rem(n, 2) == 1 do
    IO.puts "ODD size #{n} at node #{node}"
    next_casualty = Circle.next(circle, across)
    next_casualty = Circle.next(circle, next_casualty)
    Circle.delete(circle, across)
    next = Circle.next(circle, node)
    next_across(circle, next, next_casualty, n-1)
  end
  def next_across(circle, node, across, n) when rem(n, 2) == 0 do
    IO.puts "EVEN size #{n} at node #{node}"
    next_casualty = Circle.next(circle, across)
    Circle.delete(circle, across)
    next = Circle.next(circle, node)
    next_across(circle, next, next_casualty, n-1)
  end

  def find_across(circle, node, size) do
    skips = round(Float.floor(size/2))
    Circle.skip(circle, node, skips)
  end

end


