%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright iBot Robotics
%%% @doc
%%% Функции управления записями бд
%%% @end
%%% Created : 28. Feb 2015 12:01 AM
%%%-------------------------------------------------------------------
-module(ibot_db_func).

-export([create_db/1, add/3, get/2, delete_table/1]).

-export([add_to_mnesia/1, get_from_mnesia/2]).


%% @doc
%% Создание ETS таблицы
%% @end
create_db(TableName) ->
  ets:new(TableName, [named_table, public]).

%% @doc
%% Доабвление записи с таблицу
%% @end
add(TableName, Key, Value) ->
  ets:insert(TableName, {Key, Value}).

%% @doc
%% Выбор записи из таблицы
%% @end
get(TableName, Key) ->
  ets:lookup(TableName, Key).

%% @doc
%% Удаление ETS таблицы
%% @end
delete_table(TableName) ->
  ets:delete(TableName).

%% @doc
%% Добавить значение в талицу Mnesia
%% @end
add_to_mnesia(Record) ->
  mnesia:transaction(fun() -> mnesia:write(Record) end).


%% @doc
%% Выбор значения из таблицы Mnesia
%% @end
get_from_mnesia(Table, Key) ->
  case mnesia:transaction(fun() -> mnesia:read(Table, Key) end) of
    {atomic, []} -> not_found; %% запись не найдена
    {atomic, [Item]} -> Item %% возвращаем запись
  end.