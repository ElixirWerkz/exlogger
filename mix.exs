defmodule Logger.Mixfile do
  use Mix.Project

  def project do
    [ app: :exlogger,
      version: "0.0.1",
      elixir: "~> 0.10.2-dev",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [mod: {ExLogger.App, []},
     env: [
       error_logger_redirect: true,
       log_level: :debug,
       backends: [
         ExLogger.Backend.IO,
       ],
     ]
    ]
  end

  defp deps do
    []
  end
end
