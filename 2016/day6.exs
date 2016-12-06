defmodule Day6 do
  def solve(filename, picker \\ &Enum.max_by/2) do
    File.stream!(filename)
    |> Enum.map(&String.trim/1)
    |> Enum.reduce(%{}, fn(word, acc) ->
      indexed = Enum.with_index(String.graphemes(word))
      word_freq = for {c, idx} <- indexed, into: %{}, do: {idx, [c]}
      Map.merge(acc, word_freq, fn(_idx, v1, v2) -> v1 ++ v2 end)
    end)
    |> Map.to_list
    |> Enum.sort
    |> Enum.reduce("", fn({_idx, l}, acc) ->
      chunks =
        Enum.sort(l)
        |> Enum.chunk_by(&(&1))
      [c | _] = picker.(chunks, &length/1)
      acc <> c
    end)
  end

  
end

ExUnit.start

defmodule Day6Test do
  use ExUnit.Case, async: true
  import Day6

  test "sample" do
    assert "easter" == solve("day6.test.txt")
  end

  test "sample_least" do
    assert "advent" == solve("day6.test.txt", &Enum.min_by/2)
  end

  test "proper" do
    assert "tkspfjcc" == solve("day6.txt")
  end

  test "proper_least" do
    assert "xrlmbypn" == solve("day6.txt", &Enum.min_by/2)
  end
end

