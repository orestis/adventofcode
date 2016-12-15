defmodule StateTest do
  use ExUnit.Case

  doctest State
  doctest State.Floor

  test "get_next_state" do
    floors = [[{:chip, :h}, {:chip, :l}], [{:gen, :h}], [{:gen, :l}], []]
    {floors, full_floor, validator, pass_generator} = State.create_floors(floors)
    get_next = fn(state) -> State.get_next_state(state, pass_generator, validator) end

    end_check = fn({3, floors}) -> Enum.at(floors, 3) == full_floor
                   (_) -> false end

    assert 11 == BFS.walk_bfs({0, floors}, get_next, end_check)

  end

end
