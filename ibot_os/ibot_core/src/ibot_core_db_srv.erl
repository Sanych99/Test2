%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. Март 2015 10:52
%%%-------------------------------------------------------------------
-module(ibot_core_db_srv).
-author("alex").

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-export([add_record/3, get_record/2, delete_table/1]).

-define(SERVER, ?MODULE).

-include("debug.hrl").
-include("config_db_keys.hrl").
-include("ibot_gen_srvs.hrl").
-include("ibot_table_names.hrl").
-include("ibot_table_commands.hrl").

-record(state, {}).


start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).


init([]) ->
  ibot_core_db_func:create_db(?TABLE_CONFIG), %% Запуск / создание таблицы для хранения данных конфигурации проекта
  {ok, #state{}}.



handle_call({?ADD_RECORD, TableName, Key, Value}, _From, State) ->
  ?DBG_INFO("try add topic: ~p~n", [{?ADD_RECORD, TableName, Key, Value}]),
  ibot_core_db_func:add(TableName, Key, Value), %% Добавиляем запись
  ?DBG_INFO("try get topic ~p~n", ibot_core_db_func:get(TableName, Key)),
  %?DBG_INFO("ibot_topics info: ~p~n", [ets:info(ibot_topics)]),
  {reply, ok, State};

handle_call({?GET_RECORD, TableName, Key}, _From, State) ->
  io:format("handle_call: ~p~n", [ibot_core_db_func:get(TableName, Key)]),
  case ibot_core_db_func:get(TableName, Key) of %% Получить данные
    [{Key, Value}] ->
      ?DBG_INFO("handle_call find: ~p~n", [{Key, Value}]),
      {reply, {ok, Value}, State};
    [] ->
      ?DBG_INFO("handle_call NOT find...~n", []),
      {reply, record_not_found, State}
  end;

handle_call({?DELETE_TABLE, TableName}, _From, State) ->
  ibot_core_db_func:delete_table(TableName), %% Добавиляем запись
  {reply, ok, State}.

handle_cast(_Request, State) ->
  {noreply, State}.


handle_info(_Info, State) ->
  {noreply, State}.


terminate(_Reason, _State) ->
  ok.


code_change(_OldVsn, State, _Extra) ->
  {ok, State}.


%%======================
%% Internal functions
%%======================

add_record(TableName, Key, Value) ->
  gen_server:call(?IBOT_CORE_DB_SRV, {add_record, TableName, Key, Value}).

get_record(TableName, Key) ->
  gen_server:call(?IBOT_CORE_DB_SRV, {add_record, TableName, Key}).

delete_table(TableName) ->
  gen_server:call(?IBOT_CORE_DB_SRV, {delete_table, TableName}).


%%===================================
%% Config manipulation spec function
%%===================================
set_project_full_path(Path) ->
  gen_server:call(?IBOT_CORE_DB_SRV, {add_record, ?TABLE_CONFIG, ?FULL_PROJECT_PATH, Path}).

get_project_full_path() ->
  gen_server:call(?IBOT_CORE_DB_SRV, {add_record, ?TABLE_CONFIG, ?FULL_PROJECT_PATH}).
