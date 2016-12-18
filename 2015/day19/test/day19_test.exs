defmodule Day19Test do
  use ExUnit.Case
  doctest Day19
  @test_replacements [{"H", "HO"}, {"H", "OH"}, {"O", "HH"}]
  @test_replacements_e [{"H", "HO"}, {"H", "OH"}, {"O", "HH"}, {"e", "H"}, {"e", "O"}]

  def s(l) do
    Enum.sort(l)
  end

  test "test_split" do
      assert Day19.split("HOH", @test_replacements) == ["H", "O", "H"]
      assert Day19.split("HaOHa", [{"Ha", ""}, {"O", ""}]) == ["Ha", "O", "Ha"]
      assert Day19.split("HaO2H", [{"Ha", ""}, {"H", ""}]) == ["Ha", "O2", "H"]
  end

  test "replacements" do
    assert s(Day19.generate("HOH", @test_replacements)) == s(["HOOH", "HOHO", "OHOH", "HOOH", "HHHH"])
  end

  test "replacements2" do
    c = Day19.generate("HOHOHO", @test_replacements) 
    |> Enum.uniq
    |> Enum.count

    assert c == 7
  end

  test "extra chars" do
    assert Day19.generate("H2O", [{"H", "OO"}]) == ["OO2O"]
  end

  test "reverse1" do
    assert 3 == Day19.hunt("HOH", @test_replacements_e)
  end
  test "reverse2" do
    assert 6 == Day19.hunt("HOHOHO", @test_replacements_e)
  end
end
