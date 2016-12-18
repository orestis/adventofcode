defmodule Day20 do
  @doc """
  --- Day 20: Infinite Elves and Infinite Houses ---

  To keep the Elves busy, Santa has them deliver some presents by hand, door-to-door. He sends them down a street with infinite houses numbered sequentially: 1, 2, 3, 4, 5, and so on.

  Each Elf is assigned a number, too, and delivers presents to houses based on that number:

      The first Elf (number 1) delivers presents to every house: 1, 2, 3, 4, 5, ....
      The second Elf (number 2) delivers presents to every second house: 2, 4, 6, 8, 10, ....
      Elf number 3 delivers presents to every third house: 3, 6, 9, 12, 15, ....

  There are infinitely many Elves, numbered starting with 1. Each Elf delivers presents equal to ten times his or her number at each house.

  So, the first nine houses on the street end up like this:

  House 1 got 10 presents.
  House 2 got 30 presents.
  House 3 got 40 presents.
  House 4 got 70 presents.
  House 5 got 60 presents.
  House 6 got 120 presents.
  House 7 got 80 presents.
  House 8 got 150 presents.
  House 9 got 130 presents.

  The first house gets 10 presents: it is visited only by Elf 1, which delivers 1 * 10 = 10 presents. The fourth house gets 70 presents, because it is visited by Elves 1, 2, and 4, for a total of 10 + 20 + 40 = 70 presents.

  What is the lowest house number of the house to get at least as many presents as the number in your puzzle input?
  """

  defmodule Help do
    def divisors(n) do
      s = round(Float.floor(:math.sqrt(n)))
      d = divisors(n, s, [])
      r = Enum.map(d, &(div(n, &1)))
      d ++ r
      |> Enum.uniq()
      |> Enum.sort()
    end
    def divisors(n, 0, l), do: l
    def divisors(n, i, l) when rem(n, i) == 0 do
      divisors(n, i-1, [i|l])
    end
    def divisors(n, i, l) do
      divisors(n, i-1, l)
    end
  end





  def presents(house) do
    (Help.divisors(house)
    |> Enum.sum)
    * 10
  end

  def presents2(house, mul \\ 11) do
    elfs = Help.divisors(house)
    # each elf would bring presents to this house
    # if there are less than 50 houses before this one
    # that have common divisors with this house

    # elf 1 would give presents up to house 50
    # elf 2 would give presents up to house 100 = 50 * 2
    # elf 3 would give presents up to house 150 = 50 * 3
    # ...

    relevant_elfs = Enum.reject(elfs, fn(e) -> (e * 50) < house end)
    Enum.sum(relevant_elfs) * mul

  end



  def solve(n, pres \\ &presents/1) do
    solve(n, 1, 1, pres)
  end



  def solve(n, start, step, pres) do
    Stream.iterate(start, &(&1 + step))
    |> Stream.map(fn(h) -> {h, pres.(h)} end)
    |> Stream.filter(fn({h, p}) -> p >= n end)
    |> Enum.take(1)
    |> Enum.at(0)
    |> elem(0)
  end
end

ExUnit.start


defmodule Day20Test do
  use ExUnit.Case


  import Day20

  test "presents" do
    assert presents(1) == 10
    assert presents(2) == 30
    assert presents(3) == 40
    assert presents(4) == 70
    assert presents(5) == 60
    assert presents(6) == 120
    assert presents(7) == 80
    assert presents(8) == 150
    assert presents(9) == 130
  end

  test "solve" do
    assert solve(100) == 6
    assert solve(130) == 8
  end

  test "part 2 presents" do
    assert presents2(50, 10) == presents(50)
    assert presents2(51, 10) == presents(51) - 10

    assert presents2(100, 10) == presents(100) - 10
    assert presents2(101, 10) == presents(101) - 10
    assert presents2(102, 10) == presents(102) - 10 -20
  end

  @puzzle_input 36000000

  @tag :skip
  test "actual part 1" do
    assert solve(@puzzle_input) == -1
  end

  test "actual part 2" do
    assert solve(@puzzle_input, &presents2/1) == -1
  end

end
