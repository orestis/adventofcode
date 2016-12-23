ExUnit.start
defmodule Day23 do
  use ExUnit.Case

  @modified_input """
  cpy a b
  dec b
  mul a b
  jnz 1 1
  jnz 1 1
  jnz 1 1
  jnz 1 1
  jnz 1 1
  jnz 1 1
  jnz 1 1
  dec b
  cpy b c
  cpy c d
  dec d
  inc c
  jnz d -2
  tgl c
  cpy -16 c
  jnz 1 c
  cpy 85 c
  jnz 76 d
  inc a
  inc d
  jnz d -2
  inc c
  jnz c -5
  """

  @input """
  cpy a b
  dec b
  cpy a d
  cpy 0 a
  cpy b c
  inc a
  dec c
  jnz c -2
  dec d
  jnz d -5
  dec b
  cpy b c
  cpy c d
  dec d
  inc c
  jnz d -2
  tgl c
  cpy -16 c
  jnz 1 c
  cpy 85 c
  jnz 76 d
  inc a
  inc d
  jnz d -2
  inc c
  jnz c -5
  """


  @annotated_input """
  00 cpy a b
  01 dec b   -- a = 12, b = 11
  
  02 cpy a d -- multiply a with b
  03 cpy 0 a
  04 cpy b c
  05 inc a
  06 dec c
  07 jnz c -2
  08 dec d
  09 jnz d -5 -- end multiply - a = a * b, c=0, d=0
  
  10 dec b    -- b is 10, 9, ...
  11 cpy b c
  12 cpy c d
  13 dec d
  14 inc c
  15 jnz d -2  -- end: c = 2 * b

  16 tgl c     -- when c = 9, instruction 25 will become "cpy c -5"
  17 cpy -16 c
  18 cpy 1 c  -- c = 2 -- bah, wrong calculation, solution was to replace the assembunny instructions with an actual mul
  19 jnz 85 c -- c = 3
  20 cpy 76 d -- c = 4
  21 dec a    -- c = 5
  22 dec d    -- c = 6
  23 cpy d -2 -- c = 7
  24 dec c    -- c = 8
  25 cpy c -5 -- c = 9
  """

  @sample_input """
  cpy 2 a
  tgl a
  tgl a
  tgl a
  cpy 1 a
  dec a
  dec a
  """

  defmodule Program do
    use GenServer

    def init(program) do
      {:ok, program}
    end

    def get(pid, addr) do
      GenServer.call(pid, {:get, addr})
    end

    def toggle(pid, addr) do
      GenServer.call(pid, {:toggle, addr})
    end

    def handle_call({:get, addr}, _from, program) do
      args = Enum.at(program, addr)
      {:reply, args, program}
    end

    def handle_call({:toggle, addr}, _from, program) do
      case Enum.at(program, addr) do
        nil -> {:reply, :ok, program}
        args ->
          IO.puts "toggling at #{addr} #{inspect(args)}"
          toggled = toggle(args)
          program = List.replace_at(program, addr, toggled)
          {:reply, :ok, program}
      end
    end

    def toggle(["inc", x]) do
      ["dec", x]
    end
    def toggle([_, x]) do
      ["inc", x]
    end
    def toggle(["jnz", x, y]) do
      ["cpy", x, y]
    end
    def toggle([_, x, y]) do
      ["jnz", x, y]
    end
  end

  def process(instructions, regs \\ [a: 0, b: 0, c: 0, d: 0]) do
    program =
      String.split(instructions, "\n", trim: true)
      |> Enum.map(&String.split/1)

    {:ok, program} = GenServer.start_link(Program, program, name: Program)
    run(program, regs, 0)
  end

  def run(program, regs, addr) do
    args = Program.get(program, addr)
    #IO.puts "addr #{addr}: #{inspect(args)}"
    case args do
      nil -> regs
      _ ->
        {offset, regs} = apply(__MODULE__, :inst, args ++ [regs, addr])
        run(program, regs, addr + offset)
    end
  end

  defp value(x, regs) do
    case Integer.parse(x) do
      {n, _} -> n
      :error -> Keyword.fetch!(regs, String.to_atom(x))
    end
  end

  def update_regs(regs, k, v) do
    # first fetch
    Keyword.fetch!(regs, k)
    Keyword.put(regs, k, v)
  end

  def inst("tgl", x, regs, addr) do
    v = value(x, regs)
    Program.toggle(Program, addr + v)
    {1, regs}
  end

  def inst("inc", x, regs, addr) do
    x = String.to_atom(x)
    v = regs[x]
    regs = update_regs(regs, x, v + 1)
    {1, regs}
  end

  def inst("mul", x, y, regs, addr) do
    a = value(x, regs)
    b = value(y, regs)
    regs = update_regs(regs, String.to_atom(x), a * b)
    {1, regs}
  end

  def inst("dec", x, regs, addr) do
    x = String.to_atom(x)
    v = regs[x]
    regs = update_regs(regs, x, v - 1)
    {1, regs}
  end

  def inst("cpy", x, y, regs, addr) do
    y = String.to_atom(y)
    v = value(x, regs)
    regs = update_regs(regs, y, v)
    {1, regs}
  end

  def inst("jnz", x, y, regs, addr) do
    v = value(x, regs)
    y = value(y, regs)
    if v != 0 do
      {y, regs}
    else
      {1, regs}
    end
  end

  @tag :skip
  test "sample" do
    regs = process(@sample_input)
    assert regs[:a] == 3
  end

  @tag :skip
  test "part 1" do
    regs = [a: 7, b: 0, c: 0, d: 0]
    regs = process(@input, regs)
    assert regs == nil
  end

  test "part 2" do
    regs = [a: 12, b: 0, c: 0, d: 0]
    regs = process(@modified_input, regs)
    assert regs == nil
  end
end
