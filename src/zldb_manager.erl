%% Copyright
-module(zldb_manager).
-author("jllonch").

%% API
-export([initialize/0, get_pid_from_id/1, get_term_pid_from_id/1, delete/1]).

initialize() ->
  % Create a new ETS table, called from supervisor
  ets:new(zldb_id2pid,[set, public, named_table, {read_concurrency, true}]).

get_pid_from_id(Id) ->
  % lookup Id in ETS to get Pid
  Result = get_value(Id),

  case Result of
    % if Id not exists query persistent layer to get data, spawn new process with data and return new Pid
    none ->
      {ok, Pid} = revive(Id),
      {ok, Pid};
    % if Id exists return
    {Id, Pid} ->
      {ok, Pid}
  end.

get_term_pid_from_id(Id) ->
  {ok, Pid} = get_pid_from_id(Id),
  TermPid = pid_to_list(Pid),
  {ok, TermPid}.


%% Private functions
delete(Key) ->
  true = ets:delete(zldb_id2pid, Key),
  ok.

set_value(Key, Value) ->
  % Insert Key, Value into ETS
  {ok, Result} = case ets:insert(zldb_id2pid, {Key, Value}) of
    true ->
      {ok, {Key,Value}};
    {error, Reason} ->
      {error, Reason}
  end,
  Result.

get_value(Key) ->
  % Search for the key in ETS
  {ok, Result} = case ets:lookup(zldb_id2pid, Key) of
    [{_,Value}] ->
      {ok, {Key,Value}};
    [] ->
      {ok, none};
    {error, Reason} ->
      {error, Reason}
  end,
  Result.

revive(Id) ->
  % query to persistent layer
  {ok, Result} = zldb_persistent_layer:get(Id),
  revive_persistent_layer_result(Id, Result).

revive_persistent_layer_result(_, not_found) -> {warning, id_not_found};
revive_persistent_layer_result(Id, Value) ->
  % spawn new process
  {ok, Pid} = zldb_entity_sup:create_new_entity(),
  % set data
  zldb_entity:set(Pid, id, Id),
  zldb_entity:set(Pid, data, Value),
  % save Id and Pid
  set_value(Id, Pid),
  % return new Pid
  {ok, Pid}.
