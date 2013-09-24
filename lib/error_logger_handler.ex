defmodule ExLogger.ErrorLoggerHandler do
  use GenEvent.Behaviour
  use ExLogger

  defrecord CrashReport, registered_name: nil, pid: nil, error_info: nil, neighbours: nil do
    def construct(proc, neighbours) do
      new(proc).neighbours(neighbours)
    end
  end

  defrecord Reason, reason: nil
  defrecord Format, format: nil, args: []

  def init(_) do
    {:ok, nil}
  end

  def handle_event(event_log, state) do
    handle_event_log(event_log, state)
    {:ok, state}
  end

  defp handle_event_log({:error, _gl, {pid, fmt, args}}, state) do
    case fmt do
      '** Generic server' ++ _ ->
        # gen_server terminate
        [name, _msg, _state, reason] = args
        ExLogger.error "gen_server ${name} terminated with reason ${reason}",
                       name: name, reason: Reason[reason: reason], __PID__: pid, __MODULE__: nil
      '** State machine' ++ _ ->
        # gen_fsm terminate
        [name, _msg, state_name, _state_data, reason] = args
        ExLogger.error "gen_fsm ${name} in state ${state} terminated with reason ${reason}",
                       name: name, state: state_name, reason: Reason[reason: reason], __PID__: pid, __MODULE__: nil
      '** gen_event handler' ++ _ ->
        # gen_event handler terminate
        [id, name, _msg, state, reason] = args
        ExLogger.error "gen_event ${id} installed in ${name} terminated with reason ${reason}",
                       handler: id, name: name, state: state, reason: Reason[reason: reason], __PID__: pid, __MODULE__: nil
        _ ->
          # TODO: custom formatters, pluggable
          ExLogger.error "${error}", error: Format[format: fmt, args: args], __PID__: pid, __MODULE__: nil
    end
    state
  end

  defp handle_event_log({:error_report, _gl, {pid, :std_error, d}}, state) do
    ExLogger.error to_string(d), __PID__: pid
    state
  end
  
  defp handle_event_log({:error_report, _gl, {pid, :supervisor_report, d}}, state) do
    offender = d[:offender]
    if is_list(d) and not nil?(offender) do
      case offender[:mfargs] do
        nil ->
          ## supervisor_bridge
          ExLogger.error "Supervisor ${supervisor} had child at module ${module} at ${pid} exit with reason ${reason} " <>
                         "in context ${context}",
                         supervisor: supervisor_name(d[:supervisor]),
                         reason: Reason[reason: d[:reason]], context: d[:errorContext],
                         module: offender[:mod], pid: offender[:pid],
                         __PID__: pid, __MODULE__: nil
        mfa ->
          ## regular supervisor
          ExLogger.error "Supervisor ${supervisor} had child ${name} started with ${mfa} at ${pid} exit with reason ${reason} " <>
                         "in context ${context}",
                         supervisor: supervisor_name(d[:supervisor]),
                         reason: Reason[reason: d[:reason]], context: d[:errorContext], 
                         name: offender[:name], pid: offender[:pid],
                         mfa: ExLogger.MFA.construct(mfa),
                         __PID__: pid, __MODULE__: nil
      end
    else
      ExLogger.error to_string(d), __PID__: pid
    end
    state
  end
  defp handle_event_log({:error_report, _gl, {pid, :crash_report, [proc, neighbours]}}, state) do
    ExLogger.error "CRASH REPORT ${report}",
                    report: CrashReport.construct(proc, neighbours),
                    __PID__: pid, __MODULE__: nil
    state
  end

  defp handle_event_log({:info_report, _gl, {pid, :progress, details}}, state) do
    cond do
      not nil?(app = Dict.get(details, :application)) ->
        app = to_string(app)
        node = to_string(Dict.get(details, :started_at))
        ExLogger.info("Application ${application} started on node ${node}",
                      type: :application_start, application: app, node: node,
                      __MODULE__: nil, __PID__: nil)
      not nil?(started = Dict.get(details, :started)) ->
        ExLogger.info "Supervisor ${supervisor} started ${mfa} at ${__PID__}",
                    type: :supervisor_start,
                    supervisor: supervisor_name(details[:supervisor]), mfa: ExLogger.MFA.construct(started[:mfargs]),
                    __MODULE__: nil, __PID__: details[:pid]
      true ->
        ExLogger.info "PROGRESS REPORT ${report}",
                   type: :progress_report, report: details,
                   __MODULE__: nil, __PID__: pid
    end
    state
  end
  defp handle_event_log({:warning_msg, _gl, {pid, fmt, args}}, state) do
    ExLogger.warning "${message}", message: Format[format: fmt, args: args],
                     __MODULE__: nil, __PID__: pid
    state
  end
  defp handle_event_log({:warning_report, _gl, {pid, :std_warning, report}}, state) do
    ExLogger.warning "${message}", message: inspect(report),
                     __MODULE__: nil, __PID__: pid
    state
  end
  defp handle_event_log({:info_msg, _gl, {pid, fmt, args}}, state) do
    ExLogger.info "${message}", message: Format[format: fmt, args: args],
                     __MODULE__: nil, __PID__: pid
    state
  end
  defp handle_event_log({:info_report, _gl, {pid, :std_info, report}}, state) do
    if not nil?(report[:application]) and not nil?(report[:exited]) do
      ExLogger.info "Application ${application} exited with reason ${reason}",
                    application: report[:application], reason: Reason[reason: report[:exited]],
                    __MODULE__: nil, __PID__: pid
    else
      ExLogger.info "${message}", message: inspect(report),
                       __MODULE__: nil, __PID__: pid
    end
    state
  end
  defp handle_event_log(other, state) do
    ExLogger.info "${message}", message: inspect(other),
                     __MODULE__: nil, __PID__: nil
    state                  
  end

  defp supervisor_name({:local, name}), do: name
  defp supervisor_name(name), do: name

end