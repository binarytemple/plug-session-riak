use Mix.Config

config :pooler, pools:
  [
    [
      name: :riaklocal,
      group: :riak,
      max_count: 15,
      init_count: 2,
      start_mfa: { Riak.Connection, :start_link, [
      System.get_env("RIAK_HOST") || '127.0.0.1', System.get_env("RIAK_PORT") || "8097"  ] }
    ]
  ]

config :plug_session_riak,
  server: [
  System.get_env("RIAK_HOST"), 8097
  ]
