ExUnit.start()
{:ok, _} = Application.ensure_all_started(:req)
{:ok, _} = Application.ensure_all_started(:castore)
