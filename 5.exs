defmodule Polymers do
    def collapses?(l0, l1) do
        cond do
            l0 == l1 -> false
            l0 == nil || l1 == nil -> false
            String.downcase(l0) == String.downcase(l1) -> true
            true -> false
        end
    end

    def collapse(p) do
        graphemes = String.graphemes(p)
        Enum.reduce(graphemes, [], fn l, chain ->
            case chain do
                [] -> [l]
                _ ->
                    case collapses?(l, hd(chain)) do
                    true -> tl(chain)
                    false -> [l] ++ chain
                end
            end
        end)
    end
end

input = File.read!("5.input")
unitTypes = String.downcase(input) |> String.graphemes |> MapSet.new

Enum.map(unitTypes, fn t -> String.replace(input, ~r/#{t}/i, "") end)
    |> Enum.map(&Polymers.collapse/1)
    |> Enum.map(&length/1)
    |> Enum.min
    |> IO.puts
# IO.puts(length(Polymers.collapse(input)))