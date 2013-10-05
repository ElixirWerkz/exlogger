defmodule ExLogger.Format do
  @spec expand_message(ExLogger.message) :: [String.t|ExLogger.object_key]
  defp expand_message(message) do
    expand_message(message, [], nil)
  end
  defp expand_message(<< "${", rest :: binary >>, acc, nil) do
    expand_message(rest, acc, "")
  end
  defp expand_message(<< a :: [1, binary], rest :: binary >>, [], nil) do
    expand_message(rest, [a], nil)
  end
  defp expand_message(<< a :: [1, binary], rest :: binary >>, [string|tail], nil) when is_binary(string) do
    expand_message(rest, [string <> a|tail], nil)
  end
  defp expand_message(<< a :: [1, binary], rest :: binary >>, acc, nil) do
    expand_message(rest, [a|acc], nil)
  end
  defp expand_message(<< "}", rest :: binary >>, acc, name_acc) do
    expand_message(rest, [convert_name(name_acc)|acc], nil)
  end
  defp expand_message(<< a :: [1, binary], rest :: binary >>, acc, name_acc) do
    expand_message(rest, acc, name_acc <> a)
  end
  defp expand_message("", acc, _) do
    Enum.reverse(acc)
  end

  def format(nil, object) do
    inspect(object)
  end
  def format(message, object) do
    lc component inlist expand_message(message) do
      cond do
        is_atom(component) ->
          ExLogger.Inspect.to_string(object[component])
        is_list(component) ->
          Enum.reduce(component, object, fn(path, object) ->
            object[path]
          end) |>
          ExLogger.Inspect.to_string
        true ->
          component
      end
    end
  end

  defp convert_name(name_acc) do
    case String.split(name_acc,".") do
      [name] -> binary_to_atom(name)
      names -> (lc name inlist names, do: binary_to_atom(name))
    end
  end
end