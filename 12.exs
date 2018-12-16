defmodule Plants do
    def grow(plants = [p0, p1 | _], patterns) do
        [p0, p1] ++ generation(plants, patterns)
    end
    def generation([l0 , l1, {old_plant, pot}, r0, r1 | rest], patterns) do
        {lp0, _} = l0
        {lp1, _} = l1
        {rp0, _} = r0
        {rp1, _} = r1
        plant = Enum.reduce_while(patterns, nil, fn {[p0, p1, p2, p3, p4], plant}, _ ->
            case {lp0, lp1, old_plant, rp0, rp1} do
                {^p0, ^p1, ^p2, ^p3, ^p4} -> {:halt, plant}
                _ -> {:cont, "."}
            end
        end)
        [{plant, pot}] ++ generation([l1, {old_plant, pot}, r0, r1] ++ rest, patterns)
    end

    def generation([_, _], _) do
        []
    end

    def generation(l, _) do
        l
    end
    def score(plants) do
        Enum.filter(plants, fn {plant, _} -> plant == "#" end)
        |> Enum.map(fn {_,score} -> score end)
        |> Enum.sum
    end
end

input = File.stream!("input/12.input")
|> Stream.map(&String.trim_trailing/1) 
|> Enum.to_list

num_rounds = 500
padding = num_rounds + 5

initial_state = hd(input) |> String.slice(15..-1) |> String.graphemes() |> Enum.with_index
state_header = List.duplicate(".", padding) |> Enum.with_index(-padding)
state_footer = List.duplicate(".", padding) |> Enum.with_index(length(initial_state))
initial_state = state_header ++ initial_state ++ state_footer

patterns = Enum.drop(input, 2)
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(fn p -> {Enum.take(p, 5), List.last(p)} end)

{_, scores} = Enum.reduce(1..num_rounds, {initial_state, [0]}, fn round, {state, scores} ->
    next_state = Plants.grow(state, patterns)
    score = Plants.score(next_state)
    delta_score = score - (hd scores)
    IO.puts("Generation: #{round}, score: #{score}, delta score: #{delta_score}")
    {next_state, [score] ++ scores}
end)

IO.puts("Score: #{hd scores}")
last_score = hd scores
delta_score = last_score - (hd(tl(scores)))
generations_left = 50000000000 - num_rounds
final_score = generations_left * delta_score + last_score
IO.puts("Final score: #{final_score}")