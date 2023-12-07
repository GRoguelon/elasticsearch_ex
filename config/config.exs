import Config

if config_env() in ~w[dev test]a do
  import_config "#{config_env()}.exs"
end
