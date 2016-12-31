ExUnit.start
defmodule Day24 do
  use ExUnit.Case

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



  # less naive approach
  # generate all permutations of numbers, such as the first numbers produce target weight
  # sort these permutations and filter by uniq
  # group by the number of elements and sort fewer -> more
  # for each list in group, get the difference and repeat with new target weight
  # if it is not possible to group rest into 2, discard the parent list
  # continue until we finish a group
  # calculate the QE for the group -> sort by less QE -> done

  def groups(numbers) do
    sum = round(Enum.sum(numbers) / 3)
    groups(0, numbers, sum)
    |> flatten()
  end

  def groups(n, numbers, sum) when sum == 0 do
    #IO.puts "n #{n}, sum #{sum}, numbers #{inspect(numbers, charlists: :as_lists)}"
    {n, []}
  end
  def groups(n, numbers, sum) when sum < 0, do: nil
  def groups(n, numbers, sum) do
    #IO.puts "n #{n}, sum #{sum} numbers #{inspect(numbers,charlists: :as_lists)}"
    combs = for i <- numbers, g = groups(i, numbers -- [i], sum - i), g != nil, g != [], do: g
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

  def solve(numbers) do
    target = round(Enum.sum(numbers) / 3)
    perms = Combination.permutate(numbers, &(valid_start(&1, target)))
    starts =
      Enum.map(perms, fn(n) -> Enum.take(n, valid_start(n, target)) |> Enum.sort() end)
      |> Enum.uniq()
      |> Enum.sort()
      |> IO.inspect
  end

  def valid_start(numbers, target_weight) do
    Enum.reduce_while(numbers, {0, 0}, fn(n, {sum, count}) ->
      cond do
        sum < target_weight -> {:cont, {sum+n, count+1}}
        sum == target_weight -> {:halt, count}
        sum > target_weight -> {:halt, false}
      end
    end)
  end

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
    assert groups(4, [5, 6, 7, 8, 9, 10, 11], 10) == {4, [{10, []}]}
    assert groups(3, [4, 5, 6, 7, 8, 9, 10, 11], 14) |> flatten() == [[3, 4, 10], [3, 5, 9], [3, 6, 8]]
    assert groups(2, [3, 4, 5, 6, 7, 8, 9, 10, 11], 17) |> flatten() == [[2, 3, 4, 10], [2, 3, 5, 9], [2, 3, 6, 8], [2, 4, 5, 8], [2, 4, 6, 7], [2, 6, 11], [2, 7, 10], [2, 8, 9]]
    #assert groups(@test_numbers, 20) == nil
  end

  test "groups" do
    assert groups([1, 2, 3, 4, 5]) == [[1, 4], [2, 3], [5]]
  end

  @tag :skip
  test "groups2" do
    assert groups(@test_numbers) == [[9, 11], [5, 7, 8], [10, 1, 2, 3, 4]]
  end


end
