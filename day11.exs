defmodule Day11 do
  

  def next(s) do
    Enum.reverse(increase(Enum.reverse(s)))
  end

  def next_valid(s, {true, true, true}) do
    s
  end

  def next_valid(s, _) do
    n = next(s)
    next_valid(n, valid(n))
  end

  def next_valid(s) do
    n = next(s)
    next_valid(n, valid(n))
  end

  def increase(charlist) do
    #IO.puts("---")
    [h|t] = charlist
    #IO.puts(charlist)
    #IO.inspect(h)
    if h == ?z do
      #IO.puts('Z')
      [?a|increase(t)]
    else
      #IO.puts('NOZ')
      [h+1|t]
    end
  end

  def valid(s) do
    {valid1(s), valid2(s), valid3(s)}
  end

  def valid1(s) do
    Enum.chunk(s, 3, 1)
    #|> IO.inspect
    |> Enum.any?(&continuous/1)
  end

  def continuous(chunk) do
    _continuous(chunk)
  end

  def _continuous([c|rest]) do
    _continuous(c, rest)
  end
  def _continuous(_, []) do
    true
  end
  def _continuous(c, rest) do
    #IO.puts("---")
    #IO.inspect([c, rest])
    [n|rest] = rest
    #IO.inspect([n, rest])
    if n - c == 1 do
      _continuous(n, rest)
    else
      false
    end 
  end

  def valid2(s) do
    not String.contains?(to_string(s), ["i", "o", "l"])
  end

  def valid3(s) do
    r = ~r/.*(\w)\1.*(\w)\2.*/
    Regex.match?(r, to_string(s))
  end

  def test do
    'abd' = next('abc') 
    'aca' = next('abz') 
    {true, false, false} = valid('hijklmmn')
    {false, true, true} = valid('abbceffg')
    {false, true, false}  = valid('abbcegjk')
    'abcdffaa' = next_valid('abcdefgh')
    'ghjaabcc' = next_valid('ghijklmn')
  end
end

#Day11.test
Day11.next_valid('vzbxkghb')
|> Day11.next_valid
|> IO.puts