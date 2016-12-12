defmodule Day12 do
  @input """
  cpy 1 a
  cpy 1 b
  cpy 26 d
  jnz c 2
  jnz 1 5
  cpy 7 c
  inc d
  dec c
  jnz c -2
  cpy a c
  inc a
  dec b
  jnz b -2
  cpy c b
  dec d
  jnz d -6
  cpy 19 c
  cpy 11 d
  inc a
  dec d
  jnz d -2
  dec c
  jnz c -5
  """
  def process(instructions, regs \\ [a: 0, b: 0, c: 0, d: 0]) do
    program =
      String.split(instructions, "\n", trim: true)
      |> Enum.map(&String.split/1)
    run(program, regs, 0)
  end

  def run(program, regs, addr) when addr >= length(program), do: regs
  def run(program, regs, addr) do
    args = Enum.at(program, addr)
    {offset, regs} = apply(__MODULE__, :inst, args ++ [regs])
    run(program, regs, addr + offset)
  end

  defp value(x, regs) do
    case Integer.parse(x) do
      {n, _} -> n
      :error -> regs[String.to_atom(x)]
    end
  end

  def inst("inc", x, regs) do
    x = String.to_atom(x)
    v = regs[x]
    regs = put_in(regs[x], v + 1)
    {1, regs}
  end

  def inst("dec", x, regs) do
    x = String.to_atom(x)
    v = regs[x]
    regs = put_in(regs[x], v - 1)
    {1, regs}
  end

  def inst("cpy", x, y, regs) do
    y = String.to_atom(y)
    v = value(x, regs)
    regs = put_in(regs[y], v)
    {1, regs}
  end

  def inst("jnz", x, y, regs) do
    v = value(x, regs)
    y = String.to_integer(y)
    if v != 0 do
      {y, regs}
    else
      {1, regs}
    end
  end

  def solve do
    regs = process(@input)
    IO.puts "regs are #{inspect(regs)}"
  end

  def solve2 do
    regs = process(@input, [a: 0, b: 0, c: 1, d: 0])
    IO.puts "regs are #{inspect(regs)}"
  end
end

ExUnit.start

defmodule Day12Test do

  @test_input """
  cpy 41 a
  inc a
  inc a
  dec a
  jnz a 2
  dec a
  """
  use ExUnit.Case, async: true
  import Day12

  test "sample" do
    regs = process(@test_input)
    assert regs[:a] == 42
  end

end
