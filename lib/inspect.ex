defprotocol ExLogger.Inspect do
  @only [BitString, Record, Any]

  def to_string(thing)

end