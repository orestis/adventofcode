defmodule Day14 do
  def md5(n, salt) do
    md5(salt <> Integer.to_string(n))
  end
  def md5(s) do
    :crypto.hash(:md5, s) |> Base.encode16(case: :lower)
  end

  def md5_stretch(s, repeats \\ 2016, ets_table \\ :stretch) do
    case :ets.lookup(ets_table, {s, repeats}) do
      [] ->
        res = do_md5_stretch(s, repeats)
        :ets.insert(ets_table, {{s, repeats}, res})
        res
      [{_, r}] -> r
    end
  end

  def do_md5_stretch(s, 0), do: s
  def do_md5_stretch(s, repeats) do
    do_md5_stretch(md5(s), repeats-1)
  end

  @triple ~r/.*(\d|[a-z])\1\1.*/
  def triple(n, salt), do: triple(md5(n, salt))
  def triple(s) do
    case Regex.run(@triple, s, capture: :all_but_first) do
      [h|_t] -> h
      _ -> false
    end
  end

  @quintuple ~r/.*(.)\1\1\1\1.*/
  def quintuple(s, opts \\ [ets_table: nil]) do
    if t = opts[:ets_table] do
      case :ets.lookup(t, {:q, s}) do
        [] ->
          res = do_quintuple(s)
          :ets.insert(t, {{:q, s}, res})
          res
        [{_, r}] -> r
      end
    else
      do_quintuple(s)
    end
  end

  def do_quintuple(s) do
    case Regex.run(@quintuple, s, capture: :all_but_first) do
      [h|_t] -> h
      _ -> nil
    end
  end

  def counter(n) do
    Stream.iterate(n, &(&1 + 1))
  end

  def key2(n, salt) do
    if t = triple(md5_stretch(md5(n, salt))) do
      Enum.reduce_while(counter(n+1), :unused, fn(idx, acc) ->
        if idx >= (n + 1000) do
          {:halt, false}
        else
          if quintuple(md5_stretch(md5(idx, salt)), [ets_table: :stretch]) == t, do: {:halt, true}, else: {:cont, acc}
        end
      end)
    else
      false
    end
  end

  def key(n, salt) do
    if t = triple(n, salt) do
      Enum.reduce_while(counter(n+1), :unused, fn(idx, acc) ->
        if idx >= (n + 1000) do
          {:halt, false}
        else
          if quintuple(md5(idx, salt)) == t, do: {:halt, true}, else: {:cont, acc}
        end
        end)
    else
      false
    end
  end

  def solve(salt, keyfun \\ &key/2) do
    counter(0)
    |> Stream.map(& {keyfun.(&1, salt), &1})
    |> Stream.filter(fn({iskey, _n}) -> iskey end)
    |> Stream.map(fn({_true, n}) -> IO.puts "key #{n}"; n end)
    |> Enum.take(65)
    |> Enum.at(-1)
  end

end

ExUnit.start
:crypto.start
:observer.start

defmodule Day14Test do
  use ExUnit.Case, async: true
  @moduletag timeout: 12000000
  import Day14
  @doc """
  For example, if the pre-arranged salt is abc:

  The first index which produces a triple is 18, because the MD5 hash of abc18 contains ...cc38887a5.... However, index 18 does not count as a key for your one-time pad, because none of the next thousand hashes (index 19 through index 1018) contain 88888.
  The next index which produces a triple is 39; the hash of abc39 contains eee. It is also the first key: one of the next thousand hashes (the one at index 816) contains eeeee.
  None of the next six triples are keys, but the one after that, at index 92, is: it contains 999 and index 200 contains 99999.
  Eventually, index 22728 meets all of the criteria to generate the 64th key.

  So, using our example salt of abc, index 22728 produces the 64th key.

  Given the actual salt in your puzzle input, what index produces your 64th one-time pad key?

  Your puzzle input is qzyelonm.
  """

  @salt "abc"

  test "triple" do
    assert "a" == triple("baaac")
    assert "a" == triple("baaaa")
    assert "8" == triple(18, @salt)
    assert "e" == triple(39, @salt)
    assert "9" == triple(92, @salt)
    assert triple(22728, @salt) != nil
  end

  test "quintuple" do
    assert "e" == quintuple(md5(816, @salt))
    assert "9" == quintuple(md5(200, @salt))
  end

  @tag :skip
  test "key" do
    assert false == key(18, @salt)
    assert false == key(19, @salt)
    assert true == key(39, @salt)
    assert true == key(92, @salt)
    assert true == key(22728, @salt)
  end

  @tag :skip
  test "key 2" do
    :ets.new(:stretch, [:named_table])
    assert false == key2(5, @salt)
    assert true == key2(10, @salt)
    assert true == key2(22551, @salt)
  end

  @tag :skip
  test "64th key" do
    assert 22728 == solve(@salt)
  end

  test "64th key 2" do
    :ets.new(:stretch, [:named_table])
    assert 22122 == solve("qzyelonm", &key2/2)
  end

  @tag :skip
  test "64th key 2 test" do
    :ets.new(:stretch, [:named_table])
    assert 22551 == solve("qzyelonm", &key2/2)
  end

  @tag :skip
  test "md5 stretch" do
    :ets.new(:stretch, [:named_table])
    assert "a107ff634856bb300138cac6568c0f24" == md5_stretch(md5("abc0"))
    assert "a107ff634856bb300138cac6568c0f24" == md5_stretch(md5("abc0"))
  end

  @tag :skip
  test "64th key actual" do
    assert 15168 == solve("qzyelonm")
  end
end
