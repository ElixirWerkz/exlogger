defimpl ExLogger.Inspect, for: ExLogger.ErrorLoggerHandler.Reason do
 
  alias ExLogger.ErrorLoggerHandler.Reason
  alias ExLogger.MFA
  import Kernel, except: [to_string: 1]

  def to_string(Reason[reason: {:"function not exported", [{m, f, a}, mfa|_]}]) do
    "call to undefined function " <> ExLogger.Inspect.to_string(MFA.construct(m, f, length(a))) <>
    " from " <> ExLogger.Inspect.to_string(MFA.construct(mfa))
  end

  def to_string(Reason[reason: {:"function not exported", [{m, f, a, _props}, mfa|_]}]) do
    "call to undefined function " <> ExLogger.Inspect.to_string(MFA.construct(m, f, length(a))) <>
    " from " <> ExLogger.Inspect.to_string(MFA.construct(mfa))
  end

  def to_string(Reason[reason: {:undef, [mfa|_]}]) do
    "call to undefined function " <> ExLogger.Inspect.to_string(MFA.construct(mfa))
  end

  def to_string(Reason[reason: {:bad_return, {_mfa, {:EXIT, reason}}}]) do
    to_string(Reason[reason: reason])
  end

  def to_string(Reason[reason: {:bad_return, {mfa, val}}]) do
    "bad return value " <> inspect(val) <> " from " <> ExLogger.inspect(MFA.construct(mfa))
  end

  def to_string(Reason[reason: {:bad_return_value, val}]) do
    "bad return value " <> inspect(val)
  end

  def to_string(Reason[reason: {{:bad_return_value, val}, mfa}]) do
    "bad return value " <> inspect(val) <> " from " <> ExLogger.inspect(MFA.construct(mfa))
  end

  def to_string(Reason[reason: {{:bad_record, record}, [mfa|_]}]) do
    "bad record  " <> inspect(record) <> " in " <> ExLogger.inspect(MFA.construct(mfa))
  end

  def to_string(Reason[reason: {{:case_clause, val}, [mfa|_]}]) do
    "no case clause matching " <> inspect(val) <> " in " <> ExLogger.inspect(MFA.construct(mfa))
  end

  def to_string(Reason[reason: {:function_clause, [mfa|_]}]) do
    "no function clause matching " <> ExLogger.inspect(MFA.construct(mfa))
  end

  def to_string(Reason[reason: {:if_clause, [mfa|_]}]) do
    "no true branch found while evaluating if expression in " <> ExLogger.inspect(MFA.construct(mfa))
  end

  def to_string(Reason[reason: {{:try_clause, val}, [mfa|_]}]) do
    "no try clause matching " <> inspect val <> " in " <> ExLogger.inspect(MFA.construct(mfa))
  end

  def to_string(Reason[reason: {:badarith, [mfa|_]}]) do
    "bad arithmetic expression in " <> ExLogger.inspect(MFA.construct(mfa))
  end

  def to_string(Reason[reason: {{:badmatch, val}, [mfa|_]}]) do
    "no match of right hand side value " <> inspect val <> " in " <> ExLogger.inspect(MFA.construct(mfa))
  end

  def to_string(Reason[reason: {:emfile, _trace}]) do
    "system limit: maximum number of file descriptors exhausted, check ulimit -n"
  end

  def to_string(Reason[reason: {:system_limit, [{:erlang, :open_port, _}|_]}]) do
    "system limit: maximum number of ports exceeded"
  end

  def to_string(Reason[reason: {:system_limit, [{:erlang, :spawn, _}|_]}]) do
    "system limit: maximum number of processes exceeded"
  end

  def to_string(Reason[reason: {:system_limit, [{:erlang, :spawn_opt, _}|_]}]) do
    "system limit: maximum number of processes exceeded"
  end

  def to_string(Reason[reason: {:system_limit, [{:erlang, :list_to_atom, _}|_]}]) do
    "system limit: tried to create an atom larger than 255, or maximum atom count exceeded"
  end

  def to_string(Reason[reason: {:system_limit, [{:ets, :new, _}|_]}]) do
    "system limit: maximum number of ETS tables exceeded"
  end

  def to_string(Reason[reason: {:system_limit, [mfa|_]}]) do
    "system limit in " <> ExLogger.inspect(MFA.construct(mfa))
  end

  def to_string(Reason[reason: {:badarg, [{_, _, a} = mfa, mfa2|_]}]) when is_list(a) do
    "bad argument in call to " <> ExLogger.inspect(MFA.construct(mfa)) <> " in "  <> ExLogger.inspect(MFA.construct(mfa2))
  end

  def to_string(Reason[reason: {:badarg, [{_, _, a, _props} = mfa, mfa2|_]}]) when is_list(a) do
    "bad argument in call to " <> ExLogger.inspect(MFA.construct(mfa)) <> " in "  <> ExLogger.inspect(MFA.construct(mfa2))
  end

  def to_string(Reason[reason: {:badarg, [mfa|_]}]) do
    "bad argument in " <> ExLogger.inspect(MFA.construct(mfa))
  end

  def to_string(Reason[reason: {{:badarity, {f, a}}, [mfa|_]}]) do
    arity = :erlang.fun_info(f)[:arity]
    "function called with wrong arity of #{length(a)} instead of #{arity} in " <> ExLogger.inspect(MFA.construct(mfa))
  end

  def to_string(Reason[reason: {:noproc, mfa}]) do
    "no such process or port in call to " <> ExLogger.inspect(MFA.construct(mfa))
  end

  def to_string(Reason[reason: {{:badfun, term}, [mfa|_]}]) do
    "bad function " <> inspect(term) <> " in " <> ExLogger.inspect(MFA.construct(mfa))
  end

  def to_string(Reason[reason: {reason, [mfa|_]}]) do
    ExLogger.inspect(reason) <> " in " <> ExLogger.inspect(MFA.construct(mfa))
  end

  def to_string(Reason[reason: {:EXIT, reason}]) do
    to_string(Reason[reason: reason])
  end

  def to_string(Reason[reason: reason]) do
    inspect(reason)
  end

end