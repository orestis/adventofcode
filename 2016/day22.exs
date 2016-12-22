ExUnit.start

defmodule Day22 do
  use ExUnit.Case

  defmodule Node do
    defstruct x: 0, y: 0, used: 0, avail: 0, total: 0
  end

  def parse("/dev/grid/node-" <> node) do
    r = ~r/x(\d+)-y(\d+)\s+(\d+)T\s+(\d+)T\s+(\d+)T.*/
    [x, y, total, used, avail] = Regex.run(r, node, capture: :all_but_first)
    m = for {k, v} <- Enum.zip([:x, :y, :total, :used, :avail], [x, y, total, used, avail]), into: %{}, do: {k, String.to_integer(v)}
    struct(Node, m)
  end

  def input() do
    File.stream!("day22.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.drop(2)
  end

  def get_nodes(input) do
    input |> Enum.map(&parse/1)
  end

  def viable_pair(%Node{used: used} = a, b) when a != b and used != 0 do
    a.used <= b.avail
  end
  def viable_pair(_a, _b), do: false

  # assumes that nodes will be listed from MOST free size to LEAST free size
  def viable_pairs_for_node([h|t], node, pairs) do
    if viable_pair(node, h) do
      viable_pairs_for_node(t, node, [h|pairs])
    else
      # the next node will have even less free space, so don't bother
      pairs
    end
  end
  def viable_pairs_for_node([], _node, pairs), do: pairs

  def all_viable_pairs(nodes) do
    IO.puts "total nodes #{length(nodes)}"
    nodes_by_free_space = Enum.sort_by(nodes, fn(n) -> n.avail end, &>=/2)
    nodes_by_used_space = Enum.sort_by(nodes, fn(n) -> n.used end, &>=/2)

    viable_pairs = Enum.flat_map(nodes_by_used_space, fn(node) ->
      viable_pairs_for_node(nodes_by_free_space, node, [])
    end)
    |> length()
  end

  test "all viable pairs" do
    nodes = get_nodes(input())
    assert all_viable_pairs(nodes) == nil
  end

  test "parse node" do
    n = parse("/dev/grid/node-x11-y19   93T   65T    28T   69%")
    assert n.x == 11
    assert n.y == 19
    assert n.total == 93
    assert n.used == 65
    assert n.avail == 28
  end

  test "viable pairs" do
    n1 = parse("/dev/grid/node-x11-y19   93T   65T    28T   69%")
    n2 = parse("/dev/grid/node-x0-y25    91T   68T    23T   74%")
    n3 = parse("/dev/grid/node-x0-y25    91T   18T    73T   74%")

    refute viable_pair(n1, n1)
    refute viable_pair(n1, n2)
    assert viable_pair(n1, n3)
    assert viable_pair(n2, n3)
    assert viable_pair(n3, n1)
    assert viable_pair(n3, n2)
  end

end



