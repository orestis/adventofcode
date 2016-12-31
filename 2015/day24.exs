ExUnit.start
defmodule Day24 do
  use ExUnit.Case, async: true

  @numbers ~w(1
            2
            3
            7
            11
            13
            17
            19
            23
            31
            37
            41
            43
            47
            53
            59
            61
            67
            71
            73
            79
            83
            89
            97
            101
            103
            107
            109
            113) |> Enum.map(&String.to_integer/1)

  @test_numbers [1, 2, 3, 4, 5, 7, 8, 9, 10, 11]

  def solve_naive(numbers) do
    # first, get all the possible ways you can divide the weights into 3:
    combs = groups(numbers, 3)
    IO.puts "combs"
    # then, for each combination, ensure that we can combine the rest into 2
    valid =
      for c <- combs, subcomps = groups(numbers -- c, 2), subcomps != [], do: c

    IO.puts "valid"

    valid = Enum.sort(valid) |> Enum.reverse()
    smallest = Enum.chunk_by(valid, &length/1) |> hd()
    less_qe = Enum.sort_by(smallest, &qe/1) |> hd() |> qe()
  end

  def solve(numbers, parts \\ 3) do
    target = round(Enum.sum(numbers) / parts)
    numbers = Enum.sort(numbers) |> Enum.reverse()
    {_, min_count} = Enum.reduce_while(numbers, {0, 0}, fn(n, {sum, count}) ->
      cond do
        sum < target -> {:cont, {sum + n, count + 1}}
        true -> {:halt, {sum, count}}
      end
    end)
    fewer_packages =
      Stream.iterate(min_count, &(&1 + 1))
      |> Stream.map(fn(count) -> Combination.combine(numbers, count) end)
      |> Stream.map(fn(combinations) ->
        Enum.filter(combinations, &(Enum.sum(&1) == target))
      end)
      |> Stream.filter(fn(valid_combinations) -> length(valid_combinations) > 0 end)
      |> Enum.take(1)
      |> hd()

    fewer_packages
    |> Enum.map(&qe/1)
    |> Enum.sort()
    |> hd()
  end



  def qe(numbers) do
    Enum.reduce(numbers, 1, &(&1 * &2))
  end

  def groups(numbers, parts) do
    sum = round(Enum.sum(numbers) / parts)
    #IO.puts "must divide #{insp numbers}, total #{Enum.sum(numbers)} into #{parts} parts of #{sum} weight"
    case groups(0, MapSet.new(numbers), sum) do
      nil -> []
      other -> flatten(other)
    end
  end

  def groups(n, _numbers, sum) when sum == 0 do
    #IO.puts "n #{n}, sum #{sum}, numbers #{inspect(numbers, charlists: :as_lists)}"
    {n, []}
  end
  def groups(n, numbers, sum) do
    #IO.puts "n #{n}, sum #{sum} numbers #{inspect(numbers,charlists: :as_lists)}"
    combs = for i <- numbers, i <= sum, do: groups(i, MapSet.delete(numbers, i), sum - i)
    combs = Enum.reject(combs, fn(c) -> c == nil end)
    if combs != [] do
      {n, combs}
    else
      nil
    end
  end

  def insp(t) do
    inspect(t, charlists: :as_lists)
  end

  def flatten(group) do
    flatten_tree(group)
    |> Enum.map(&List.wrap/1)
    |> Enum.map(&Enum.sort/1)
    |> Enum.uniq()
  end

  def flatten_tree({n, []}) do
    [n]
  end
  def flatten_tree({0, rest}) do
    Enum.flat_map(rest, fn(r) ->
      flatten_tree(r)
    end)
  end
  def flatten_tree({n, rest}) do
    subtrees = Enum.flat_map(rest, fn(r) ->
      flatten_tree(r)
      end)
    for t <- subtrees, do: [n|List.wrap(t)]
  end
  def flatten_tree([]), do: []
  def flatten_tree(n), do: [n]



  test "flatten" do
    assert flatten({4, [{10, []}]}) == [[4, 10]]
    assert flatten({4, [10]}) == [[4, 10]]
    assert flatten({3, [{4, [10]}] }) == [[3, 4, 10]]
    assert flatten({3, [{4, [10]}, {5, [9]}, {6, [8]}]}) == [[3, 4, 10], [3, 5, 9], [3, 6, 8]]
    assert flatten({2,
                    [{3,
                      [{4, [{10, []}]}, {5, [{9, []}]}, {6, [{8, []}]}, {8, [{6, []}]},
                       {9, [{5, []}]}, {10, [{4, []}]}]},
                     {4,
                      [{3, [{10, []}]}, {5, [{8, []}]}, {6, [{7, []}]}, {7, [{6, []}]},
                       {8, [{5, []}]}, {10, [{3, []}]}]}]}) == [[2, 3, 4, 10], [2, 3, 5, 9], [2, 3, 6, 8], [2, 4, 5, 8],
                                                                [2, 4, 6, 7]]
  end

  test "groups 2" do
    assert groups(4, MapSet.new([5, 6, 7, 8, 9, 10, 11]), 10) == {4, [{10, []}]}
    assert groups(3, MapSet.new([4, 5, 6, 7, 8, 9, 10, 11]), 14) |> flatten() == [[3, 4, 10], [3, 5, 9], [3, 6, 8]]
    assert groups(2, MapSet.new([3, 4, 5, 6, 7, 8, 9, 10, 11]), 17) |> flatten() == [[2, 3, 4, 10], [2, 3, 5, 9], [2, 3, 6, 8], [2, 4, 5, 8], [2, 4, 6, 7], [2, 6, 11], [2, 7, 10], [2, 8, 9]]
    #assert groups(@test_numbers, 20) == nil
  end

  @tag :skip
  test "groups" do
    assert groups([1, 2, 3, 4, 5], 3) == [[1, 4], [2, 3], [5]]
  end

  test "invalid groups" do
    assert groups(@test_numbers -- [1, 2, 3, 5, 9], 2) == []
  end

  @tag :skip
  test "groups2" do
    assert groups(@test_numbers, 3) == [[9, 11], [5, 7, 8], [10, 1, 2, 3, 4]]
  end

  test "sample" do
    assert solve(@test_numbers) == 99
  end

  test "sample 2" do
    assert solve(@test_numbers, 4) == 44
  end

  @tag :skip
  test "part 1" do
    assert solve(@numbers) == -1
  end

  test "part 2" do
    assert solve(@numbers, 4) == -1
  end


end
