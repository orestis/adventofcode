defmodule Day5 do
  def isnice?(s) do
    
    #IO.puts(s)
    chars = String.codepoints(s)
    vowel_count = Enum.count(chars, &Regex.match?(~r/.*[aeiou].*/, &1))
    #IO.puts("vowelcount #{vowel_count}")
    forbidden = String.contains?(s, ["ab", "cd", "pq", "xy"])
    #IO.puts("forbiddden? #{forbidden}")
    double = Regex.match?(~r/.*([a-z])\1.*/, s) 
    #IO.puts("double? #{double}")
    (vowel_count >= 3) and (not forbidden) and double
  end


  def isnice2?(s) do
    pair = Regex.match?(~r/.*([a-z][a-z]).*\1.*/, s) 
    trio = Regex.match?(~r/.*([a-z])[a-z]\1.*/, s)
    pair and trio
  end

  def test do
    true = isnice? "ugknbfddgicrmopn"
    true = isnice? "aaa"
    false = isnice? "jchzalrnumimnmhp"
    false = isnice? "haegwjzuvuyypxyu"
    false = isnice? "dvszwmarrgswjxmb"

    true = isnice2? "qjhvhtzxzqqjkmpb"
    true = isnice2? "xxyxx"
    false = isnice2? "uurcxstgmygtbstg"
    false = isnice2? "uurcxstgmygtbstg"
  
  end

  def solve do
    {:ok, input} = File.read "day5.input.txt"
    lines = Regex.split(~r/\R/, input)
    IO.puts "nice strings:"
    lines 
    |> Enum.count(&isnice?/1)
    |> IO.puts
    IO.puts "nice2 strings:"
    lines 
    |> Enum.count(&isnice2?/1)
    |> IO.puts
  end

end

Day5.test
Day5.solve