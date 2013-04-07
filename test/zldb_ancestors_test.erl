%% Copyright
-module(zldb_ancestors_test).
-author("jllonch").

-compile(export_all).

% Include etest's assertion macros.
-include_lib("etest/include/etest.hrl").

before_suite() ->
  ok.

before_test() ->
  ok.

test_ancestors() ->
  {ok, Pid1} = zldb_manager:get_pid_from_id("abc"),
  {ok, Pid2} = zldb_manager:get_pid_from_id("123"),

  {ok, ResultId1} = zldb_entity:get(Pid1, id),
  ?assert_equal("abc", ResultId1),
  {ok, ResultId2} = zldb_entity:get(Pid2, id),
  ?assert_equal("123", ResultId2),
  {ok, ResultData1} = zldb_entity:get(Pid1, data),
  ?assert_equal("Lorem ipsum dolor sit amet, consectetur adipiscing elit", ResultData1),
  {ok, ResultData2} = zldb_entity:get(Pid2, data),
  ?assert_equal("Lorem ipsum dolor sit amet, consectetur adipiscing elit", ResultData2).


after_test() ->
  ok.

after_suite() ->
  ok.