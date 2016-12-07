defmodule Day7 do
  @abba ~r/.*(\w)(\w)\2\1.*/
  #@aba ~r/(\w)(\w)\1/
  @aba ~r/(?=(\w)(\w)\1)/
  @hypernet ~r/(?<hypernet>\[\w+?\])/
  def tls(s) do
    hypernets = Regex.scan(@hypernet, s)
    in_hyper = Enum.any?(hypernets, fn([_, h]) ->
      Regex.match?(@abba, h)
      end)
    if in_hyper do
      false
    else
      splits = Regex.split(@hypernet, s, on: [:hypernet])
      Enum.any?(splits, fn(str) ->
        Enum.any?(Regex.scan(@abba, str), fn([_cap, a, b]) ->
          a != b
        end)
      end)
    end
  end

  def ssl(s) do
    hypernets = Regex.scan(@hypernet, s, capture: :all_but_first) |> List.flatten
    hypernet_abas = Enum.flat_map(hypernets, &Regex.scan(@aba, &1, capture: :all_but_first))
    ips = Regex.split(@hypernet, s, on: [:hypernet])
    ip_abas = Enum.flat_map(ips, &Regex.scan(@aba, &1, capture: :all_but_first))
    reverse_ip_abas = Enum.map(ip_abas, fn([a, b]) -> [b, a] end)
    IO.puts "ips #{inspect(ips)} abas #{inspect(ip_abas)} revers #{inspect(reverse_ip_abas)}"
    h_s = MapSet.new(hypernet_abas)
    i_s = MapSet.new(reverse_ip_abas)
    IO.puts "hh #{inspect(h_s)}, ii #{inspect(i_s)}"
    count =
      MapSet.intersection(h_s, i_s)
      |> MapSet.size()
    count > 0
  end

  def solve() do
    File.stream!("day7.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&tls/1)
    |> Stream.filter(&(&1))
    |> Enum.count
    |> IO.inspect
  end

  def solve2() do
    File.stream!("day7.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&ssl/1)
    |> Stream.filter(&(&1))
    |> Enum.count
    |> IO.inspect
  end
end

ExUnit.start

defmodule Day7Test do
  use ExUnit.Case, async: true
  import Day7
  @aba ~r/(?=(\w)(\w)\1)/

  test "sample" do
    assert true == tls("abba[mnop]qrst")
    assert false == tls("abba[bddb]xyyx")
    assert false == tls("abcd[bddb]xyyx")
    assert false == tls("abcd[oprs]somethingelse[bddb]xyyx")
    assert false == tls("aaaa[qwer]tyui")
    assert true == tls("ioxxoj[asdfgh]zxcvbn")
    assert false == tls("zfrvenflhmjgoesmax[pgqxadyxekpnwwnckin]kqqmdrmcgyweogyfya[wbwicwmfsbthzmrfe]wbstpswtzaitlwbcv")
  end

  test "ssl" do
    assert ssl("aba[bab]xyz") == true
    assert ssl("xyx[xyx]xyx") == false
    assert ssl("aaa[kek]eke") == true
    assert ssl("zazbz[bzb]cdb") == true
  end

  test "aba" do
    s = Regex.scan(@aba, "zazbz", capture: :all_but_first)
    assert [["z", "a"], ["z", "b"]] == s
  end
end
