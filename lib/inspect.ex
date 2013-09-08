defprotocol ExLogger.Inspect do
  @only [BitString, Record, Tuple, Any]

  def to_string(thing)

end