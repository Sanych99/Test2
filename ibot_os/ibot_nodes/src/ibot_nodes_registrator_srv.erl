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

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Запуск регистратора узлов
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Инициализация рагистратора узлов
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
  {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term()} | ignore).
init([]) ->
  % Создание ETS таблицы для хранения данных об узлах
  ets:new(?NODE_REGISTRATOR_DB, [named_table]),
  {ok, #state{}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Синхронная обработка запросов сервера
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #state{}) ->
  {reply, Reply :: term(), NewState :: #state{}} |
  {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_call({?GET_NODE_INFO, NodeName}, _From, State) ->
  case ets:lookup(?NODE_REGISTRATOR_DB, NodeName) of
    [] ->
      {reply, {?RESPONSE, ?NO_NODE_INFO}, State};
    NodeInfo ->
      {reply, {?RESPONSE, NodeInfo}, State}
  end;
handle_call(_Request, _From, State) ->
  {reply, ok, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_cast(Request :: term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_cast(_Request, State) ->
  {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Обработка закпросов регистрации узлов
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
-spec(handle_info(Info :: timeout() | term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
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

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Завершение работы регистратора узлов
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #state{}) -> term()).
terminate(_Reason, _State) ->
  % Удаление ETS таблицы
  ets:delete(?NODE_REGISTRATOR_DB),
  ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Метод вызываемы при замене кода модуля
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
    Extra :: term()) ->
  {ok, NewState :: #state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
