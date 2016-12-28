ExUnit.start
defmodule Day21 do
  use ExUnit.Case

  @moduledoc """
  Weapons:    Cost  Damage  Armor
  Dagger        8     4       0
  Shortsword   10     5       0
  Warhammer    25     6       0
  Longsword    40     7       0
  Greataxe     74     8       0

  Armor:      Cost  Damage  Armor
  Leather      13     0       1
  Chainmail    31     0       2
  Splintmail   53     0       3
  Bandedmail   75     0       4
  Platemail   102     0       5

  Rings:      Cost  Damage  Armor
  Damage +1    25     1       0
  Damage +2    50     2       0
  Damage +3   100     3       0
  Defense +1   20     0       1
  Defense +2   40     0       2
  Defense +3   80     0       3
  """

  def parse_line(line) do
    [cost, damage, armor] = String.split(line) |> Enum.take(-3) |> Enum.map(&String.to_integer/1)
    {cost, damage, armor}
  end

  def weapons() do
    w = """
    Dagger        8     4       0
    Shortsword   10     5       0
    Warhammer    25     6       0
    Longsword    40     7       0
    Greataxe     74     8       0
    """
    String.split(w, "\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def armors() do
    w = """
    Leather      13     0       1
    Chainmail    31     0       2
    Splintmail   53     0       3
    Bandedmail   75     0       4
    Platemail   102     0       5
    """
    (String.split(w, "\n", trim: true)
    |> Enum.map(&parse_line/1))
    ++ [{0, 0, 0}]
  end

  def rings() do
    w = """
    Damage +1    25     1       0
    Damage +2    50     2       0
    Damage +3   100     3       0
    Defense +1   20     0       1
    Defense +2   40     0       2
    Defense +3   80     0       3
    """
    rings =
      String.split(w, "\n", trim: true)
      |> Enum.map(&parse_line/1)
    rings ++ pairs(rings) ++ [{0, 0, 0}]
  end

  def pairs([h|t]) do
    p = for e <- t, do: [h, e]
    p ++ pairs(t)
  end
  def pairs([]), do: []

  def players() do
    # 5 weapons * 5 armors * (ring pairs + rings)
    players = for w <- weapons(), a <- armors(), r <- rings(), do: gen_player(w, a, r)
    Enum.sort_by(players, fn(p) -> p[:cost] end)
  end

  def merge({c1, d1, a1}, {c2, d2, a2}) do
    {c1 + c2, d1 + d2, a1 + a2}
  end

  def gen_player(w, a, [r1, r2]) do
    gen_player(w, a, merge(r1, r2))
  end

  def gen_player(w, a, r) do
    {cost, damage, armor} = merge(merge(w, a), r)
    [hp: 100, damage: damage, armor: armor, type: :player, cost: cost]
  end


  def solve(boss) do
    players()
    |> Stream.map(fn(player) ->
      {winner, _} = battle(player, boss)
      winner end)
    |> Stream.filter(fn(c) -> c[:type] == :player end)
    |> Enum.take(1)
    |> Enum.at(0)
    |> IO.inspect
    |> Keyword.get(:cost)
  end

  def solve_loss(boss) do
    players()
    |> Enum.reverse()
    |> Stream.map(fn(player) ->
      {_, loser} = battle(player, boss)
      loser end)
      |> Stream.filter(fn(c) -> c[:type] == :player end)
    |> Enum.take(1)
    |> Enum.at(0)
    |> IO.inspect
    |> Keyword.get(:cost)
  end

  @boss [hp: 109, damage: 8, armor: 2, type: :boss]
  @test_boss [hp: 12, damage: 7, armor: 2, type: :boss]

  def attack(attacker, defender) do
    damage = attacker[:damage]
    armor = defender[:armor]
    hit = max(damage - armor, 1)
    Keyword.put(defender, :hp, defender[:hp] - hit)
  end

  def battle(p1, p2) do
    cond do
      p1[:hp] <= 0 -> {p2, p1}
      p2[:hp] <= 0 -> {p1, p2}
      :else ->
        p2 = attack(p1, p2)
        battle(p2, p1)
    end
  end

  test "attack" do
    player = [hp: 8, damage: 5, armor: 5]
    boss = @test_boss

    boss = attack(player, boss)
    assert boss[:hp] == 9
    player = attack(boss, player)
    assert player[:hp] == 6
    boss = attack(player, boss)
    assert boss[:hp] == 6
    player = attack(boss, player)
    assert player[:hp] == 4
    boss = attack(player, boss)
    assert boss[:hp] == 3
    player = attack(boss, player)
    assert player[:hp] == 2
    boss = attack(player, boss)
    assert boss[:hp] == 0
  end

  test "battle" do
    player = [hp: 8, damage: 5, armor: 5, type: :player]
    boss = @test_boss
    {winner, loser} = battle(player, boss)
    assert loser[:hp] == 0
    assert loser[:type] == :boss
    assert winner[:hp] == 2
    assert winner[:type] == :player
  end

  test "part 1" do
    assert solve(@boss) == 111
  end

  test "part 2" do
    assert solve_loss(@boss) == -1
  end

end
