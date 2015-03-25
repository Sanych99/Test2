%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. Mar 2015 10:27 PM
%%%-------------------------------------------------------------------
-module(ibot_db_srv).
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

-include("../../ibot_core/include/debug.hrl").
-include("ibot_db_project_config_param.hrl").
-include("ibot_db_modules.hrl").
-include("ibot_db_table_names.hrl").
-include("ibot_db_table_commands.hrl").

-record(state, {}).


start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).


init([]) ->
  ibot_db_func:create_db(?TABLE_CONFIG), %% Запуск / создание таблицы для хранения данных конфигурации проекта
  ibot_db_func:create_db(?TABLE_TOPICS), %% Create topics table
  ibot_db_func:create_db(?TABLE_NODE_INFO), %% Create node info table
  {ok, #state{}}.



handle_call({?ADD_RECORD, TableName, Key, Value}, _From, State) ->
  ?DBG_INFO("try add topic: ~p~n", [{?ADD_RECORD, TableName, Key, Value}]),
  ibot_db_func:add(TableName, Key, Value), %% Добавиляем запись
  ?DBG_INFO("try get topic ~p~n", ibot_db_func:get(TableName, Key)),
  %?DBG_INFO("ibot_topics info: ~p~n", [ets:info(ibot_topics)]),
  {reply, ok, State};

handle_call({?GET_RECORD, TableName, Key}, _From, State) ->
  ?DBG_MODULE_INFO("handle_call({?GET_RECORD, TableName, Key}: ~p~n", [?MODULE, {?GET_RECORD, TableName, Key}]),
  io:format("handle_call: ~p~n", [ibot_db_func:get(TableName, Key)]),
  case ibot_db_func:get(TableName, Key) of %% Получить данные
    [{Key, Value}] ->
      ?DBG_INFO("handle_call find: ~p~n", [{Key, Value}]),
      {reply, {ok, Value}, State};
    [] ->
      ?DBG_INFO("handle_call NOT find...~n", []),
      {reply, record_not_found, State}
  end;

handle_call({?DELETE_TABLE, TableName}, _From, State) ->
  ibot_db_func:delete_table(TableName), %% Добавиляем запись
  {reply, ok, State}.

handle_cast(_Request, State) ->
  {noreply, State}.


handle_info(_Info, State) ->
  {noreply, State}.


terminate(_Reason, _State) ->
  ibot_db_func:delete_table(?TABLE_CONFIG), %% Delete congiguration table
  ibot_db_func:delete_table(?TABLE_TOPICS), %% Delete topics table
  ibot_db_func:delete_table(?TABLE_NODE_INFO), %% Delete node info table
  ok.


code_change(_OldVsn, State, _Extra) ->
  {ok, State}.


%%======================
%% API functions
%%======================

add_record(TableName, Key, Value) ->
  gen_server:call(?IBOT_DB_SRV, {add_record, TableName, Key, Value}).

get_record(TableName, Key) ->
  gen_server:call(?IBOT_DB_SRV, {get_record, TableName, Key}).

delete_table(TableName) ->
  gen_server:call(?IBOT_DB_SRV, {delete_table, TableName}).


%%===================================
%% Config manipulation spec function
%%===================================
set_project_full_path(Path) ->
  gen_server:call(?IBOT_DB_SRV, {add_record, ?TABLE_CONFIG, ?FULL_PROJECT_PATH, Path}).

get_project_full_path() ->
  gen_server:call(?IBOT_DB_SRV, {get_record, ?TABLE_CONFIG, ?FULL_PROJECT_PATH}).