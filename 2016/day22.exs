ExUnit.start

defmodule Day22 do
  use ExUnit.Case

  defmodule Node do
    defstruct x: 0, y: 0, used: 0, avail: 0, total: 0
    defimpl String.Chars, for: Node do
      def to_string(node), do: inspect(node)
    end
  end


  def parse("/dev/grid/node-" <> node) do
    r = ~r/x(\d+)-y(\d+)\s+(\d+)T\s+(\d+)T\s+(\d+)T.*/
    [x, y, total, used, avail] = Regex.run(r, node, capture: :all_but_first)
    m = for {k, v} <- Enum.zip([:x, :y, :total, :used, :avail], [x, y, total, used, avail]), into: %{}, do: {k, String.to_integer(v)}
    struct(Node, m)
  end

  def input(fname \\ "day22.txt") do
    File.stream!(fname)
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

  def make_grid(nodes, w, h) do
    g = :digraph.new()

    Enum.each(nodes, fn(node) ->
      v = {node.x, node.y}
      :digraph.add_vertex(g, v, node)
    end)

    g
  end

  def analyze_nodes(nodes) do
    empty_node = Enum.sort_by(nodes, fn(n) -> n.avail end, &>=/2) |> Enum.take(1) |> Enum.at(0)
    IO.puts "empty node is #{empty_node}"
    empty_node
  end

  def print_grid(grid, w, h) do
    IO.puts ""
    IO.puts "~~~~~~~grid of #{w}x#{h}~~~~~~~~~"
    for y <- 0..(h-1), x <- 0..(w-1) do

      {{x, y}, node} = :digraph.vertex(grid, {x, y})
      if x == 0 and y > 0 do
        IO.puts ""
      end
      IO.write String.pad_leading("#{node.used}/", 3)
      IO.write String.pad_leading("#{node.total}", 2)
      if x < w-1, do: IO.write " - "
    end
    IO.puts ""

  end

  def find_path(initial, target, grid) do
    require BFS
    end_check = fn(node) -> node == target end
    get_next = fn({x, y}) ->
      {{x, y}, curr} = :digraph.vertex(grid, {x, y})
      next_pos = [{x-1, y}, {x+1, y}, {x, y+1}, {x, y-1}]
      next_nodes =
        Enum.map(next_pos, fn(pos) -> :digraph.vertex(grid, pos) end)
        |> Enum.reject(fn(node_or_false) -> node_or_false == false end)
        |> Enum.map(fn({{x, y}, node}) -> node end)
        |> Enum.filter(fn(node) -> node.used <= curr.total end)
        |> Enum.map(fn(node) -> {node.x, node.y} end)

      #IO.puts "node #{curr} has viable neighbors #{inspect(next_nodes)})"
      next_nodes
    end

    steps = BFS.walk_bfs(initial, get_next, end_check)
    IO.puts "can reach #{inspect(target)} from #{inspect(initial)} in #{steps} steps"

    steps

  end

  def shortest_path(nodes) do
    # assuming the instructions are not misleading and indeed
    # the nodes are interchangeable, except of the empty one
    # and the larges ones

    # we can make a graph of all the nodes that are connected
    # wherever there is an immovable node, we will leave it out
    # and therefore sever the connections in the grid

    # the first part is to bring the empty node to a spot adjacent
    # to the Goal node
    # there are four (or less) adjacent spots
    # for each spot S, calculate the path between E -> S

    # this is the first step of the problem, which is a simple
    # "shortest_path" implementation
    # as we use only 1 operation to move the empty node closer

    # once we are adjacent to the Goal node, the grid is transformed
    # to a weighted one; the weight or cost of each edge is the number
    # of operations it takes to move the Goal node there
    # this is at least 6 for an unobstructed grid but it could be more
    # if there are unmovable nodes in the way

    # once the costs are calculated, we can use Dijkstra's algorithm
    # to find the shortest path from the Goal to Target (0, 0).
    # To get the puzzle answer we get the total Dijkstra cost of the
    # shortest path to the the cost of the first part of the problem

  end

  @tag :skip
  test "part 2 test" do
    nodes = get_nodes(input("day22.test.txt"))
    empty_node = analyze_nodes(nodes)
    grid = make_grid(nodes, 3, 3)
    print_grid(grid, 3, 3)

    find_path({empty_node.x, empty_node.y}, {2, 0}, grid)
  end

  test "part 2" do
    nodes = get_nodes(input())
    empty_node = analyze_nodes(nodes)
    grid = make_grid(nodes, 38, 26)
    print_grid(grid, 38, 3)
    # 37 is the TARGET
    # 36 is LEFT of TARGET
    first_part = find_path({empty_node.x, empty_node.y}, {36, 0}, grid)
    # we know how many moves to get to the LEFT of TARGET

    # to get the empty node back to the ORIGIN we will need...
    second_part = find_path({36, 0}, {0, 0}, grid)

    # big assumption (to be tested)

    IO.puts "we will need #{first_part} + 5 * #{second_part} + 1"
    IO.puts "that is #{first_part + 5 * second_part + 1}"
  end

  @tag :skip
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



