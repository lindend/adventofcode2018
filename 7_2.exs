defmodule Untangle do
    def untangle(%{}, _, workers) do
        workers
            |> Enum.map(fn {_, time} -> time end)
            |> Enum.max
    end

    def untangle(prereqs, nexts, workers) do
        {step, wait_time, prereqs, workers} = next_available(prereqs, workers, nexts)
        IO.puts("Step #{step}")
        time = step_time(step)
        wait_time + untangle(Map.delete(prereqs, step), nexts, Enum.sort_by([{step, time}] ++ workers, fn {_, t} -> t end))
    end

    def conc_untangle(prereqs, _, workers, time) when prereqs == %{} do
        workers
            |> Enum.map(fn {_, time} -> time - 1 end)
            |> Enum.max
            |> Kernel.+(time)
    end

    def conc_untangle(_, _, _, 50000) do
        0
    end

    def conc_untangle(prereqs, nexts, workers, total_time) do
        workers = Enum.map(workers, fn {task, time} -> {task, max(0, time - 1)} end)
        done_tasks = Enum.filter(workers, fn {task, time} -> task != nil && time == 0 end)
        workers = Enum.map(workers, fn {task, time} -> 
            case time do
                0 -> {nil, 0}
                _ -> {task, time}
            end
        end)
        prereqs = Enum.reduce(done_tasks, prereqs, fn {worker_task, _}, _ ->
            Map.get(nexts, worker_task, [])
                |> Enum.reduce(prereqs, fn next_step, prereqs ->
                    Map.update!(prereqs, next_step, fn steps -> List.delete(steps, worker_task) end)
                end)
        end)

        free_workers = Enum.filter(workers, fn {_, time} -> time <= 0 end)
        available_tasks = next_prereq(prereqs)
        {prereqs, workers} = Enum.zip(free_workers, available_tasks)
            |> Enum.reduce({prereqs, workers}, fn {worker, task}, {prereqs, workers} ->
                {Map.delete(prereqs, task), [{task, step_time(task)}] ++ List.delete(workers, worker)}
        end)
        conc_untangle(prereqs, nexts, workers, total_time + 1)
    end

    def step_time(step) do
        hd(to_charlist(step)) - 4
    end

    def next_available(prereqs, workers, nexts) do
        {total_time, prereqs, task} = Enum.reduce_while(workers, {0, prereqs, nil}, 
        fn {worker_task, worker_time}, {total_time, prereqs, _} ->
            case next_prereq(prereqs) do
                [] ->
                    prereqs = Map.get(nexts, worker_task, [])
                        |> Enum.reduce(prereqs, fn next_step, prereqs ->
                            Map.update!(prereqs, next_step, fn steps -> List.delete(steps, worker_task) end)
                        end)
                    {:cont, {worker_time + total_time, prereqs, nil}}
                [{task, _} | _] -> {:halt, {worker_time + total_time, prereqs, task}}
            end
        end)
        {task, total_time, prereqs, Enum.map(workers, fn {task, time} -> {task, max(0,time - total_time)} end)}
    end

    def next_prereq(prereqs) do
        Enum.filter(prereqs, fn {_, arr} -> arr == [] end)
            |> Enum.sort_by(fn {k, _} -> k end)
            |> Enum.map(fn {task, _} -> task end)
            
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

workers = [{nil, 0}, {nil, 0}, {nil, 0}, {nil, 0}, {nil, 0}]

IO.puts(Untangle.conc_untangle(prereqs, nexts, workers, 0))