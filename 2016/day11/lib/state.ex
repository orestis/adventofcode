defmodule State do
  use Bitwise

  defmodule Floor do
    def valid?(floor, gen_shift, full_floor) do
      gens = floor >>> gen_shift
      chip_mask = full_floor >>> gen_shift
      chips = floor &&& chip_mask
      protected = chips &&& gens
      unprotected = chips - protected

      #IO.puts "floor #{floor} full_floor #{full_floor} chipmask #{chip_mask} gens: #{gens} chips: #{chips} proteced #{protected} unprotected #{unprotected}"

      gens == 0 or unprotected == 0
    end

    @doc ~S"""
    iex> State.Floor.passengers(1+2+8, [1, 2, 4, 8, 1+2, 1+4, 2+8, 4+8])
    [1, 2, 8, 1+2, 2+8]
    """
    def passengers(floor, possible_pairs) do
      for p <- possible_pairs, (p &&& floor) == p, do: p
    end
  end

  def hash({elev, floors}, chip_list, gen_list) do
    # current repr
    # {0, [1+2, 4, 8, 0]}
    # equivalent to repr
    # {0, [2+1, 8, 4, 0]
    # another:
    # {1, [0, 1+4, 2+8, 0]
    # equivalent to
    # {1, [0, 2+8, 1+4, 0]
    # bigger:
    # {2, [1+8, 2+4, 16+32, 0]
    # equiv =>
    # {2, [2+16, 1+4, 8+32, 0]
    # {2, [4+32, 1+2, 8+1632, 0]

    #leave it for now
  end

  defstruct elevator: 0, floors: [0, 0, 0, 0]

  @doc ~S"""
    iex> floors = [[{:chip, :h}, {:chip, :l}], [{:gen, :h}], [{:gen, :l}], []]
    iex> {floors, full_floor, validator, pass_generator} = State.create_floors(floors)
    iex> floors
    [1+2, 4, 8, 0]
    iex> full_floor
    1+2+4+8
    iex> validator.(1+2)
    true
    iex> validator.(1+4)
    true
    iex> validator.(1+8)
    false
    iex> validator.(2+8)
    true
    iex> validator.(4+8)
    true
    iex> pass_generator.(1+2+8)
    [1+2, 2+8, 1, 2, 8]
  """
  def create_floors(floors) do
    all_elements =
      List.flatten(floors)
      |> Enum.map(fn({_type, el}) -> el end)
      |> Enum.uniq()

    gen_shift = length(all_elements)

    el_to_number =
      Enum.with_index(all_elements)
      |> Enum.map(fn({el, idx}) -> {el, 1 <<< idx} end)
      |> Map.new()

    chips_list = Map.values(el_to_number)
    gens_list = Enum.map(chips_list, &(&1 <<< gen_shift))

    full_floor = Enum.sum(chips_list) + Enum.sum(gens_list)


    floors =
      Enum.map(floors, fn(floor) ->
        Enum.map(floor, fn
          ({:chip, el}) -> el_to_number[el]
          ({:gen, el}) -> el_to_number[el] <<< gen_shift
        end)
        |> Enum.sum()
      end)

    validator = fn(floor) ->
      Floor.valid?(floor, gen_shift, full_floor)
    end

    possible_pairs = pairs(chips_list ++ gens_list) |> Enum.map(&Enum.sum/1) |> Enum.filter(validator)

    pass_generator = fn(floor) ->
      Floor.passengers(floor, possible_pairs ++ chips_list ++ gens_list)
    end

    {floors, full_floor, validator, pass_generator}
  end

  def get_next_state({elev, floors}, pass_generator, validator) do
    curr_floor = Enum.at(floors, elev)
    next_positions = cond do
      elev == 0 -> [1]
      elev == 3 -> [2]
      :else -> [elev+1, elev-1]
    end

    new_floors =
      for pass <- pass_generator.(curr_floor),
        p <- next_positions,
        floor = Enum.at(floors, p) + pass,
        new_curr = curr_floor - pass,
        validator.(floor) and validator.(new_curr) do
                                {p, floor, new_curr}
      end

    Enum.map(new_floors, fn({p, floor, new_curr}) ->
      new_floors =
        List.replace_at(floors, elev, new_curr)
        |> List.replace_at(p, floor)
      {p, new_floors}
    end)
  end

  def pairs([]), do: []
  def pairs([_]), do: []
  def pairs([h|t]) do
    p = for e <- t, do: [h, e]
    p ++ pairs(t)
  end

end
