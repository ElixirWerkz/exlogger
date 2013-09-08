defimpl ExLogger.Inspect, for: ExLogger.MFA do
 
  alias ExLogger.MFA
  import Kernel, except: [to_string: 1]
  
  def to_string(MFA[module: m, function: f, arguments: a, properties: properties]) when is_list(a) do
    "#{inspect m}.#{f}" <>
    (Inspect.Algebra.surround_many("(", a, ")", :infinity, inspect(&1)) |> Inspect.Algebra.pretty(:infinity)) <>
    format_properties(properties)
  end

  def to_string(MFA[module: m, function: f, arguments: a, properties: properties]) when is_integer(a) do
    "#{inspect m}.#{f}/#{a}" <> format_properties(properties)
  end

  defp format_properties(nil), do: ""
  defp format_properties(props) do
    " (#{props[:file]}:#{props[:line]})"
  end

end