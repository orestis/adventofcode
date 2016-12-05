defmodule Day5Test do
  use ExUnit.Case, async: true
  doctest Day5
  doctest Day5.Crypto

  import Day5

  @tag skip: "too long"
  test "crack_indexed" do
    assert crack_indexed("abc") == "05ace8e3"
  end

  @tag timeout: 120000
  test "part2" do
    assert crack_indexed("ojvtpuvg") == "1050cbbd"
  end

  @tag skip: "too long"
  test "search" do
    assert crack("abc") == "18f47a30"
  end

end
