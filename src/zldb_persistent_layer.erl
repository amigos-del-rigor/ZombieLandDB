%% Copyright
-module(zldb_persistent_layer).
-author("jllonch").

%% API
-export([get/1, set/2]).

get(_Id) ->
  {ok, "Lorem ipsum dolor sit amet, consectetur adipiscing elit"}.

set(_Id, _Value) ->
  ok.

