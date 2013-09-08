defimpl ExLogger.Inspect, for: ExLogger.ErrorLoggerHandler.Format do
 
  alias ExLogger.ErrorLoggerHandler.Format
  import Kernel, except: [to_string: 1]
  
  def to_string(Format[format: f, args: args]) do
    Kernel.to_string(:io_lib.format(f, args))
  end

end