%% Copyright
-module(zldb_entity).
-author("jllonch").

-behaviour(gen_fsm).

%% API
-export([start_link/0, get/2, set/3, set_ttl/2]).

%% gen_fsm
-export([init/1, running/2, running/3, handle_event/3,
  handle_sync_event/4, handle_info/3, terminate/3, code_change/4]).

%% API
start_link() ->
  gen_fsm:start_link(?MODULE, [], []).

get(Pid, Key) ->
  gen_fsm:sync_send_event(Pid, {get, Key}).

set(Pid, Key, Value) ->
  gen_fsm:send_event(Pid, {set, {Key, Value}}).

set_ttl(Pid, NewTime) ->
  gen_fsm:send_event(Pid, {set_timer, NewTime}),
  ok.

%% gen_fsm callbacks
-record(zldb_entity_state, {
  timer_ref=none,
  timer_time=60000, % ms (1')
  loop_data=[] % proplist
}).

init(_Args) ->
  State = #zldb_entity_state{},
  {ok, running, State}.


running({set, {Key, Value}}, State) ->
  NewState = loopdata_set(State, Key, Value),
  NewStateTimerUpdated = update_timer(NewState),
  {next_state, running, NewStateTimerUpdated};
running({set_timer, Time}, State) ->
  NewState = set_timer(State, Time),
  {next_state, running, NewState};
running({timeout, _Ref, "life is too hard, killme!"}, State) ->
  Id = loopdata_get(State, id),
  % delete item in the manager that links id to pid
  zldb_manager:delete(Id),
  {stop, shutdown, State}.


running({get, Key}, _From, State) ->
  Value = loopdata_get(State, Key),
  NewStateTimerUpdated = update_timer(State),
  {reply, {ok, Value}, running, NewStateTimerUpdated}.

handle_event(_Event, StateName, State) ->
  {next_state, StateName, State}.

handle_sync_event(_Event, _From, StateName, State) ->
  {reply, ok, StateName, State}.

handle_info(_Info, StateName, State) ->
  {next_state, StateName, State}.

terminate(_Reason, _StateName, _State) ->
  ok.

code_change(_OldVsn, StateName, State, _Extra) ->
  {ok, StateName, State}.


%% internal functions
loopdata_get(State, Key) ->
  LoopData = State#zldb_entity_state.loop_data,
  Value = proplists:get_value(Key, LoopData),
  Value.

loopdata_set(State, Key, Value) ->
  LoopData = State#zldb_entity_state.loop_data,
  PreNewLoopData = proplists:delete(Key, LoopData),
  NewLoopData = PreNewLoopData ++ [{Key, Value}],
  NewState = State#zldb_entity_state{loop_data=NewLoopData},
  NewState.

start_timer(Time) ->
  gen_fsm:start_timer(Time, "life is too hard, killme!").

cancel_timer(none) ->
  ok;
cancel_timer(TimerRef) ->
  gen_fsm:cancel_timer(TimerRef),
  ok.

set_timer(State, Time) ->
  TimerRef = State#zldb_entity_state.timer_ref,
  cancel_timer(TimerRef),
  NewTimerRef = start_timer(Time),
  State#zldb_entity_state{timer_ref=NewTimerRef, timer_time=Time}.

update_timer(State) ->
  Time = State#zldb_entity_state.timer_time,
  NewState = set_timer(State, Time),
  NewState.