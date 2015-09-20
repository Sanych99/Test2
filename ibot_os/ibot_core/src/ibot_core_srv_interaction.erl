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

%% API
-export([start_link/0]).
-export([
  start_distribute_db/0, %% запуск распределенной бд
  stop_distribute_db/0 %% остановка распределенной бд
]).
-export([
  all_children_projects_start_distribute_db/0, %% запуск распределенной бд на дочерних ядрах
  all_children_projects_stop_distribute_db/0 %% остановка расчпределенной бд на дочерних ядрах
]).
-export([
  connect_to_distribute_project/0, %% поздключение к дочерним ядрам
  connect_to_project/0, %% подключение к проекту
  start_chiled_core/0 %% запуск дочернего ядра
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
  %?DBG_MODULE_INFO("init([]) -> after 7 seconds..............", [?MODULE]),
  {ok, #state{}}.


handle_call(_Request, _From, State) ->
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
%%% Internal functions
%%%===================================================================

%% @doc
%% Запуск распределенной БД
%% @end
start_distribute_db() ->
  ibot_db_srv:start_distibuted_db().

%% @doc
%% Остановка распределенной БД
%% @end
stop_distribute_db() ->
  ibot_db_srv:stop_distributed_db().


%% @doc
%% Connect to project. Read nodes config file.
%% @spec connect_to_project() -> ok.
%% @end
-spec connect_to_project() -> ok.

connect_to_project() ->
  %% connect to project
  ibot_core_app:connect_to_project(ibot_db_func_config:get_full_project_path()),
  %% if project status is RELEASE, start project nodes
  case ibot_db_srv_func_project:get_projectStatus() of
    ?RELEASE ->
      ibot_core_app:start_project();
    _ -> ok
  end.

%% @doc
%% Запуск дочерних ядер
%% @end
start_chiled_core() ->
  rpc:multicall(ibot_db_srv_func_project:get_children_project_names_list(), ibot_core_srv_interaction, connect_to_project, []).


%% @doc
%% Запуск распределенной бд на дочерних ядрах
%% @end
all_children_projects_start_distribute_db() ->
  rpc:multicall(ibot_db_srv_func_project:get_children_project_names_list(), ibot_core_srv_interaction, start_distribute_db, []).


%% @doc
%% Остановка распределенной бд на дочерних ядрах
%% @end
all_children_projects_stop_distribute_db() ->
  rpc:multicall(ibot_db_srv_func_project:get_children_project_names_list(), ibot_core_srv_interaction, stop_distribute_db, []).

%% @doc
%% Запуск ядра и управление дочерними для главного
%% @end
connect_to_distribute_project() ->
  case mnesia:stop() of %% остановка распределенной бд / выполняемтся всем ядрами
    _ ->
      mnesia:delete_schema([node()]), % Удаляем все локальные схемы с распределенной бд / Remove local mnesia schema
      case ibot_db_srv_func_project:get_project_config_info() of %% информация о конфигурации проекта
        record_not_found -> %% запись не найдена
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
  end.

