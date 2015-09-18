%%%-------------------------------------------------------------------
%%% @author Tsaregorodtsev Alexandr
%%% @copyright iBot Robotics
%%% @doc
%%% Функции управления записями бд и распределенной бд
%%% @end
%%% Created : 14. Mar 2015 10:27 PM
%%%-------------------------------------------------------------------
-module(ibot_db_srv).

-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([
  add_record/3, %% добавить запись
  get_record/2, %% получить запись
  delete_table/1]). %% удалить таблицу
-export([
  start_distibuted_db/0, %% запуск распределенной бд
  stop_distributed_db/0, %% остановка распределенной бд
  create_distributed_shema/0, %% создание схемы распределенной бд
  create_distributed_tables/0 %% создание таблиц распределенной бд
]).

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
%% Start module
%% @end
start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%% ====== start_link function end ======


%% ====== init function start ======
%% @doc
%% Create system tables
%% @end
init([]) ->
  stop_distributed_db(), %% Stop Mnesia applcation
  ibot_db_func:create_db(?TABLE_CONFIG), %% Запуск / создание таблицы для хранения данных конфигурации проекта
  ibot_db_func:create_db(?TABLE_SERVICES_CLIENT), %% Create cilent service table
  {ok, #state{}}.


%% @doc
%% Create database schema on all connected core nodes
%% @end
create_distributed_shema() ->
  ?DBG_MODULE_INFO("create_distributed_shema() -> ~p~n", [?MODULE, [node() | nodes()]]),
  mnesia:create_schema([node() | nodes()]).


%% @doc
%% Start mnesia database
%% @end
start_distibuted_db() ->
  application:start(mnesia).


%% @doc
%% Stop mnesia database
%% @spec stop_distributed_db() -> ok | error.
%% @end
-spec stop_distributed_db() -> ok | error.

stop_distributed_db() ->
  case application:ensure_started(mnesia) of
    ok -> application:stop(mnesia);
    _ -> error
  end.


%% @doc
%% Create tables on all connected core nodes
%% @spec create_distributed_tables() -> ok.
%% @end
-spec create_distributed_tables() -> ok.

create_distributed_tables() ->

  mnesia:create_table(node_info, [{attributes, record_info(fields, node_info)}]),

  mnesia:create_table(topic_info, [{attributes, record_info(fields, topic_info)}]),

  mnesia:create_table(service_server, [{attributes, record_info(fields, service_server)}]),
  ok.

%% ====== init function end ======




%% ====== handle_call function start ======
%% @doc
%% Add new record to table
%% @end
handle_call({?ADD_RECORD, TableName, Key, Value}, _From, State) ->
  ?DMI("ADD_RECORD", [{?ADD_RECORD, TableName, Key, Value}]),
  ibot_db_func:add(TableName, Key, Value), %% добавиляем запись
  {reply, ok, State};


%% @doc
%% Get record from table
%% @end
handle_call({?GET_RECORD, TableName, Key}, _From, State) ->
  ?DMI("GET_RECORD", {TableName, Key}),
  case ibot_db_func:get(TableName, Key) of %% получить данные
    [{Key, Value}] ->
      %% возвращаем найденную запись
      ?DMI("row found", [{Key, Value}]),
      {reply, {ok, Value}, State};
    [] ->
      %% запись не найдена
      ?DMI("row NOT found", ?ONLY_MESSAGE),
      {reply, record_not_found, State}
  end;


%% @doc
%% Dalete table
%% @end
handle_call({?DELETE_TABLE, TableName}, _From, State) ->
  ibot_db_func:delete_table(TableName), %% удаление таблицы
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
%% Dalete system table
%% @end
terminate(_Reason, _State) ->
  ibot_db_func:delete_table(?TABLE_CONFIG), %% Delete congiguration table
  ibot_db_func:delete_table(?TABLE_SERVICES_CLIENT), %% Delete cilent service table

  %% delete tables from distributed database
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
%% Add record to table
%% @spec add_record(TableName, Key, Value) -> ok when TableName :: atom(), Key :: atom(), Value :: term().
%% @end
-spec add_record(TableName, Key, Value) -> ok when TableName :: atom(), Key :: atom(), Value :: term().

add_record(TableName, Key, Value) ->
  gen_server:call(?IBOT_DB_SRV, {add_record, TableName, Key, Value}).


%% @doc
%% Get record from table
%% @spec get_record(TableName, Key) -> {ok, Val} | record_not_found
%% when TableName :: atom(), Key :: atom().
%% @end
-spec get_record(TableName, Key) -> {ok, _} | record_not_found

  when TableName :: atom(), Key :: atom().
get_record(TableName, Key) ->
  gen_server:call(?IBOT_DB_SRV, {get_record, TableName, Key}).


%% @doc
%% Delete system table
%% @spec delete_table(TableName) -> ok when TableName :: atom().
%% @end
-spec delete_table(TableName) -> ok when TableName :: atom().

delete_table(TableName) ->
  gen_server:call(?IBOT_DB_SRV, {delete_table, TableName}).

%% ====== records manipulation function end ======