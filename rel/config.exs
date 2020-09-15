~w(rel plugins *.exs)
|> Path.join()
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Distillery.Releases.Config,
    default_release: :default,
    default_environment: Mix.env()

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: System.get_env("ERLANG_COOKIE") || 
    raise """
    environment variable ERLANG_COOKIE is missing.
    """

  set vm_args: "rel/vm.args"
end

release :altbee do
  set version: current_version(:altbee)
  set applications: [
    :runtime_tools
  ]
  set commands: [
    migrate: "rel/commands/migrate.sh",
    seed: "rel/commands/seed.sh"
  ]
end

