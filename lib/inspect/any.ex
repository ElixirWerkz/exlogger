defimpl ExLogger.Inspect, for: Any do

  def to_string(thing) do
    inspect(thing)
  end

end