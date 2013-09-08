defimpl ExLogger.Inspect, for: BitString do

  import Kernel, except: [to_string: 1]

  def to_string(thing) do
    thing
  end

end