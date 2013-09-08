defimpl ExLogger.Inspect, for: Any do

  import Kernel, except: [to_string: 1]

  def to_string(thing) do
    inspect(thing)
  end

end