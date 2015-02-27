%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015
%%% @doc
%%%
%%% @end
%%% Created : 28. Feb 2015 12:01 AM
%%%-------------------------------------------------------------------
-module(ibot_core_config_db).
-author("alex").

%% API
-export([create_db/0, add/2, get/1, delete_db/0]).

create_db() ->
  ets:new(ibot_config, [named_table]).

add(Key, Value) ->
  ets:insert(ibot_config, {Key, Value}).

get(Key) ->
  ets:lookup(ibot_config, Key).

delete_db() ->
  ets:delete(ibot_config).
