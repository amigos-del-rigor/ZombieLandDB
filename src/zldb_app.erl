-module(zldb_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
%%   lager:set_loglevel(lager_console_backend, info),
  lager:set_loglevel(lager_console_backend, debug),
  zldb_sup:start_link().

stop(_State) ->
    ok.
