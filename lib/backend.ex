defmodule ExLogger.Backend do

  defmacro __using__(_) do
    quote do
      use GenEvent.Behaviour
      Record.import ExLogger.Message, as: :message

      def handle_event({:log, msg}, state) do
        state = handle_log(msg, state)
        {:ok, state}
      end
    end
  end
end