defmodule Untangle do
    def untangle(prereqs, nexts) do
        available_steps = Enum.filter(prereqs, fn {_, arr} -> arr == [] end)
            |> Enum.sort_by(fn {k, _} -> k end)

        case available_steps do
            [] -> []
            _ ->
                {step, _} = hd(available_steps)
                prereqs = Map.get(nexts, step, [])
                    |> Enum.reduce(prereqs, fn next_step, prereqs ->
                        Map.update!(prereqs, next_step, fn steps -> List.delete(steps, step) end)
                    end)
                [step] ++ untangle(Map.delete(prereqs, step), nexts)
        end
    end
end

raw_input = File.read!("7.input")
matcher = ~r/Step (.) must be finished before step (.) can begin\./

input = Regex.scan(matcher, raw_input)
    |> Enum.map(fn [_, prereq, step] -> {step, prereq} end)

all_steps = Enum.unzip(input)
    |> (fn {first, last} -> first ++ last end).()
    |> Enum.map(fn i -> {i, []} end)
    |> Map.new

nexts = Enum.reduce(input, %{}, fn {step, prereq}, next_map ->
    Map.update(next_map, prereq, [step], fn nexts -> [step] ++ nexts end)
end)

prereqs = Enum.reduce(input, all_steps, fn {step, prereq}, dep_map ->
    Map.update!(dep_map, step, fn prereqs -> [prereq] ++ prereqs end)
end)

IO.puts(Untangle.untangle(prereqs, nexts))