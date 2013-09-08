defmodule ExLogger.Backend do
  use Behaviour

  defcallback backend_init(options :: Keyword.t) :: {:ok, state :: term} | {:error, reason :: term}
  defcallback handle_log(log :: term, state :: term)

  defmacro __using__(_) do
    quote do
      use GenEvent.Behaviour
      Record.import ExLogger.Message, as: :message
      @behaviour ExLogger.Backend
      require ExLogger

      @levels ExLogger.levels
      @top_level hd(@levels)
      defrecordp :state, :state, state: nil, log_level: nil

      def init(options) do
        log_level = options[:log_level] || @top_level
        case backend_init(options) do
          {:ok, s} ->
            {:ok, state(state: s, log_level: log_level)}
          {:error, _} = error ->
            error
        end
      end

      lc level inlist @levels, level1 inlist @levels do
        @level level
        @level1 level1
        if Enum.find_index(@levels, fn(l) -> l == level end) >= Enum.find_index(@levels, fn(l) -> l == level1 end) do
          def handle_event({:log, message(level: @level) = msg}, state(state: backend_state, log_level: @level1) = s) do
            backend_state = handle_log(msg, backend_state)
            {:ok, state(s, state: backend_state)}
          end
        else 
          def handle_event({:log, message(level: @level) = msg}, state(state: backend_state, log_level: @level1) = s) do
            {:ok, s}
          end
        end
      end

      def handle_call({:set_log_level, level}, state() = s) when level in @levels do
        {:ok, level, state(s, log_level: level)}
      end

      def handle_call(:get_log_level, state(log_level: level) = s) do
        {:ok, level, s}
      end

    end
  end
end