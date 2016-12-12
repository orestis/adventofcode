defmodule Day11 do
  defmodule Queue do
    use GenServer

    def new() do
      {:ok, pid} = GenServer.start_link(__MODULE__, [])
      pid
    end

    def stop(pid) do
      GenServer.stop(pid)
    end

    def init(args) do
      q = :queue.new()
      IO.puts "queue is #{inspect(q)}"
      {:ok, q}
    end

    def get(pid) do
      GenServer.call(pid, :get)
    end

    def peek(pid) do
      GenServer.call(pid, :peek)
    end

    def drop(pid) do
      GenServer.call(pid, :drop)
    end

    def put(pid, item) do
      GenServer.call(pid, {:put, item})
    end

    def put_list(pid, list) do
      GenServer.call(pid, {:put_list, list})
    end

    def handle_call(:get, _from, q) do
      {ret, q} = :queue.get(q)
      {:reply, ret, q}
    end

    def handle_call(:peek, _from, q) do
      ret = :queue.peek(q)
      {:reply, ret, q}
    end

    def handle_call(:drop, _from, q) do
      q = :queue.drop(q)
      {:reply, :ok, q}
    end

    def handle_call({:put, item}, _from, q) do
      IO.puts "PUT queue is #{inspect(q)}"
      q = :queue.in(item, q)
      {:reply, :ok, q}
    end

    def handle_call({:put_list, list}, _from, q) do
      n = :queue.from_list(list)
      q = :queue.join(q, n)
      {:reply, :ok, q}
    end

  end

  def new_graph() do
    :digraph.new([:acyclic])
  end

  def puzzle_input do
    {0, [["GP", "GS", "GT", "MT"], ["MP", "MS"], ["GQ", "GR", "MQ", "MR"], []]}
  end

  def found?({elev, floors} = state, end_state) do
    length(Enum.at(floors, 3)) == end_state
  end

  def filter_below(states, {elev, floors}) do
    {floors_below, floors_above} = Enum.split(floors, elev)
    all_floors_below_empty = Enum.reduce(floors_below, true, fn(floor, acc) ->
      acc and length(floor) == 0
    end)
    if all_floors_below_empty do
      Stream.reject(states, fn({new_elev, _floors}) ->
        new_elev < elev
      end)
    else
      states
    end
  end

  def filter_states(states, {elev, floors} = curr, seen) do
    Stream.filter(states, fn(s) ->
      #IO.puts "checking state #{inspect(s)} which hashed to #{inspect(to_hash(s))}"
      not MapSet.member?(seen, to_hash(s))
    end)
    #|> filter_below(curr)
    |> Enum.to_list()
  end

  def to_hash({elev, floors} = state) do
    pairs =
      Enum.with_index(floors)
      |> Enum.flat_map(fn({floor, idx}) -> for <<_type, el>> <- floor, do: {<<el>>, idx} end)
      |> Enum.reduce(%{}, fn({el, floor}, map) ->
        l = Map.get(map, el, [])
        Map.put(map, el, [floor|l])
        end)
      |> Map.values()
      |> List.to_tuple()
    {elev, pairs}
  end

  def process(state, end_state, seen) do
    seen = MapSet.put(seen, to_hash(state))
    children = generate_new_state(state) |> filter_states(state, seen)
    {children, seen}
  end

  def walk_queue(queue, next_queue, end_state, seen, depth) do
    #if depth == 2, do: Process.halt(0)
    case Queue.peek(queue) do
      {:value, curr} ->
        Queue.drop(queue)
        if found?(curr, end_state) do
          IO.puts "DONE #{depth}"
          to_hash(curr)
          depth
        else
          {my_children, seen} = process(curr, end_state, seen)
          Queue.put_list(next_queue, my_children)
          walk_queue(queue, next_queue, end_state, seen, depth)
        end
      :empty ->
        IO.puts ">>>>>>>>>> GOINT DEEPER <<<<<<<<<<<<<<<<<<< at depth #{depth+1}"
        Queue.stop(queue)
        walk_queue(next_queue, Queue.new(), end_state, seen, depth + 1)
    end
  end



  def generate_new_state({elev, floors} = current) do
    curr_floor = Enum.at(floors, elev)
    passengers = valid_passengers(current)
    new_positions = Enum.filter([elev + 1, elev - 1], fn(x) -> (x >= 0) and (x <= 3) end)
    new_floors =
      (for p <- new_positions, pass <- passengers, do: {p, Enum.at(floors, p) ++ pass, pass})
      |> Enum.filter(fn ({_el, floor, _pass}) -> valid_floor(floor) end)

    Enum.map(new_floors, fn({p, floor, pass}) ->
      new_curr_floor = curr_floor -- pass
      new_floors =
        List.replace_at(floors, elev, new_curr_floor)
        |> List.replace_at(p, floor)
        #|> Enum.map(&Enum.sort/1)
      {p, new_floors}
    end)
    #|> Enum.sort()
  end

  def valid_passengers({elev, floors}) do
    curr_floor = Enum.at(floors, elev)
    possible_passengers =
      (pairs(curr_floor) ++ Enum.map(curr_floor, &List.wrap/1))
      |> Enum.filter(&valid_pair/1)
      |> Enum.filter(fn(pass) -> valid_floor(curr_floor -- pass) end)
    possible_passengers
  end

  def valid_floor(floor) do
    paired = pairs(floor)
    shielded_microchips =
      Enum.filter(paired, &shielded_pair/1)
      |> List.flatten()
      |> Enum.filter(fn
          ("M" <> _) -> true
          (_) -> false
        end)
    Enum.all?(pairs(floor -- shielded_microchips), &valid_pair/1)
  end

  def shielded_pair(["G" <> a, "M" <> a]), do: true
  def shielded_pair(["M" <> a, "G" <> a]), do: true
  def shielded_pair(_), do: false

  def valid_pair([_]), do: true
  def valid_pair(["G" <> a, "M" <> a]), do: true
  def valid_pair(["M" <> a, "G" <> a]), do: true
  def valid_pair(["G" <> _, "G" <> _]), do: true
  def valid_pair(["M" <> _, "M" <> _]), do: true
  def valid_pair(_), do: false


  def pairs([]), do: []
  def pairs([_]), do: []
  def pairs([h|t]) do
    p = for e <- t, do: [h, e]
    p ++ pairs(t)
  end

  def end_state(initial) do
    final_state = Enum.reduce(elem(initial, 1), [], fn(floor, acc) ->
      acc ++ floor
    end)
    length(final_state)
  end

  def test_input do
    {0, [["MH", "ML"], ["GH"], ["GL"], []]}
  end

  def solve_queue(initial \\ puzzle_input()) do
    final_state = end_state(initial)
    queue = Queue.new()
    Queue.put(queue, initial)
    walk_queue(queue, Queue.new(), final_state, MapSet.new(), 0)
  end

end

ExUnit.start

defmodule Day11Test do
  use ExUnit.Case, async: true

  import Day11

  @input """
  The first floor contains a hydrogen-compatible microchip and a lithium-compatible microchip.
  The second floor contains a hydrogen generator.
  The third floor contains a lithium generator.
  The fourth floor contains nothing relevant.
  """

  @puzzle_input """
  The first floor contains a thulium generator, a thulium-compatible microchip, a plutonium generator, and a strontium generator.
  The second floor contains a plutonium-compatible microchip and a strontium-compatible microchip.
  The third floor contains a promethium generator, a promethium-compatible microchip, a ruthenium generator, and a ruthenium-compatible microchip.
  The fourth floor contains nothing relevant.
  """

  @tag :skip
  test "newstate" do
    curr = test_input()
    next = {1, [["ML"], ["GH", "MH"], ["GL"], []]}
    assert [next] == generate_new_state(curr)
    assert [
      curr,
      {2, [["ML"], [], ["GH", "GL", "MH"], []]},
      {2, [["ML"], ["MH"], ["GH", "GL"], []]},
    ] == generate_new_state(next)
  end

  @tag :skip
  test "valid passengers" do
    curr = test_input()
    assert [["MH", "ML"], ["MH"], ["ML"]] == valid_passengers(curr)

    assert [["GH", "MH"], ["GH", "GL"], ["MH"], ["GL"]] == valid_passengers({0, [["GH", "MH", "GL"], [], [], []]})
  end

  test "valid pairs" do
    assert true == valid_pair(["MH", "ML"])
    assert false == valid_pair(["GH", "ML"])
  end

  test "shielded pair" do
    assert true == shielded_pair(["MH", "GH"])
    assert false == shielded_pair(["ML", "GH"])
  end

  test "valid floor" do
    assert true == valid_floor(["GH", "MH"])
    assert false == valid_floor(["GH", "MH", "ML"])
    assert true == valid_floor(["GL", "GH", "MH"])
    assert true == valid_floor(["GL", "GS"])
    assert true == valid_floor(["ML", "MS"])
  end

  test "pairs" do
    assert pairs([:a, :b, :c, :d]) == [[:a, :b], [:a, :c], [:a, :d], [:b, :c], [:b, :d], [:c, :d]]
  end

  @tag :skip
  test "check" do
    assert [] == generate_new_state({2, [["ML"], [], ["GH", "GL", "MH"], []]})
  end

  test "sample" do
    assert 11 == solve_queue(test_input())
  end

end
