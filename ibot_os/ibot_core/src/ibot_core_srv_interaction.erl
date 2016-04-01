%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. May 2015 1:13 AM
%%%-------------------------------------------------------------------
-module(ibot_core_srv_interaction).
-author("alex").

-behaviour(gen_server).

-include("debug.hrl").
-include("ibot_core_modules_names.hrl").
-include("../../ibot_db/include/ibot_db_records.hrl").
-include("ibot_core_project_statuses.hrl").
-include("../../ibot_events/include/ibot_events_handlers.hrl").
-include("../../ibot_nodes/include/ibot_nodes_registration_info.hrl").

%% API
-export([start_link/0]).
-export([
  start_distribute_db/0, %% start distributed db
  stop_distribute_db/0 %% stop distributed db
]).
-export([
  all_children_projects_start_distribute_db/0, %% start ditributes db on child cores
  all_children_projects_stop_distribute_db/0 %% stop ditributes db on child cores
]).
-export([
  connect_to_distribute_project/0, %% start core / main core managed all child cores
  connect_to_project/0, %% connect to project. read nodes config file.
  start_chiled_core/0, %% start child cores
  start_remote_node/1 %% start remote node
]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {}).


start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).


init([]) ->
  timer:apply_after(7000, ?IBOT_CORE_SRV_INTERACTION, connect_to_distribute_project, []),
  {ok, #state{}}.


handle_call({all_children_projects_start_distribute_db}, _From, State) ->
  rpc:multicall(ibot_db_srv_func_project:get_children_project_names_list(), ibot_core_srv_interaction, start_distribute_db, []),
  {reply, ok, State};

handle_call({all_children_projects_stop_distribute_db}, _From, State) ->
  rpc:multicall(ibot_db_srv_func_project:get_children_project_names_list(), ibot_core_srv_interaction, stop_distribute_db, []),
  {reply, ok, State};

handle_call({connect_to_project}, _From, State) ->
  ibot_core_app:connect_to_project(ibot_db_func_config:get_full_project_path()),  %% connect to project
  case ibot_db_srv_func_project:get_projectStatus() of                            %% if project status is RELEASE, start project nodes
    ?RELEASE ->
      ibot_core_app:start_project();
    _ -> ok
  end,
  {reply, ok, State};

handle_call({start_chiled_core}, _From, State) ->
  rpc:multicall(ibot_db_srv_func_project:get_children_project_names_list(), ibot_core_srv_interaction, connect_to_project, []),
  {reply, ok, State}.



handle_cast(_Request, State) ->
  {noreply, State}.


handle_info(_Info, State) ->
  {noreply, State}.


terminate(_Reason, _State) ->
  ok.


code_change(_OldVsn, State, _Extra) ->
  {ok, State}.


%%%===================================================================
%%% API functions
%%%===================================================================

%% start distributed database
start_distribute_db() ->
  ibot_db_srv:start_distibuted_db().

%% stop distributed database
stop_distribute_db() ->
  ibot_db_srv:stop_distributed_db().

%% connect to project. read nodes config file.
connect_to_project() ->
  gen_server:call(ibot_core_srv_interaction, {connect_to_project}).

%% start child cores
start_chiled_core() ->
  gen_server:call(ibot_core_srv_interaction, {start_chiled_core}).

%% start remote node
start_remote_node(NodeInfo) ->
  rpc:call(NodeInfo#node_info.atomServerFullName, ?IBOT_CORE_APP, start_node, NodeInfo).

%% start ditributes db on child cores
all_children_projects_start_distribute_db() ->
  gen_server:call(ibot_core_srv_interaction, {all_children_projects_start_distribute_db}).

%% stop ditributes db on child cores
all_children_projects_stop_distribute_db() ->
  gen_server:call(ibot_core_srv_interaction, {all_children_projects_stop_distribute_db}).

%% start core / main core managed all child cores
connect_to_distribute_project() ->
  case mnesia:stop() of %% stop distributed db / all cores do it itself
    _ ->
      mnesia:delete_schema([node()]), %% remove local mnesia schema
      case ibot_db_srv_func_project:get_project_config_info() of %% информация о конфигурации проекта
        record_not_found ->
          ok;

        ProjectInfo ->
          case ProjectInfo#project_info.mainProject of %% выполняется только для гланого ядра
            true ->
                  ibot_core_srv_connect:connect_to_distributed_projects(), %% подключение к распределенным проектам
                  ibot_db_srv:create_distributed_shema(), %% создание схем распределенной бд
                  ibot_core_srv_interaction:all_children_projects_start_distribute_db(), %% запуск распределенной бд на всех ядрах

                  %% todo start mnesia db on all connected cores

                  %% запускаем распределеннйю бд на глявном ядре /  start mnesia database
                  case mnesia:start() of
                    Res when Res == {error, {already_started, mnesia}}; Res == ok ->
                      ibot_db_srv:create_distributed_tables(), %% создание распределенных таблиц / create distribute database on all connected cores
                      ibot_core_srv_interaction:start_chiled_core(), %% запуск дочерних ядер / start to remote core nodes
                      ibot_core_srv_interaction:connect_to_project(); %% подключение к проекту / connect to project, read node config files

                    {error, Result} ->
                      ?DMI("connect_to_distribute_project ERROR", [Result])
                  end;

            _Other -> ok %% дочернее ядро
          end
      end,

      %% инициализация узла по отправке сообщений пользовательскому интерфейсу /  init ui interaction sending message #state record
      ibot_nodes_srv_ui_interaction:init_state()
  end,
  %% запускаем логгер записи сообщений в файл
  gen_event:add_handler(?EH_EVENT_LOGGER, ?IBOT_EVENTS_SRV_LOGGER, []).