defmodule Day5 do
  @input "ojvtpuvg"
  defmodule Crypto do
    @prefix "00000"
    #@prefix :binary.compile_pattern("00000")
    def hash(input, n) do
      :crypto.hash(:md5 , input <> Integer.to_string(n)) |> Base.encode16(case: :lower)
    end

    def interesting(@prefix <> rest), do: rest
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
    |> Enum.reduce_while(%{}, fn({i, c}, acc) ->
      #IO.puts "i #{i} c #{c}"
      GenServer.cast(Day5.Cinematic, {i, c})
      acc = Map.put_new(acc, i, c)
      if length(Map.keys(acc)) == 8 do
        {:halt, acc}
      else
        {:cont, acc}
      end
    end)
    |> Map.to_list
    |> Enum.sort
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
    GenServer.start_link(Day5.Cinematic, [], name: Day5.Cinematic)
    _result = crack_indexed(@input)
    GenServer.cast(Day5.Cinematic, :stop)
  end

  def test_print do
    Process.sleep(10000)
  end

  defmodule Cinematic do
    use GenServer

    def init(_) do
      Process.send_after(self(), :tick, 0)
      {:ok, %{}}
    end

    def handle_cast(:stop, _s) do
      IO.write IO.ANSI.reset()
      {:stop, :normal, :ok}
    end
    def handle_cast({i, c}, s) do
      {:noreply, Map.put_new(s, i, c)}
    end

    def handle_info(:tick, s) do
      print(s)
      Process.send_after(self(), :tick, 50)
      {:noreply, s}
    end


    def print(s) do
      r = 32..126
      l = for i <- 1..8, do: Map.get(s, i, nil)
      l = Enum.map(l, fn
        (nil) -> [IO.ANSI.normal(), IO.ANSI.faint(), Enum.random(r)]
        (c) -> [IO.ANSI.normal(), IO.ANSI.bright(), IO.ANSI.primary_font(), c]
      end)

      IO.write  <<27, "[", "?25l">> #  CSI ?25l
      IO.write IO.ANSI.clear_line()
      IO.write [IO.ANSI.reverse(),  l]
      IO.write '\r'
    end

  end

end
