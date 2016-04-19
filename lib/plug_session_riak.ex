defmodule PlugSessionRiak do
  use Application

@vsn "0.0.1"
    
  @moduledoc """
  This plug is to be used as store for Plug.Session. It saves session data in
  a memcached instance providing just a session id being saved in the user's 
  cookie. 
  Provides Plug.Session.RIAK
  
  ## Usage
   1. Configure the connection to a memcached instance:
      ```
      config :plug_memcached_riak , ['127.0.0.1']
      ```
  2. In your app, use and configure Plug.Session
     ```
     plug Plug.Session,
       store: :riak,
       key: "_my_app_key", # use a proper value 
       signing_salt: "123456",   # use a proper value
       encryption_salt: "654321" # use a proper value
     ```
  
  ## Limitations
  
  Maximum session data size is 2MB. Riak works best with small objects, ideally keep the session smaller than 100kb. Data serialization is done via Erlang's 
  `term_to_binary(Data)` (see [mcd](https://github.com/EchoTeam/mcd/blob/master/src/mcd.erl#L715))
  
  """

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # start memcached for sessions
    # :mcd.start_link(:memcached_sessions, [] )

    children = [
      # Define workers and child supervisors to be supervised
      # worker(PlugSessionMemcached.Worker, [arg1, arg2, arg3])
      # worker( :mcd, [ :memcached_sessions, [ '127.0.0.1', 11211 ] ] )
      supervisor( PlugSessionMemcached.Supervisor, [] )
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PlugSessionRiak.Supervisor]
    { :ok, _pid } = Supervisor.start_link(children, opts)
  end

end

defmodule PlugSessionRiak.Supervisor do
  use Supervisor

  def start_link arg \\ [] do
    Supervisor.start_link __MODULE__, arg
  end
  
  def init _arg do
    children = [
      worker( :riak, [
          :riak_sessions,
          Application.get_env( :plug_session_riak, :server ) || [ '127.0.0.1', 11211 ],
        ]
      )
    ]
    supervise children, strategy: :one_for_one
  end

end

defmodule Plug.Session.RIAK do
    @moduledoc """
    Stores the session in a memcached table.

    ## Usage 

    See PlugSessionRiak , issue `h PlugSessionRiak` in an iex shell


    An established Riak connection instance via Riak is required for this
    store to work.

    This store does not create the Riak connection, it is expected that an
    existing named connection is given as argument with  public properties.

    ## Examples

    # Use the session plug with the connection process name
    key = "myapp_session_id"
    plug Plug.Session,  store: :riak, key: key


    See:
    https://github.com/drewkerrigan/riak-elixir-client

    ## Acknowledgements
    This module is based on Plug.Session.MEMCACHED
    Most parts are just copied from there and adapted to :mcd instead of :ets.
    """

    @behaviour Plug.Session.Store

    @max_tries 100

    def init(opts) do
        Keyword.fetch!(opts, :table)
    end

    def get( _conn, sid, table) do
        #case :mcd.get( table, sid ) do
        #  {:error, :noproc}   -> raise "cannot find memcached proc"
        #  {:error, :notfound} -> {nil, %{}}
        #  {:error, :noconn} -> {nil, %{}}
        #  {:ok, data }        -> {sid, data}
        #end
        {sid, "foo"}

    end

    def put( _conn, nil, data, table) do
        #put_new(data, table)
        sid = :crypto.strong_rand_bytes(96) |> Base.encode64
    end

    def put( _conn, sid, data, table) do
        #:mcd.set( table, sid, data )
        sid
    end

    def delete( _conn, sid, table) do
        #:mcd.delete(table, sid)
        :ok
    end

#    defp put_new(data, table, counter \\ 0)
#        #when counter < @max_tries do
#        #    sid = :crypto.strong_rand_bytes(96) |> Base.encode64
#        #put( nil, sid, data, table )
#        :ok
#    end
end
