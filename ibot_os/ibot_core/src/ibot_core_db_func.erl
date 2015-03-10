%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015
%%% @doc
%%%
%%% @end
%%% Created : 28. Feb 2015 12:01 AM
%%%-------------------------------------------------------------------
-module(ibot_core_db_func).

-export([create_db/1, add/3, get/2, delete_table/1]).

create_db(TableName) ->
  ets:new(TableName, [named_table, public]).

add(TableName, Key, Value) ->
  ets:insert(TableName, {Key, Value}).

get(TableName, Key) ->
  ets:lookup(TableName, Key).

delete_table(TableName) ->
  ets:delete(TableName).
