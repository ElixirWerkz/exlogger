defmodule ExLogger.BackendWatcher do
  use GenServer.Behaviour    
  use ExLogger

  def start(event, module, options) do
    :supervisor.start_child(ExLogger.Sup.BackendWatcher, [event, module, options])
  end

  def start_link(event, module, options) do
    :gen_server.start_link(__MODULE__,[event, module, options], [])
  end

  defrecordp :state, :state, event: nil, module: nil, options: nil

  def init([event, module, options]) do
    install_handler(event, module, options)
    {:ok, state(event: event, module: module, options: options)}
  end

  def handle_info({:gen_event_EXIT, module, reason},
                  state(module: module) = s) when reason in %w(normal shutdown)a do
    {:stop, :normal, s}
  end

  def handle_info({:gen_event_EXIT, module, reason},
                  state(module: module, options: options, event: event) = s) do
    ExLogger.error "ExLogger ${backend} backend exited with reason ${reason}",
                   application: :exlogger, backend: module, reason: reason
    install_handler(event, module, options)
    {:noreply, s}
  end

  defp install_handler(event, module, options) do
     case :gen_event.add_sup_handler(event, module, options) do
       :ok -> :ok
       error ->
         ExLogger.warning "ExLogger fatally failed installing ${backend} backend, error: ${error}",
                          application: :exlogger,
                          event: event, backend: module, options: options, error: error
         :gen_server.cast(self, :stop)
     end
  end

end