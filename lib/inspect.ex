defprotocol ExLogger.Inspect do
  @fallback_to_any true

  def to_string(thing)

end