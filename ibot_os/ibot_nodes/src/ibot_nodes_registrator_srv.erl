%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015
%%% @doc
%%% Регистратор внешних узлов на языках (C/C++, Python, Java)
%%% Принимает информацию от узлов после их запуска
%%% Предоставляем информацию о небходимом узле по запросу
%%% @end
%%% Created : 22. Февр. 2015 17:54
%%%-------------------------------------------------------------------
-module(ibot_nodes_registrator_srv).

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

-export([add_node_info/2, get_node_info/1]).

-include("../../ibot_core/include/debug.hrl").
-include("tables_names.hrl").
-include("nodes_registration_info.hrl").

-define(SERVER, ?MODULE).
-define(EXTNODE, external_node).
-define(REG_INFO, reg_info).

-record(state, {}).


start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).


init([]) ->
  % Создание ETS таблицы для хранения данных об узлах
  ibot_db_func:create_db(?NODE_REGISTRATOR_DB),
  {ok, #state{}}.


handle_call({?GET_NODE_INFO, NodeName}, _From, State) ->
  case get_node_info(NodeName) of
    [] ->
      {reply, {?RESPONSE, ?NO_NODE_INFO}, State};
    NodeInfo ->
      {reply, {?RESPONSE, NodeInfo}, State}
  end;
handle_call(_Request, _From, State) ->
  {reply, ok, State}.


handle_cast(_Request, State) ->
  {noreply, State}.




handle_info({?REG_INFO, MBoxName, NodeServerName}, State) ->
  {noreply, State};

handle_info({?EXTNODE, Parameters}, State) ->
      ?DBG_MODULE_INFO("message from node: ~p~n", [?MODULE, {?EXTNODE, Parameters}]),
      % Регистрационные данные узла
      {NodeName, NodeServer, NodeNameServer, NodeLang, NodeExecutable, NodePreArguments, NodePostArguments} = Parameters,
      % Добавляем дaнне об узле в таблицу
      add_node_info(NodeName, #node_info{nodeName = NodeName, nodeServer = NodeServer, nodeNameServer = NodeNameServer,
        nodeLang = NodeLang, nodeExecutable = NodeExecutable,
        nodePreArguments = NodePreArguments, nodePostArguments = NodePostArguments}),
  {noreply, State};

handle_info(_Info, State) ->
  ?DBG_MODULE_INFO("unknow message: ~p~n", [?MODULE, {_Info}]),
  {noreply, State}.


terminate(_Reason, _State) ->
  % Удаление ETS таблицы
  ets:delete(?NODE_REGISTRATOR_DB),
  ok.


code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% API functions
%%%===================================================================

get_node_info(NodeName) ->
  ibot_db_srv:get_record(?NODE_REGISTRATOR_DB, NodeName).

add_node_info(Key, Val) ->
  ibot_db_srv:add_record(?NODE_REGISTRATOR_DB, Key, Val).