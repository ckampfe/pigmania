defmodule PigMania.Points do
  defmacro build_points_table(points_map) do
    quote do
      Enum.reduce(unquote(points_map), %{}, fn {pig1, points1}, acc1 ->
        Enum.reduce(unquote(points_map), acc1, fn {pig2, points2}, acc2 ->
          combined_points =
            cond do
              pig1 == "sider" && pig2 == "sider" ->
                1

              pig1 == pig2 ->
                (points1 + points2) * 2

              true ->
                if points1 >= points2 do
                  points1
                else
                  points2
                end
            end

          Map.put(acc2, {pig1, pig2}, combined_points)
        end)
        |> Map.merge(acc1)
      end)
    end
  end
end
