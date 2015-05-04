%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015
%%% @doc
%%%
%%% @end
%%% Created : 28. Feb 2015 12:01 AM
%%%-------------------------------------------------------------------
-module(ibot_db_func).

-export([create_db/1, add/3, get/2, delete_table/1]).

-export([add_to_mnesia/1, get_from_mnesia/2]).



create_db(TableName) ->
  ets:new(TableName, [named_table, public]).

add(TableName, Key, Value) ->
  ets:insert(TableName, {Key, Value}).

get(TableName, Key) ->
  ets:lookup(TableName, Key).

delete_table(TableName) ->
  ets:delete(TableName).


add_to_mnesia(Record) ->
  mnesia:transaction(fun() -> mnesia:write(Record) end).

get_from_mnesia(Table, Key) ->
  case mnesia:transaction(fun() -> mnesia:read(Table, Key) end) of
    {atomic, []} -> not_found;
    {atomic, [Item]} -> Item
  end.