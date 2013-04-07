%% Copyright
-module(zldb_entity_sup).
-author("jllonch").

-behaviour(supervisor).

%% API
-export([start_link/0, create_new_entity/0]).

%% supervisor
-export([init/1]).

%% API
start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

create_new_entity() ->
  {ok, Pid} = supervisor:start_child(?MODULE, []),
  {ok, Pid}.

%% supervisor callbacks
init(_Args) ->
  {ok, {{simple_one_for_one, 0, 1},
    [{zldb_entity, {zldb_entity, start_link, []},
      transient, 2000, worker, [zldb_entity]}]}}.

