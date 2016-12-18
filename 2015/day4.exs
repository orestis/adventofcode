defmodule Day4 do

  def solve(key, check) do
    match(0, key, check)
  end

  def match(n, key, check) do
    h = key <> Integer.to_string(n)
    hash = :crypto.hash(:md5, h) |> Base.encode16
    if String.starts_with?(hash, check) do
      n
    else
      match(n+1, key, check)
    end
  end

  def test_solve do
    609043 = solve "abcdef","00000"
    1048970 = solve "pqrstuv","00000"
  end
end

Day4.test_solve
sol1 = Day4.solve "ckczppom","00000"
IO.puts sol1
sol2 = Day4.solve "ckczppom","000000"
IO.puts sol2