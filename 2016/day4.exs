defmodule Day4 do

  def load_input do
    File.stream!("day4.txt")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&parse_room/1)
  end

  def parse_room(room) do
    [name, sector, check] = Regex.run(~r/(.+)-(\d+)\[(.+)\]/, room, capture: :all_but_first)
    {name, String.to_integer(sector), check}
  end

  def hash(name) do
    letters = String.replace(name, "-", "") |> String.codepoints
    letter_lists = Enum.group_by(letters, &(&1)) |> Map.to_list |> Enum.shuffle
    ordered = Enum.sort_by(letter_lists,
      fn({<<c>>, l}) -> {length(l), -c} end,
      &>=/2
    )
    top5 = Enum.take(ordered, 5) |> Enum.map(fn({c, _}) -> c end) |> Enum.join
    top5
  end

  def real_room({name, _, check}) do
    hash(name) == check
  end

  def part_1 do
    load_input()
    |> Enum.filter(&real_room/1)
    |> Enum.map(fn({_, s, _}) -> s end)
    |> Enum.sum
    |> IO.inspect
  end
end

ExUnit.start

defmodule Day4Test do
  use ExUnit.Case
  import Day4

  test "hash" do
    assert hash("aaaaa-bbb-z-y-x") == "abxyz"
    assert hash("a-b-c-d-e-f-g-h") == "abcde"
    assert hash("not-a-real-room") == "oarel"
    assert hash("totally-real-room") != "decoy"
  end

  test "parse" do
    assert parse_room("aaaaa-bbb-z-y-x-123[abxyz]") == {"aaaaa-bbb-z-y-x", 123, "abxyz"}
  end

  test "part_1" do
    assert 278221 == part_1()
  end

end
