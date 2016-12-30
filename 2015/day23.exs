ExUnit.start

defmodule Day23 do
  use ExUnit.Case

  @test_program """
  inc a
  jio a, +2
  tpl a
  inc a
  """

  @program """
  jio a, +19
  inc a
  tpl a
  inc a
  tpl a
  inc a
  tpl a
  tpl a
  inc a
  inc a
  tpl a
  tpl a
  inc a
  inc a
  tpl a
  inc a
  inc a
  tpl a
  jmp +23
  tpl a
  tpl a
  inc a
  inc a
  tpl a
  inc a
  inc a
  tpl a
  inc a
  tpl a
  inc a
  tpl a
  inc a
  tpl a
  inc a
  inc a
  tpl a
  inc a
  inc a
  tpl a
  tpl a
  inc a
  jio a, +8
  inc b
  jie a, +4
  tpl a
  inc a
  jmp +2
  hlf a
  jmp -7
  """

  def run(program, addr, registers) when addr >= length(program), do: registers
  def run(program, addr, registers) do
    i = Enum.at(program, addr)
    {offset, registers} = apply(__MODULE__, :inst, i ++ [registers])
    run(program, addr+offset, registers)
  end

  def inst("hlf", x, registers) do
    x = String.to_atom(x)
    v = registers[x]
    {1, Keyword.put(registers, x, round(v/2))}
  end

  def inst("tpl", x, registers) do
    x = String.to_atom(x)
    v = registers[x]
    {1, Keyword.put(registers, x, v * 3)}
  end

  def inst("inc", x, registers) do
    x = String.to_atom(x)
    v = registers[x]
    {1, Keyword.put(registers, x, v + 1)}
  end

  def inst("jmp", offset, registers) do
    offset = String.to_integer(offset)
    {offset, registers}
  end

  def inst("jie", x, offset, registers) do
    x = String.to_atom(x)
    v = registers[x]
    offset =
      if rem(v, 2) == 0, do: String.to_integer(offset), else: 1
    {offset, registers}
  end

  def inst("jio", x, offset, registers) do
    x = String.to_atom(x)
    v = registers[x]
    offset =
    if v == 1, do: String.to_integer(offset), else: 1
    {offset, registers}
  end

  def solve(input, registers \\ [a: 0, b: 0]) do
    program =
      String.split(input, "\n", trim: true)
      |> Enum.map(&(String.split(&1, [" ", ","], trim: true)))
    run(program, 0, registers)
  end

  test "sample" do
    r = solve(@test_program)
    assert r[:a] == 2
  end

  test "part 1" do
    r = solve(@program)
    assert r[:b] == 184
  end

  test "part 2" do
    r = solve(@program, [a: 1, b: 0])
    assert r[:b] == 231
  end

end
