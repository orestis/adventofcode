ExUnit.start
defmodule Day25 do
  use ExUnit.Case
  @input """
  cpy a d
  cpy 14 c
  cpy 182 b
  inc d
  dec b
  jnz b -2
  dec c
  jnz c -5
  cpy d a
  jnz 0 0
  cpy a b
  cpy 0 a
  cpy 2 c
  jnz b 2
  jnz 1 6
  dec b
  dec c
  jnz c -4
  inc a
  jnz 1 -7
  cpy 2 b
  jnz c 2
  jnz 1 4
  dec b
  dec c
  jnz 1 -4
  jnz 0 0
  out b
  jnz a -19
  jnz 1 -21
  """

  @modified_input """
  cpy a d
  cpy 14 c # 14
  cpy 182 b # 182
  muladd b c d   # d = a + b * c (input)
  cpy 0 b
  cpy 0 c
  jnz 0 0
  jnz 0 0
  cpy d a # label START a = input
  jnz 0 0 # label CONT
  cpy a b # DIVMOD2           # DIVMOD2(a) -> a = a // 2, c = 1 (odd) or 2 (even), b = 0, d = d
  cpy 0 a
  cpy 2 c # DIVMOD_1
  jnz b 2 # DIVMOD_2
  jnz 1 6 # return DIVMOD (G)
  dec b
  dec c
  jnz c -4 # jnz c DIVMOD_2
  inc a
  jnz 1 -7 # goto DIVMOD_1
  cpy 2 b  # label G
  jnz c 2 # jnz c Z , label D
  jnz 1 4 # goto OUT
  dec b   # label Z
  dec c
  jnz 1 -4 # goto D
  jnz 0 0  # label OUT
  out b  # OUT
  jnz a -19 # jnz a CONT
  jnz 1 -21 # goto START
  """



  def actual_program(d, io) do
    a = d
    a = div(a, 2)
    c = rem(a, 2)
    io = [c|io]
    if a == 0 do
      io
    else
      actual_program(a, io)
    end
  end

  def check(io) when rem(length(io), 2) == 0 do
    Enum.all?(Enum.chunk(io, 2), fn(p) -> p == [0, 1] end)
  end
  def check(_), do: false


  def process(instructions, regs \\ [a: 0, b: 0, c: 0, d: 0]) do
    program =
      String.split(instructions, "\n", trim: true)
      |> Enum.map(fn(line) -> String.split(line, "#") |> Enum.at(0) |> String.trim() end)
      |> Enum.map(&String.split/1)

    run(program, regs, 0, [], 0, %{})
  end

  def print_stats(steps, stats) do
    if rem(steps, 14 * 182 + 1) == 0 do
      IO.puts "at steps #{steps}"
      for i <- 0..30 do
        IO.puts "#{i}: #{Map.get(stats, i)}"
      end
    end
  end

  def run(program, regs, addr, io, steps, stats) do
    stats = Map.put(stats, addr, Map.get(stats, addr, 0) + 1)
    args = Enum.at(program, addr)
    if addr == 20 do
      IO.puts "#{steps} addr #{addr}: #{Enum.join(args, " ")} io #{inspect(io)} regs #{inspect(regs)}"
    end
    #IO.puts "#{steps} addr #{addr}: #{Enum.join(args, " ")} io #{inspect(io)} regs #{inspect(regs)}"
    # print_stats(steps, stats)
    case args do
      nil -> regs
      _ ->
        prev_io = io
        {offset, regs, io} = apply(__MODULE__, :inst, args ++ [regs, io])
        if io != prev_io do
          IO.inspect io
        end
        run(program, regs, addr + offset, io, steps+1, stats)
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

  def inst("muladd", x, y, z, regs, io) do
    a = value(x, regs)
    b = value(y, regs)
    c = value(z, regs)
    m = a * b + c
    IO.puts "muladd #{m}"
    regs = update_regs(regs, String.to_atom(z), m)
    {1, regs, io}
  end


  def inst("out", x, regs, io) do
    a = value(x, regs)
    {1, regs, [a|io]}
  end

  def inst("inc", x, regs, io) do
    x = String.to_atom(x)
    v = regs[x]
    regs = update_regs(regs, x, v + 1)
    {1, regs, io}
  end

  def inst("dec", x, regs, io) do
    x = String.to_atom(x)
    v = regs[x]
    regs = update_regs(regs, x, v - 1)
    {1, regs, io}
  end

  def inst("mul", x, y, regs, io) do
    a = value(x, regs)
    b = value(y, regs)
    regs = update_regs(regs, String.to_atom(x), a * b)
    {1, regs, io}
  end

  def inst("cpy", x, y, regs, io) do
    y = String.to_atom(y)
    v = value(x, regs)
    regs = update_regs(regs, y, v)
    {1, regs, io}
  end

  def inst("jnz", x, y, regs, io) do
    v = value(x, regs)
    y = value(y, regs)
    if v != 0 do
      {y, regs, io}
    else
      {1, regs, io}
    end
  end

  @tag :skip
  test "part 1 program" do
    process(@modified_input, [a: 0, b: 0, c: 0, d: 0])
  end

  def solve() do
    Stream.iterate(0, &(&1 + 1))
    |> Stream.drop_while(fn(a) ->
      d = a + 14 * 182
      not check(actual_program(d, []))
      end)
    |> Enum.take(1)
    |> Enum.at(0)
  end

  test "part 1" do
    assert solve() == -1
  end
end
