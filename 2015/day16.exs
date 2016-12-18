defmodule Day16 do
  @ticker [
    children: 3,
    cats: 7,
    samoyeds: 2,
    pomeranians: 3,
    akitas: 0,
    vizslas: 0,
    goldfish: 5,
    trees: 3,
    cars: 2,
    perfumes: 1
  ]

  @greater [:cats, :trees]
  @fewer [:pomeranians, :goldfish]

  def parse_line(line) do
    r = ~r/Sue (\d+): (.+)/
    [n, attrs] = Regex.run(r, line, capture: :all_but_first)
    {kw, _} = Code.eval_string("["<>attrs<>"]")
    {n, kw}
  end

  def compare({_, kw}) do
    present = Keyword.take(@ticker, Keyword.keys(kw))
    Keyword.equal?(present, kw)
  end

  def compare2({_, kw}) do
    present = Keyword.take(@ticker, Keyword.keys(kw))
    greater = Keyword.take(present, @greater) |> Keyword.keys
    fewer = Keyword.take(present, @fewer) |> Keyword.keys
    equal1 = Keyword.drop(present, @greater ++ @fewer)
    equal2 = Keyword.drop(kw, @greater ++ @fewer)

    values = fn (kwl, keys) -> Keyword.take(kwl, keys) |> Keyword.values end

    g_pairs = Enum.zip(values.(kw, greater), values.(@ticker, greater))
    f_pairs = Enum.zip(values.(kw, fewer), values.(@ticker, fewer))

    g = Enum.all?(g_pairs, fn ({x, g}) -> x > g end)
    f = Enum.all?(f_pairs, fn ({x, l}) -> x < l end)

    Keyword.equal?(equal1, equal2) and g and f

  end

  def input do
    File.stream!("day16.input.txt")
    |> Stream.map(&parse_line/1) 
  end

  def solve do
    input
    |> Stream.filter(&compare2/1)
    |> Enum.to_list()
    |> IO.inspect
  end

end

Day16.solve