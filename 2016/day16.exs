defmodule Day16 do
  use Bitwise
  @input "01111010110010011"

  def c(input) do
    {out, _} = Integer.parse(input, 2)
    {out, byte_size(input)}
  end

  def pretty({a, l}) do
    IO.inspect {String.pad_leading(Integer.to_string(a, 2), l, "0"), l}
    {a, l}
  end


  def swap_bits(x, i, j) do
    lo = ((x >>> i) &&& 1)
    hi = ((x >>> j) &&& 1)
     if lo ^^^ hi == 1 do
      x ^^^ ((1 <<< i) ||| (1 <<< j))
    else
      x
    end
  end

  def reverse({x, n}) do
    #uint n = sizeof(x) * 8;
    r = 0..round(Float.floor(n/2))
    x = Enum.reduce(r, x, fn(i, x) ->
      swap_bits(x, i, (n-i-1))
      end)
    {x, n}
  end

  def dragon({a, l}) do
    b = ~~~a &&& ((1 <<< l) - 1)
    {b, _} = reverse({b, l})
    moved = a <<< (l+1)
    {moved + b, l + l + 1}
  end

  def checksum({a, l}) do
    {check, l2} =
      pairs({a, l})
      |> Enum.map(fn
        (0) -> "1"
        (3) -> "1"
        (1) -> "0"
        (2) -> "0"
        end)
      |> Enum.join()
      |> c()

    if rem(l2, 2) == 0 do
      checksum({check, l2})
    else
      {check, l2}
    end
  end

  def pairs({a, l}) when rem(l, 2) == 0 do
    mask = 0b11
    n = round(l / 2) - 1
    Enum.map(0..n, fn(i) ->
      m = mask <<< (i * 2)
      (a &&& m) >>> (i * 2)
      end)
    |> Enum.reverse()
  end

  def trunc({x, l}, size) when size >= l, do: {x, l}
  def trunc({x, l}, size) do
    s = l - size
    {x >>> s, l - s}
  end


  def solve({initial, l}, disk_size) when disk_size > l do
    IO.puts "enlarging input #{l}/#{disk_size}"
    solve(dragon({initial, l}), disk_size)
  end
  def solve(input, disk_size) do
    IO.puts "calculating checksum"
    t = trunc(input, disk_size)
    checksum(t)
  end
end

ExUnit.start

defmodule Day16Test do
  use ExUnit.Case

  import Day16

  test "truncate" do
    assert trunc(c("11000"), 3) == c("110")
  end

  test "pairs" do
    assert pairs(c("110010110100")) == [0b11, 0b00, 0b10, 0b11, 0b01, 0b00]
  end

  test "reverse" do
    assert swap_bits(0b1000, 0, 3) == 0b0001
    assert swap_bits(0b1001, 0, 3) == 0b1001
    assert reverse(c("100")) == c("001")
    assert reverse(c("001")) == c("100")
    assert reverse(c("010")) == c("010")
    assert reverse(c("110")) == c("011")
    assert reverse(c("011")) == c("110")

    assert reverse(c("1000")) == c("0001")
    assert reverse(c("1110")) == c("0111")
  end

  test "dragon" do
    assert dragon(c("1")) == c("100")
    assert dragon(c("0")) == c("001")
    assert dragon(c("11111")) == c("11111000000")
    assert dragon(c("111100001010")) == c("1111000010100101011110000")
  end

  test "checksum" do
    assert checksum(c("110010110100")) == c("100")
  end

  test "sample input" do
    assert solve(c("10000"), 20) == c("01100")
  end

  @tag :skip
  test "puzzle input" do
    sol = solve(c("01111010110010011"), 272)
    IO.puts "SOLLLLLLLLLLLLUTION"
    pretty(sol)
    assert sol == nil
  end

  @tag timeout: 1200000000
  test "part 2" do
    sol = solve(c("01111010110010011"), 35651584)
    IO.puts "SOLLLLLLLLLLLLUTION"
    pretty(sol)
    assert sol == nil
  end
end
