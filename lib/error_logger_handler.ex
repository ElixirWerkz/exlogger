defmodule ExLogger.ErrorLoggerHandler do
  use GenEvent.Behaviour
  use ExLogger

  def init(_) do
    {:ok, nil}
  end

  def handle_event(event_log, state) do
    handle_event_log(event_log, state)
    {:ok, state}
  end

  defp handle_event_log({:error, _gl, {_pid, _fmt, _args}}, state), do: state
  defp handle_event_log({:info_report, _gl, {_pid, :progress, details}}, state) do
    cond do
      not nil?(app = Dict.get(details, :application)) ->
        app = to_string(app)
        node = to_string(Dict.get(details, :started_at))
        ExLogger.info("Application ${application} started on node ${node}",
                      type: :application_start, application: app, node: node,
                      __MODULE__: nil, __PID__: nil)
      true ->
        :ok
    end
    state
  end
  defp handle_event_log(_, _state), do: nil
end