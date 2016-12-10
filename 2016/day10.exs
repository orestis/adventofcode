defmodule Day10 do
  defmodule Node do
    use GenServer

    def init([name, low, high]) do
      {:ok, {name, low, high, []}}
    end

    def receive(pid, value) do
      GenServer.call(pid, {:receive, value})
    end

    def peek(pid) do
      GenServer.call(pid, :peek)
    end

    def handle_call({:receive, value}, _from, {name, low, high, [] = values}) do
      {:reply, :ok, {name, low, high, [value]}}
    end

    def handle_call(:peek, _from, {name, low, high, values}) do
      {:reply, values, {name, low, high, values}}
    end

    def handle_call({:receive, value}, _from, {name, low, high, [curr]}) do
      [l, h] = Enum.sort([curr, value])
      send(:factory, {name, l, h})
      Node.receive(low, l)
      Node.receive(high, h)
      {:reply, :ok, {name, low, high, []}}
    end

  end
  def parse_line(<<"bot", _rest::binary>> = line) do
    names = Regex.scan(~r/(\w+ \d+)/, line, capture: :all_but_first)
    names = List.flatten(names)
    names = Enum.map(names, &String.to_atom/1)
    GenServer.start_link(Node, names, name: hd(names))
  end

  def parse_line("value "<> rest) do
    [value, target] = Regex.run(~r/(\d+) goes to (\w+ \d+)/,  rest, capture: :all_but_first)
    value = String.to_integer(value)
    target = String.to_atom(target)
    Node.receive(target, value)
  end

  def process_input(input, fun) do
    Process.register(self(), :factory)
    for n <- 0..20 do
      name = String.to_atom("output #{n}")
      GenServer.start_link(Node, [name, :invalid, :invalid], name: name)
    end
    pids =
      String.split(input, "\n")
      |> Enum.map(&String.trim/1)
      |> Enum.filter(&(&1 != ""))
      |> Enum.sort()
      |> Enum.map(&parse_line/1)
    fun.()
  end

  def wait_for_msg(l, h) do
    receive do
      {name, ^l, ^h} -> name
      _ -> wait_for_msg(l, h)
    end
  end

  def outputs() do
    nodes = [:"output 0", :"output 1", :"output 2"]
    values = Enum.map(nodes, &Node.peek/1)
    values = List.flatten(values)
    IO.inspect values, charlists: :as_lists
  end

  def solve() do
    input = File.read!("day10.txt")
    fun = fn -> wait_for_msg(17, 61) end
    resp = process_input(input, fun)
    IO.puts "resp was #{inspect(resp)}"
  end

  def solve2() do
    input = File.read!("day10.txt")
    fun = fn -> outputs() end
    resp = process_input(input, fun)
  end
end

ExUnit.start

defmodule Day10Test do
  use ExUnit.Case, async: true

  @input """
  value 5 goes to bot 2
  bot 2 gives low to bot 1 and high to bot 0
  value 3 goes to bot 1
  bot 1 gives low to output 1 and high to bot 0
  bot 0 gives low to output 2 and high to output 0
  value 2 goes to bot 2
  """
  @tag :skip
  test "sample" do
    assert :"bot 2" == Day10.process_input(@input, 2, 5)
  end
end
