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
  end

  defstruct elevator: 0, floors: [0, 0, 0, 0]

  @doc ~S"""
    iex> floors = [[{:chip, :h}, {:chip, :l}], [{:gen, :h}], [{:gen, :l}], []]
    iex> {floors, full_floor, validator} = State.create_floors(floors)
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

    all_chips = Enum.sum(Map.values(el_to_number))
    full_floor = all_chips + (all_chips <<< gen_shift)

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

    {floors, full_floor, validator}
  end

end
