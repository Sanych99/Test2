%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. Mar 2015 7:41 PM
%%%-------------------------------------------------------------------
-module(test).
-author("alex").

%% API
-export([run/0]).


run() ->
  ibot_core_app:start(1,1),
  ibot_core_app:create_project("/home/alex/ErlangTest", "test_project"),
  ibot_core_app:create_node("test_node", "java"),
  ibot_core_app:stop({}),
  ok.