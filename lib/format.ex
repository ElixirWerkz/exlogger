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
    expand_message(rest, [binary_to_atom(name_acc)|acc], nil)
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
      if is_atom(component) do
        ExLogger.Inspect.to_string(object[component])
      else
        component
      end
    end
  end
end