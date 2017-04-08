use Mix.Config

config :logger,
  level: :debug,
  backends: [:console],             # default, support for additional log sinks
  compile_time_purge_level: :debug  # purges logs with lower level than this
