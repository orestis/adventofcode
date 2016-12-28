ExUnit.start

defmodule Day22 do
  use ExUnit.Case

  @boss [hp: 51, damage: 9, armor: 0]

  def spells() do
    [
      {:missile, 53},
      {:drain, 73},
      {:shield, 113},
      {:poison, 173},
      {:recharge, 229},
    ]
  end

  def attack(actor, damage) do
    d = max(damage - actor[:armor], 1)
    Keyword.put(actor, :hp, actor[:hp] - d)
  end

  def health(actor, health) do
    Keyword.put(actor, :hp, actor[:hp] + health)
  end

  def mana(actor, m) do
    Keyword.put(actor, :mana, actor[:mana] + m)
  end

  def spell(:missile, player, boss, effects) do
    player = mana(player, -53)
    player = Keyword.update!(player, :spent, &(&1 + 53))
    boss = attack(boss, 4)
    {player, boss, effects}
  end

  def spell(:drain, player, boss, effects) do
    player = mana(player, -73)
    player = Keyword.update!(player, :spent, &(&1 + 73))
    player = health(player, 2)
    boss = attack(boss, 2)
    {player, boss, effects}
  end

  def spell(:shield, player, boss, effects) do
    player = mana(player, -113)
    player = Keyword.update!(player, :spent, &(&1 + 113))
    effects = Keyword.put(effects, :shield, 6)
    {player, boss, effects}
  end

  def spell(:poison, player, boss, effects) do
    player = mana(player, -173)
    player = Keyword.update!(player, :spent, &(&1 + 173))
    effects = Keyword.put(effects, :poison, 6)
    {player, boss, effects}
  end

  def spell(:recharge, player, boss, effects) do
    player = mana(player, -229)
    player = Keyword.update!(player, :spent, &(&1 + 229))
    effects = Keyword.put(effects, :recharge, 5)
    {player, boss, effects}
  end

  def apply_effects(player, boss, effects) do
    player = if effects[:shield] != nil, do: Keyword.put(player, :armor, 7), else: Keyword.put(player, :armor, 0)
    player = if effects[:recharge] != nil, do: mana(player, 101), else: player
    boss = if effects[:poison] != nil, do: health(boss, -3), else: boss
    effects = Enum.reduce(Keyword.keys(effects), effects, fn(key, effects) ->
      {_, effects} = Keyword.get_and_update(effects, key, fn(duration) ->
        if duration > 1, do: {duration, duration - 1}, else: :pop
      end)
      effects
    end)
    {player, boss, effects}
  end


  def turn(:player, player, boss, effects) do
    player = health(player, player[:rot])
    if player[:hp] <= 0 do
      [{:lose, player, boss, effects}]
    else
      {player, boss, effects} = apply_effects(player, boss, effects)
      valid_spells = Enum.filter(spells(), fn({spell, cost}) -> cost <= player[:mana] and not Keyword.has_key?(effects, spell) end)
      next_states = Enum.map(valid_spells, fn({spell_name, _}) -> spell(spell_name, player, boss, effects) end)
      if length(next_states) > 0 do
        next_states |> Enum.map(fn(state) -> Tuple.insert_at(state, 0, :boss) end)
      else
        [{:lose, player, boss, effects}]
      end
    end
  end

  def turn(:boss, player, boss, effects) do
    if boss[:hp] <= 0 do
      [{:win, player, boss, effects}]
    else
      {player, boss, effects} = apply_effects(player, boss, effects)
      if boss[:hp] <= 0 do
        [{:win, player, boss, effects}]
      else
        player = attack(player, boss[:damage])
        if player[:hp] <= 0 do
          [{:lose, player, boss, effects}]
        else
          [{:player, player, boss, effects}]
        end
      end
    end
  end

  test "example 1" do
    player = [hp: 10, mana: 250, armor: 0, spent: 0, rot: 0]
    boss = [hp: 13, damage: 8, armor: 0]
    {player, boss, effects} = spell(:poison, player, boss, [])
    assert player[:mana] == 77
    assert player[:spent] == 173
    assert effects[:poison] == 6
    [{:player, player, boss, effects}] = turn(:boss, player, boss, effects)
    assert player[:hp] == 2
    assert boss[:hp] == 10
    assert effects[:poison] == 5
    next_steps = turn(:player, player, boss, effects)
    assert length(next_steps) == 2
    # drain
    {:boss, player, boss, effects} = hd(tl(next_steps))
    assert player[:mana] == 4
    assert player[:spent] == 173 + 73
    assert player[:hp] == 4
    assert boss[:hp] == 5
    assert effects[:poison] == 4
    [{:lose, player, boss,_effects}] = turn(:boss, player, boss, effects)
    assert player[:hp] == -4
    assert boss[:hp] == 2
    # magic missile
    {:boss, player, boss, effects} = hd(next_steps)
    assert player[:mana] == 24
    assert player[:spent] == 173 + 53
    assert boss[:hp] == 3
    assert effects[:poison] == 4
    [{:win, player, boss, _effects}] = turn(:boss, player, boss, effects)
    assert boss[:hp] == 0
    assert player[:hp] == 2
  end

  def print_game(game) do
    IO.puts "GAMEEEEEEEEEEEEEEEEE"
    for {t, player, boss, effects} <- game do
      if t == :player, do: IO.puts " -- Player Turn --"
      if t == :boss, do: IO.puts " -- Boss Turn -- "
      if t == :win, do: IO.puts "!!!!!!Player Wins"
      if t == :lose, do: IO.puts "........Player Loses"
      IO.puts "Player has #{player[:hp]} hit points, #{player[:armor]} armor, #{player[:mana]} mana"
      IO.puts "Boss has #{boss[:hp]} hit points \t\t Player has spent #{player[:spent]} mana so far"
      IO.puts "Effects are #{inspect effects}"
    end
    IO.puts "!@@@@@@@@@@@@@############@@@@@@@@@@#$$$$$$$$$$$$$$$"
  end

  def play(states, wins, previous) do
    Enum.reduce(states, wins, fn(state, wins) ->
      case state do
        {:win, player, _, _} ->
          s = [state|previous] |> Enum.reverse() |> print_game()
          [player[:spent]|wins] |> Enum.sort()
        {:lose, _, _, _} -> wins
        other when length(wins) == 0 ->
          next_states = apply(__MODULE__, :turn, Tuple.to_list(other))
          #IO.puts "after state #{inspect state}, next #{inspect next_states}"
          play(next_states, wins, [state|previous])
        {_, player, _, _} = other ->
          min_win = hd(wins)
          if player[:spent] >= min_win do
            wins
          else
            next_states = apply(__MODULE__, :turn, Tuple.to_list(other))
            #IO.puts "after state #{inspect state}, next #{inspect next_states}"
            play(next_states, wins, [state|previous])
          end
      end
    end)
  end

  def solve(rot \\ 0) do
    player = [hp: 50, mana: 500, armor: 0, spent: 0, rot: rot]
    boss = @boss
    wins = play([{:player, player, boss, []}], [], [])
    Enum.sort(wins)
    |> IO.inspect
    |> Enum.at(0)
  end

  @tag :skip
  test "part 1" do
    assert solve() == 900
  end

  test "rot" do
    player = [hp: 10, mana: 60, armor: 0, spent: 0, rot: -1]
    [{:boss, player, _boss, _effects}] = turn(:player, player, @boss, [])
    assert player[:hp] == 9
    player = [hp: 1, mana: 60, armor: 0, spent: 0, rot: -1]
    [{:lose, _player, _boss, _effects}] = turn(:player, player, @boss, [])
  end

  test "part 2" do
    assert solve(-1) == -1
  end

  test "effects?" do
    player = [hp: 10, mana: 60, armor: 0, spent: 0, rot: -1]
    boss = [hp: 10, armor: 0, damage: 8]
    effects = [poison: 1]
    {player, boss, effects} = apply_effects(player, boss, effects)
    assert boss[:hp] == 7
    assert effects[:poison] == nil
  end
end
