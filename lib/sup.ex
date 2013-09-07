defmodule ExLogger.Sup do
  use Supervisor.Behaviour

  defmodule BackendWatcher do
    use Supervisor.Behaviour
    
    def start_link do
      :supervisor.start_link({:local, __MODULE__}, __MODULE__, [])
    end

    def init([]) do
      children = [
        supervisor(ExLogger.BackendWatcher, [], restart: :transient)
      ]
      supervise(children, strategy: :simple_one_for_one)
    end
      
  end

  def start_link do
    :supervisor.start_link({:local, __MODULE__}, __MODULE__, [])
  end

  def init([]) do
    children = [
      worker(:gen_event, [{:local, ExLogger.Event}], id: ExLogger.Event),
      supervisor(ExLogger.Sup.BackendWatcher, []),
    ]
    supervise(children, strategy: :one_for_one)
  end

end