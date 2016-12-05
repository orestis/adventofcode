defmodule Day5 do
  @input "ojvtpuvg"
  defmodule Crypto do
    def hash(input, n) do
      :crypto.hash(:md5 , input <> Integer.to_string(n)) |> Base.encode16(case: :lower)
    end

    def interesting("00000" <> rest), do: rest
    def interesting(_), do: false

    @doc """
    iex> import Day5.Crypto
    iex> get_passwd("00000abc", 1)
    {true, "a", 1}
    iex> get_passwd("0000fabc", 1)
    {false, 1}
    """
    def get_passwd(h, n) do
      case interesting(h) do
        <<c>> <> _rest -> {true, <<c>>, n}
        _ -> {false, n}
      end
    end

    @doc """
    iex> import Day5.Crypto
    iex> get_passwd_indexed("000003ac", 1)
    {true, "a", 3,  1}
    iex> get_passwd_indexed("000007ac", 1)
    {true, "a", 7, 1}
    iex> get_passwd_indexed("000008ac", 1)
    {false, 1}
    iex> get_passwd_indexed("0000fabc", 1)
    {false, 1}
    """
    def get_passwd_indexed(h, n) do
      case interesting(h) do
        <<i>> <> <<c>> <> _rest  when i >= ?0 and i < ?8 -> {true, <<c>>, String.to_integer(<<i>>), n}
        _ -> {false, n}
      end
    end
  end

  def crack(input) do
    import Day5.Crypto
    Stream.iterate(0, &(&1+1))
    |> Stream.map(fn(n) -> get_passwd(hash(input, n), n) end)
    |> Stream.filter(fn(res) -> elem(res, 0) == true end)
    |> Stream.map(fn({true, c, _}) -> c end)
    |> Stream.take(8)
    |> Enum.join
  end

  def crack_indexed(input) do
    import Day5.Crypto
    Stream.iterate(0, &(&1+1))
    |> Stream.map(fn(n) -> get_passwd_indexed(hash(input, n), n) end)
    |> Stream.filter(fn(res) -> elem(res, 0) == true end)
    |> Stream.map(fn({true, c, i, _n}) -> {i, c} end)
    |> extract_indexed()
  end

  def extract_indexed(enumerable) do
    enumerable
    |> Stream.transform(%{}, fn({i, c}, acc) ->
        {v, acc} = Map.get_and_update(acc, i, fn
        (nil) -> {c, c}
        (v) -> {v, v}
      end)
      IO.puts "i #{i} c #{c}"
      IO.inspect acc
      if length(Map.keys(acc)) <= 8 do
        {[{i, v}], acc}
      else
        {:halt, acc}
      end
    end)
    |> Stream.uniq
    |> Stream.take(8)
    |> Enum.sort
    |> IO.inspect
    |> Enum.map(fn({_i, c}) -> c end)
    |> Enum.join
  end

  def crack_indexed_flow(input) do
    import Day5.Crypto
    alias Experimental.Flow
    Stream.iterate(0, &(&1+1))
    |> Flow.from_enumerable()
    |> Flow.map(fn(n) -> get_passwd_indexed(hash(input, n), n) end)
    |> Flow.filter(fn(res) -> elem(res, 0) == true end)
    |> Flow.map(fn({true, c, i, _n}) -> {i, c} end)
    #|> Flow.partition() 
    |> extract_indexed()
  end

  def solve2 do
    crack_indexed_flow(@input)
    |> IO.puts
  end

end
