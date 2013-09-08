defimpl ExLogger.Inspect, for: Tuple do

  import Kernel, except: [to_string: 1]

  def to_string(thing) when is_atom(elem(thing, 0)) and tuple_size(thing) > 1 do
    module = elem(thing, 0)
    if Code.ensure_loaded?(module) and
       function_exported?(module, :__record__, 1) and
       module.__record__(:fields)[:__exception__] == :__exception__ do
      module.message(thing)
    else
      inspect(thing)
    end
  end
  def to_string(thing) do
    inspect(thing)
  end

end