defmodule Day21 do

  def parse(char) when is_integer(char) do
    List.to_integer([char])
  end

  def rotate_left(l, 0), do: l
  def rotate_left([h|t], steps) do
    rotate_left(t ++ [h], steps-1)
  end

  def rotate_right(l, steps) do
    rotate_left(Enum.reverse(l), steps)
    |> Enum.reverse()
  end


  def inst(<<"swap position ", x, " with position ", y>>, p) do
    x = parse(x)
    y = parse(y)
    atx = Enum.at(p, x)
    aty = Enum.at(p, y)
    List.replace_at(p, x, aty)
    |> List.replace_at(y, atx)
  end
  def inst(<<"swap letter ", atx, " with letter ", aty>>, p) do
    x = Enum.find_index(p, &(&1 == atx))
    y = Enum.find_index(p, &(&1 == aty))
    List.replace_at(p, x, aty)
    |> List.replace_at(y, atx)
  end
  def inst(<<"reverse positions ", x, " through ", y>>, p) when x <= y do
    x = parse(x)
    y = parse(y)
    count = y-x+1
    Enum.reverse_slice(p, x, count)
  end
  def inst("rotate left " <> steps, p) do
    {steps, _} = Integer.parse(steps)
    rotate_left(p, steps)
  end
  def inst("rotate right " <> steps, p) do
    {steps, _} = Integer.parse(steps)
    rotate_right(p, steps)
  end
  def inst(<<"move position ", x, " to position ", y>>, p) do
    x = parse(x)
    y = parse(y)
    atx = Enum.at(p, x)
    p
    |> List.delete_at(x)
    |> List.insert_at(y, atx)
  end
  def inst(<<"rotate based on position of letter ", l>>, p) do
    x = Enum.find_index(p, &(&1 == l))
    if x >= 4 do
      rotate_right(p, x + 2)
    else
      rotate_right(p, x + 1)
    end
  end

  def solve(initial) do
    instructions =
      File.stream!("day21.txt")
      |> Stream.map(&String.trim/1)
    scramble(initial, instructions)
  end

  def scramble(initial, instructions) do
    instructions
    |> Enum.reduce(initial, &inst/2)
  end

  def unscramble(scrambled) do
    instructions =
      File.stream!("day21.txt")
      |> Stream.map(&String.trim/1)

    require Combination

    possibles = Combination.permutate('abcdefgh')
    Enum.reduce_while(possibles, :ok, fn(pass, :ok) ->
      scr = scramble(pass, instructions)
      if scr == scrambled do
        {:halt, pass}
      else
        {:cont, :ok}
      end
    end)

  end
end

ExUnit.start

defmodule Day21Test do
  use ExUnit.Case

  import Day21

  @pass 'abcdefgh'
  @answer 'hcdefbag'

  @scrambled 'fbgdceah'

  test "sample" do
    assert inst("swap position 4 with position 0", 'abcde') == 'ebcda'
    assert inst("swap letter d with letter b", 'ebcda') == 'edcba'
    assert inst("reverse positions 0 through 4", 'edcba') ==  'abcde'
    assert inst("rotate left 1 step", 'abcde') == 'bcdea'
    assert inst("move position 1 to position 4", 'bcdea') == 'bdeac'
    assert inst("move position 3 to position 0", 'bdeac') == 'abdec'
    assert inst("rotate based on position of letter b", 'abdec') == 'ecabd'
    assert inst("rotate based on position of letter d", 'ecabd') == 'decab'
  end

  test "part 1" do
    assert solve(@pass) == @answer
  end

  test "part 2 check" do
    assert unscramble(@answer) == @pass
  end

  test "part 2" do
    assert unscramble(@scrambled) == nil
  end


end
