defmodule Day8 do

  def solve() do
    commands = File.stream!("day8.txt")
    |> Enum.map(&String.trim/1)
    screen = make_screen(50, 6)
    screen = Enum.reduce(commands, screen, &(command(&1, &2)))
    IO.puts "there are #{count_pixels(screen)} lit pixels"
    IO.puts "the screen looks like:"
    IO.puts as_string(screen)
  end

  def command("rect " <> wh, screen) do
    [w, h] = String.split(wh, "x") |> Enum.map(&String.to_integer/1)
    rect(screen, w, h)
  end

  def command("rotate row y=" <> rest, screen) do
    [y, s] = String.split(rest, " by ") |> Enum.map(&String.to_integer/1)
    rotate_row(screen, y, s)
  end

  def command("rotate column x=" <> rest, screen) do
    [x, s] = String.split(rest, " by ") |> Enum.map(&String.to_integer/1)
    rotate_column(screen, x, s)
  end

  def make_screen(w, h, value \\ false) do
    for y <- 0..(h-1), x <- 0..(w-1), into: %{}, do: {{x, y}, value}
  end

  def count_pixels(screen) do
    Map.values(screen)
    |> Enum.count(& &1)
  end

  def rect(screen, w, h) do
    lit = make_screen(w, h, true)
    Map.merge(screen, lit)
  end

  def as_string(screen) do
    {w, h} = Map.keys(screen) |> Enum.max()
    pixels = for y <- 0..h, x <- 0..w, do: Map.get(screen, {x, y})
    dots = Enum.map(pixels, fn(v) -> if v, do: "#", else: "." end)
    lines = Enum.chunk(dots, w + 1)
    s =
      Enum.map(lines, fn(line) -> Enum.join(line) end)
      |> Enum.join("\n")
    s <> "\n"
  end

  def rotate_column(screen, _x, 0), do: screen
  def rotate_column(screen, x, 1) do
    {_w, h} = Map.keys(screen) |> Enum.max()
    column = for y <- 0..h, do: {x, y}
    [last|head] = for xy <- Enum.reverse(column), do: Map.get(screen, xy)
    values  = [last|Enum.reverse(head)]
    new = Map.new(Enum.zip(column, values))
    Map.merge(screen, new)
  end
  def rotate_column(screen, x, s) do
    Enum.reduce(1..s, screen, fn(_i, acc) ->
      rotate_column(acc, x, 1)
    end)
  end

  def rotate_row(screen, _y, 0), do: screen
  def rotate_row(screen, y, 1) do
    {w, _h} = Map.keys(screen) |> Enum.max()
    row = for x <- 0..w, do: {x, y}
    [last|head] = for xy <- Enum.reverse(row), do: Map.get(screen, xy)
    values  = [last|Enum.reverse(head)]
    new = Map.new(Enum.zip(row, values))
    Map.merge(screen, new)
  end
  def rotate_row(screen, y, s) do
    Enum.reduce(1..s, screen, fn(_i, acc) ->
      rotate_row(acc, y, 1)
    end)
  end
end

ExUnit.start

defmodule Day8Test do
  use ExUnit.Case, async: true
  import Day8

  test "rect" do
    screen = make_screen(50, 6)
    assert count_pixels(screen) == 0
    screen = rect(screen, 2, 3)
    assert count_pixels(screen) == 6
  end

  test "rotate" do
    screen = make_screen(7, 3)
    assert as_string(screen) == """
    .......
    .......
    .......
    """
    screen = rect(screen, 3, 2)
    assert as_string(screen) == """
    ###....
    ###....
    .......
    """
    screen = rotate_column(screen, 1, 1)
    assert as_string(screen) == """
    #.#....
    ###....
    .#.....
    """
    screen = rotate_row(screen, 0, 4)
    assert as_string(screen) == """
    ....#.#
    ###....
    .#.....
    """
    screen = rotate_column(screen, 1, 1)
    assert as_string(screen) == """
    .#..#.#
    #.#....
    .#.....
    """
  end

end
