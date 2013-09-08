defimpl ExLogger.Inspect, for: ExLogger.ErrorLoggerHandler.CrashReport do
 
  alias ExLogger.ErrorLoggerHandler.CrashReport
  import Kernel, except: [to_string: 1]

  def to_string(CrashReport[] = crash) do
    name =
    case (crash.registered_name || []) do
      [] ->
        ## process_info(Pid, registered_name) returns [] for unregistered processes
        crash.pid
      atom  ->
        atom
    end
    {class, reason, _trace} = crash.error_info
    reason = ExLogger.inspect(ExLogger.ErrorLoggerHandler.Reason[reason: reason])
    type = case class do
      :exit -> "exited"
      _ -> "crashed"
    end
    "Process #{inspect name} with #{length(crash.neighbours)} #{type} with reason #{reason}"
  end

end