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

-include("debug.hrl").
-include("tables_names.hrl").
-include("nodes_registration_info.hrl").

-define(SERVER, ?MODULE).
-define(EXTNODE, external_node).

-record(state, {}).


start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).


init([]) ->
  % Создание ETS таблицы для хранения данных об узлах
  ets:new(?NODE_REGISTRATOR_DB, [named_table]),
  {ok, #state{}}.


handle_call({?GET_NODE_INFO, NodeName}, _From, State) ->
  case ets:lookup(?NODE_REGISTRATOR_DB, NodeName) of
    [] ->
      {reply, {?RESPONSE, ?NO_NODE_INFO}, State};
    NodeInfo ->
      {reply, {?RESPONSE, NodeInfo}, State}
  end;
handle_call(_Request, _From, State) ->
  {reply, ok, State}.


handle_cast(_Request, State) ->
  {noreply, State}.


handle_info(_Info, State) ->
  case _Info of
    {?EXTNODE, Parameters} ->
      ?DBG_INFO("Module: ~p -> Messafe from node: ~p~n", [?MODULE, {_Info}]),
      % Регистрационные данные узла
      {NodeName, NodeServer, NodeNameServer, NodeLang, NodeExecutable, NodePreArguments, NodePostArguments} = Parameters,
      % Добавляем двнне об узле в таблицу
      ets:insert(?NODE_REGISTRATOR_DB,
        {NodeName, #node_info{nodeName = NodeName, nodeServer = NodeServer, nodeNameServer = NodeNameServer,
          nodeLang = NodeLang, nodeExecutable = NodeExecutable,
          nodePreArguments = NodePreArguments, nodePostArguments = NodePostArguments}}),
      ok;
    _ ->
      ?DBG_INFO("Module: ~p -> Unknow message: ~p~n", [?MODULE, {_Info}]),
      ok
  end,
  {noreply, State}.


terminate(_Reason, _State) ->
  % Удаление ETS таблицы
  ets:delete(?NODE_REGISTRATOR_DB),
  ok.


code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
