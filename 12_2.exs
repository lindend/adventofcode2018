defmodule Plants do
    def generation(plants, patterns) do
        Enum.reduce(Map.keys(plants), [], fn pot, new_plants ->
            Enum.map(patterns, fn pattern -> matches_pattern(pot, pattern, plants) end)
            |> List.flatten
            |> Kernel.++(new_plants)
        end) |> Map.new(fn p -> {p, true} end)
    end
    def matches_pattern(pot, pattern, plants) do
        Enum.reduce(-2..2, [], fn position, new_plants ->
            cond do
                Enum.all?(pattern, fn p -> test_pattern_position(p, pot + position, plants) end) -> [pot + position] ++ new_plants
                true -> new_plants
            end
        end)
    end
    def test_pattern_position({pattern, pattern_pos}, pot_position, plants) do
        case pattern do
            "#" -> Map.has_key?(plants, pot_position + pattern_pos)
            "." -> !Map.has_key?(plants, pot_position + pattern_pos)
        end
    end
    def score(plants) do
        Map.keys(plants)
            |> Enum.sum
    end
end

input = File.stream!("input/12.input")
    |> Stream.map(&String.trim_trailing/1) 
    |> Enum.to_list

num_rounds = 10000

initial_state = hd(input) |> String.slice(15..-1) 
    |> String.graphemes()
    |> Enum.filter(fn p -> p == "#" end)
    |> Enum.with_index
    |> Map.new(fn {_, pot} -> {pot, true} end)

patterns = Enum.drop(input, 2)
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(fn p -> {Enum.take(p, 5), List.last(p)} end)
    |> Enum.filter(fn {_, result} -> result == "#" end)
    |> Enum.map(fn {p, _} -> p end)
    |> Enum.map(&Enum.with_index/1)
    # |> Enum.map(fn {pattern, _} -> pattern
    #     |> Enum.with_index
    #     |> Enum.filter(fn {p, _} -> p == "#" end)
    #     |> Enum.map(fn {_, i} -> i end)
    # end)
    import ExProf.Macro

    profile do
grown = Enum.reduce(1..num_rounds, initial_state, fn _, state ->
    Plants.generation(state, patterns)
end)
IO.puts("Score: #{Plants.score(grown)}")

end
