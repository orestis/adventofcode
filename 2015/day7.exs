defmodule Day7 do
  @moduledoc """
--- Day 7: Some Assembly Required ---

This year, Santa brought little Bobby Tables a set of wires and 
bitwise logic gates! Unfortunately, little Bobby is a little under
the recommended age range, and he needs help assembling the circuit.

Each wire has an identifier (some lowercase letters) and can carry
a 16-bit signal (a number from 0 to 65535). A signal is provided to
each wire by a gate, another wire, or some specific value. Each wire
can only get a signal from one source, but can provide its signal to
multiple destinations. A gate provides no signal until all of its
inputs have a signal.

The included instructions booklet describes how to connect the parts
together: x AND y -> z means to connect wires x and y to an AND gate,
and then connect its output to wire z.

For example:

123 -> x means that the signal 123 is provided to wire x.
x AND y -> z means that the bitwise AND of wire x and wire y 
           is provided to wire z.
p LSHIFT 2 -> q means that the value from wire p is left-shifted
              by 2 and then provided to wire q.
NOT e -> f means that the bitwise complement of the value from wire
         e is provided to wire f.
Other possible gates include OR (bitwise OR) and RSHIFT (right-shift). 

If, for some reason, you'd like to emulate the circuit instead, almost 
all programming languages (for example, C, JavaScript, or Python) provide
operators for these gates.

In little Bobby's kit's instructions booklet (provided as your puzzle input),
what signal is ultimately provided to wire a?
"""

  @doc """
For example, here is a simple circuit:

123 -> x
456 -> y
x AND y -> d
x OR y -> e
x LSHIFT 2 -> f
y RSHIFT 2 -> g
NOT x -> h
NOT y -> i
After it is run, these are the signals on the wires:

d: 72
e: 507
f: 492
g: 114
h: 65412
i: 65079
x: 123
y: 456
  """ 
  import Bitwise

  def parse_node(s) do
    [instruction,  target] = String.split(s, " -> ")
    elems = String.split(instruction)
    node = parse(elems)
    {node, {:wire, target}}
  end

  def parse([input]) do 
    case Integer.parse(input) do
      :error -> {:wire, input}
      {int, _} -> {:value, int}
    end
  end

  def parse(["NOT", input]) do
    {:not, parse([input])}
  end

  def parse([x, "AND", y]) do
    {:and, parse([x]), parse([y])}
  end

  def parse([x, "OR", y]) do
    {:or, parse([x]), parse([y])}
  end

  def parse([x, "LSHIFT", v]) do
    {:lshift, parse([x]), String.to_integer(v)}
  end

  def parse([x, "RSHIFT", v]) do
    {:rshift, parse([x]), String.to_integer(v)}
  end

  def make_graph(nodes) do
    for {node, wire} <- nodes, into: %{}, do: {wire, node}
  end

  def get_value({:wire, n}, graph) do
    node = Map.get(graph, {:wire, n})
    IO.write("wire: " <> n <> " ")
    IO.inspect(node)
    {v, graph} = get_value(node, graph)
    graph = Map.put(graph, {:wire, n}, {:value, v})
    {v, graph}
  end

  def get_value({:value, v}, graph) do
    IO.write("value: ")
    IO.inspect(v)
    {v, graph}
  end

  def get_value({:not, x}, graph) do
    IO.write("not: ")
    IO.inspect(x)
    {v, graph} = get_value(x, graph)
    v = bnot(v) &&& 65535
    {v, graph}
  end

  def get_value({:and, x, y}, graph) do
    IO.write("and: ")
    IO.inspect(x)
    IO.inspect(y)
    {x, graph} = get_value(x, graph)
    {y, graph} = get_value(y, graph)
    v = band(x, y)
    {v, graph}
  end

  def get_value({:or, x, y}, graph) do
    IO.write("or: ")
    IO.inspect(x)
    IO.inspect(y)
    {x, graph} = get_value(x, graph)
    {y, graph} = get_value(y, graph)
    v = bor(x, y)
    {v, graph}
  end

  def get_value({:lshift, x, i}, graph) do
    IO.write("LSHIFT: ")
    IO.inspect(x)
    IO.inspect(i)
    {x, graph} = get_value(x, graph)
    v = bsl(x, i)
    {v, graph}
  end

  def get_value({:rshift, x, i}, graph) do
    IO.write("RSHIFT: ")
    IO.inspect(x)
    IO.inspect(i)
    {x, graph} = get_value(x, graph)
    v = bsr(x, i)
    {v, graph}
  end

  def test do
    s = """
    123 -> x
    456 -> y
    x AND y -> d
    x OR y -> e
    x LSHIFT 2 -> f
    y RSHIFT 2 -> g
    NOT x -> h
    NOT y -> i
    """
    lines = Regex.split(~r/\R/, s) |> Enum.filter(fn(l) -> l != "" end)
    nodes = Enum.map(lines, &parse_node/1)
    IO.inspect(nodes)
    graph = make_graph(nodes)
    IO.inspect(graph)
    {123, graph} = get_value({:wire, "x"}, graph)
    {456, graph} = get_value({:wire, "y"}, graph)
    {72, graph} = get_value({:wire, "d"}, graph)
    {507, graph} = get_value({:wire, "e"}, graph)
    {492, graph} = get_value({:wire, "f"}, graph)
    {114, graph} = get_value({:wire, "g"}, graph)
    {65412, graph} = get_value({:wire, "h"}, graph)
    {65079, graph} = get_value({:wire, "i"}, graph)
    IO.inspect(graph)

  end

  def solve do
    {:ok, input} = File.read("day7.input.txt")
    lines = Regex.split(~r/\R/, input)
    graph = lines
      |> Enum.map(&parse_node/1)
      |> make_graph
    {a, _} = get_value({:wire, "a"}, graph)
    IO.puts "wire a is"
    IO.inspect(a)
    graph = Map.put(graph, {:wire, "b"}, {:value, a})
    {a, _} = get_value({:wire, "a"}, graph)
    IO.puts "after override wire a is"
    IO.inspect(a)


  end
end

Day7.test
Day7.solve