defmodule Day19Test do
  use ExUnit.Case

  @puzzle_input 3005290
  import Day19

  @tag :skip
  test "sample" do
    assert winner(5) == 3
  end

  @tag :skip
  test "part 1" do
    assert winner(@puzzle_input) == -1
  end

  #@tag :skip
  @tag timeout: 60_000_000
  test "part 2" do
    assert winner2(@puzzle_input) == -1
  end

  test "sample 2" do
    assert winner2(5) == 2
    assert winner2(10) == 1
  end



  @tag :skip
  test "circle" do
    c = Circle.new()
    {c, first} = Circle.from_values(c, [1, 2, 3, 4, 5])
    assert first == 1
    n = Circle.next(c, first)
    assert n == 2
    n = Circle.next(c, n)
    assert n == 3
    n = Circle.next(c, n)
    assert n == 4
    n = Circle.next(c, n)
    assert n == 5
    n = Circle.next(c, n)
    assert n == 1

    n = Circle.prev(c, n)
    assert n == 5
    n = Circle.prev(c, n)
    assert n == 4
    n = Circle.prev(c, n)
    assert n == 3
    n = Circle.prev(c, n)
    assert n == 2
    n = Circle.prev(c, n)
    assert n == 1
    n = Circle.prev(c, n)
    assert n == 5

    prev = Circle.prev(c, n)
    assert prev == 4 # sanity
    next = Circle.next(c, n)
    assert next == 1 # sanity

    #circle looks like
    # 3 4 5 1 2

    Circle.delete(c, n)

    #circle looks like
    # 3 4 1 2


    prev = Circle.get(c, prev)
    next = Circle.get(c, next)

    assert prev == 1
    assert next == 4

  end

  test "circle closing" do
    c = Circle.new()
    {c, first} = Circle.from_values(c, [1, 2])
    assert first == 1

    n = Circle.next(c, first)
    assert n == 2

    n = Circle.prev(c, first)
    assert n == 2

    n = Circle.next(c, n)
    assert n == 1

    n = Circle.prev(c, n)
    assert n == 2

    Circle.delete(c, n)

    first = Circle.get(c, 1)
    n = Circle.next(c, first)
    assert n == 1

  end

end
