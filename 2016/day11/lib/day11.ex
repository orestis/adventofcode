defmodule Day11 do

  def solve() do
    floors = [
      [{:gen, :p}, {:gen, :s}, {:gen, :t}, {:chip, :t}, {:gen, :a}, {:gen, :b}, {:chip, :a}, {:chip, :b}],
      [{:chip, :p}, {:chip, :s}],
      [{:gen, :q}, {:gen, :r}, {:chip, :q}, {:chip, :r}],
      []
    ]
    {floors, full_floor, validator, pass_generator} = State.create_floors(floors)
    get_next = fn(state) -> State.get_next_state(state, pass_generator, validator) end

    end_check = fn({3, floors}) -> Enum.at(floors, 3) == full_floor
      (_) -> false end

    steps = BFS.walk_bfs({0, floors}, get_next, end_check)
    IO.puts "solved in #{steps}"
  end

end

