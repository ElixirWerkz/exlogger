defmodule ExLogger.Backend.IO do
  use ExLogger.Backend

  defrecordp :backend_state, :backend_state, file: nil, ansi: nil

  def backend_init(options) do
    file = options[:file] || :stdio
    if is_binary(file) do
      file = File.open!(file, [:write])
    end
    case options[:ansi] do
      nil ->
        ansi = is_atom(file) and IO.ANSI.terminal?
      ansi ->
        :ok
      end
    {:ok, backend_state(file: file, ansi: ansi)}
  end

  def handle_log(message(timestamp: timestamp,
                          level: level, message: msg, object: object,
                          module: module, file: file, line: line, pid: pid),
                  backend_state(file: output_file, ansi: ansi) = s) do
    string =
    Enum.join([
       format_timestamp(timestamp),
       format_level(level),
       format_pid(pid),
       ExLogger.Format.format(msg, object),
       format_location(module, file, line),
      ] |> Enum.filter(fn(x) -> not nil?(x) end), " ") |>
      String.replace("\n", "\n\r")
    IO.write output_file, IO.ANSI.escape("\r" <> string <> "\n\r", ansi)
    if is_pid(output_file), do: :file.datasync(output_file)
    s
  end

  defp format_timestamp(timestamp) do
    time = :calendar.now_to_local_time(timestamp)
    {{year, month, day}, {hour, minute, second}} = time
    String.rjust("#{day}", 2, ?0) <> "-" <> String.rjust("#{month}", 2, ?0) <> "-" <>
    "#{year} " <>
    String.rjust("#{hour}", 2, ?0) <> ":" <> String.rjust("#{minute}", 2, ?0) <> ":" <>
    String.rjust("#{second}", 2, ?0)
  end

  defp format_level(:error), do: "%{red}[error]"
  defp format_level(:alert), do: "%{red, bright}[alert]"
  defp format_level(:emergency), do: "%{red, bright}[emergency]"
  defp format_level(:critical), do: "%{red, bright}[critical]"
  defp format_level(:warning), do: "%{orange, bright}[warning]"
  defp format_level(:info), do: "%{yellow}[info]"
  defp format_level(:notice), do: "[notice]"
  defp format_level(:debug), do: "%{green, bright}[debug]"
  defp format_level(:verbose), do: "%{green, bright}[verbose]"
  defp format_level(level), do: "[#{level}]"

  defp format_location(nil, _, _), do: nil
  defp format_location(module, file, line) do
    "(#{file}:#{line}, module #{inspect module})"
  end

  defp format_pid(nil), do: nil
  defp format_pid(pid), do: "[#{inspect pid}]"
end