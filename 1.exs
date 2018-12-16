input = File.stream!("1.input")
|> Stream.map(&String.trim_trailing/1) 
|> Enum.to_list |> Enum.map(fn s -> String.to_integer(s, 10) end)
IO.puts("Sum: #{Enum.sum(input)}")


{_, freq} = Enum.reduce_while(Stream.cycle(input), {%{}, 0}, fn change, {seen, freq} ->
    freq = freq + change
    cond do
        Map.has_key?(seen, freq) -> 
            IO.puts("Seen this before!")
            {:halt, {seen, freq}}
        true -> {:cont, {Map.put(seen, freq, true), freq}}
    end
end)

IO.puts("Twice: #{freq}")