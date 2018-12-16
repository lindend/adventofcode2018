defmodule Marble do
    def put([], marble, _) do
        {[marble], 0, 0}
    end

    def put(circle, marble, current) when rem(marble, 23) == 0 do
        new_current = rem(current - 7 + length(circle), length(circle))
        {score, new_circle} = List.pop_at(circle, new_current)
        {new_circle, new_current, score + marble}
    end

    def put(circle, marble, current) do
        new_current = rem(current + 1, length(circle)) + 1
        new_circle = List.insert_at(circle, new_current, marble)
        {new_circle, new_current, 0}
    end
end

players = 465
marbles = 71498
    
high_score =
Enum.reduce(0..marbles, {[], 0, %{}}, fn marble, {circle, current, scores} ->
    {circle, current, score} = Marble.put(circle, marble, current)
    player = rem(marble, players)
    scores = Map.update(scores, player, score, fn s -> s + score end)
    {circle, current, scores}
end)
|> elem(2)
|> Map.values
|> Enum.max

IO.puts("Highest score: #{inspect(high_score)}")