%%%-------------------------------------------------------------------
%%% @author Tsaregorodtsev Alexandr
%%% @copyright (C) 2015
%%% @doc
%%%
%%% @end
%%% Created : 14. Mar 2015 10:27 PM
%%%-------------------------------------------------------------------
-module(ibot_db_srv).

-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([add_record/3, get_record/2, delete_table/1, start_m/0]).

-define(SERVER, ?MODULE).

-include("../../ibot_core/include/debug.hrl").
-include("ibot_db_project_config_param.hrl").
-include("ibot_db_modules.hrl").
-include("ibot_db_table_names.hrl").
-include("ibot_db_table_commands.hrl").
-include("ibot_db_records_service.hrl").
-include("ibot_db_records.hrl").
-include("../../ibot_nodes/include/ibot_nodes_registration_info.hrl").

-record(state, {}).

%% ====== start_link function start ======
%% @doc
%%
%% Start module
%% @end

start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%% ====== start_link function end ======


%% ====== init function start ======
%% @doc
%%
%% Create system tables
%% @end

init([]) ->
  ibot_db_func:create_db(?TABLE_CONFIG), %% Запуск / создание таблицы для хранения данных конфигурации проекта
  ibot_db_func:create_db(?TABLE_SERVICES_CLIENT), %% Create cilent service table
  start_m(),
  {ok, #state{}}.

start_m() ->
  mnesia:create_schema([node() | nodes()]),

  application:start(mnesia),

  mnesia:create_table(node_info,
    [{attributes, record_info(fields, node_info)}]),

  mnesia:create_table(topic_info,
    [{attributes, record_info(fields, topic_info)}]),

  mnesia:create_table(service_server,
    [{attributes, record_info(fields, service_server)}]),
  ok.

%% ====== init function end ======


%% ====== handle_call function start ======
%% @doc
%%
%% Add new record to table
%% @end

handle_call({?ADD_RECORD, TableName, Key, Value}, _From, State) ->
  ?DBG_INFO("try add topic: ~p~n", [{?ADD_RECORD, TableName, Key, Value}]),
  ibot_db_func:add(TableName, Key, Value), %% Добавиляем запись
  ?DBG_INFO("try get topic ~p~n", ibot_db_func:get(TableName, Key)),
  %?DBG_INFO("ibot_topics info: ~p~n", [ets:info(ibot_topics)]),
  {reply, ok, State};


%% @doc
%%
%% Get record from table
%% @end

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


%% @doc
%%
%% Dalete table
%% @end

handle_call({?DELETE_TABLE, TableName}, _From, State) ->
  ibot_db_func:delete_table(TableName), %% Добавиляем запись
  {reply, ok, State}.

%% ====== handle_call function end ======



%% ====== handle_cast function start ======
handle_cast(_Request, State) ->
  {noreply, State}.
%% ====== handle_cast function end ======

%% ====== handle_info function start ======
handle_info(_Info, State) ->
  {noreply, State}.
%% ====== handle_info function end ======


%% ====== terminate function start ======
%% @doc
%%
%% Dalete system table
%% @end
terminate(_Reason, _State) ->
  ibot_db_func:delete_table(?TABLE_CONFIG), %% Delete congiguration table
  ibot_db_func:delete_table(?TABLE_SERVICES_CLIENT), %% Delete cilent service table

  mnesia:delete_table(node_info),
  mnesia:delete_table(topic_info),
  mnesia:delete_table(service_server),
  application:stop(mnesia),
  ok.
%% ====== terminate function end ======


%% ====== code_change function start ======
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.
%% ====== code_change function end ======

%%======================
%% API functions
%%======================



%% ====== records manipulation function start ======

%% @doc
%%
%% Add record to table
%% @end

add_record(TableName, Key, Value) ->
  gen_server:call(?IBOT_DB_SRV, {add_record, TableName, Key, Value}).


%% @doc
%%
%% Get record from table
%% @end

get_record(TableName, Key) ->
  gen_server:call(?IBOT_DB_SRV, {get_record, TableName, Key}).


%% @doc
%%
%% Delete system table
%% @end

delete_table(TableName) ->
  gen_server:call(?IBOT_DB_SRV, {delete_table, TableName}).

%% ====== records manipulation function end ======