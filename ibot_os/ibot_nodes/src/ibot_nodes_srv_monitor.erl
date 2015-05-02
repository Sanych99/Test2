%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. Март 2015 12:22
%%%-------------------------------------------------------------------
-module(ibot_nodes_srv_monitor).
-author("alex").

-behaviour(gen_server).

%% API
-export([start_link/1]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-include("../../ibot_core/include/debug.hrl").
-include("ibot_nodes_modules.hrl").
-include("ibot_comm_commands.hrl").

-record(state, {nodeNameString :: string(), nodeName :: atom(), nodeServer :: atom(), nodeNameAndServer :: atom()}).


%start_link(NodeName) -> ?DBG_MODULE_INFO("start link node name:~p~n", [?MODULE, NodeName]),
%  gen_server:start_link({local, 'bar_monitor'}, ?MODULE, [NodeName], []). %% Запусе наблюдателя за узлом, передаем имя узла


start_link({NodeNameString, NodeNameAtom, NodeServerAtom, NodeNameAndServerAtom}) -> ?DBG_MODULE_INFO("start link node name:~p~n", [?MODULE, {NodeNameString, NodeNameAtom, NodeServerAtom, NodeNameAndServerAtom}]),
  gen_server:start_link({local, list_to_atom(string:join([NodeNameString, "monitor"], "_"))}, ?MODULE, [{NodeNameString, NodeNameAtom, NodeServerAtom, NodeNameAndServerAtom}], []). %% Запусе наблюдателя за узлом, передаем имя узла

%init([{NodeNameAtom, NodeServerAtom, NodeNameAndServerAtom}]) -> ?DBG_MODULE_INFO("init node name:~p~n", [?MODULE, {NodeNameAtom, NodeServerAtom}]),
%  process_flag(trap_exit, true), %% Прием сообщени о завершении работы узла
%  true = erlang:monitor_node('BLA_BLA_BLA@alex-N550JK', true), %% Устанавливаем мониторинг за узлом
%  {ok, #state{nodeName = NodeNameAtom, nodeServer = NodeServerAtom, nodeNameAndServer = NodeNameAndServerAtom}}.


init([{NodeNameString, NodeNameAtom, NodeServerAtom, NodeNameAndServerAtom}]) -> ?DBG_MODULE_INFO("init node name:~p~n", [?MODULE, {NodeNameAtom, NodeServerAtom}]),
  process_flag(trap_exit, true), %% Прием сообщени о завершении работы узла
  true = erlang:monitor_node(NodeNameAndServerAtom, true), %% Устанавливаем мониторинг за узлом
  {ok, #state{nodeNameString = NodeNameString, nodeName = NodeNameAtom, nodeServer = NodeServerAtom, nodeNameAndServer = NodeNameAndServerAtom}}.


handle_call(stop,  _From, State) ->
  {stop, normal, shutdown_ok, State};
handle_call(_Request, _From, State) ->
  {reply, ok, State}.

handle_cast(stop, State) ->
  {stop, normal, State};
handle_cast(_Request, State) ->
  {noreply, State}.




handle_info({nodedown, _ExternalNodeNode}, State = #state{nodeName = NodeName}) -> ?DBG_MODULE_INFO("handle_info {nodedown, _JavaNode}:~p node Name ~p~n", [?MODULE, {nodedown, _ExternalNodeNode}, NodeName]),
  gen_server:call(?IBOT_NODES_SRV_CONNECTOR, {?RESTART_NODE, NodeName}), %% Рестарт упавшего узла
  {stop, normal, State};

handle_info({'EXIT',_Info, P1, P2}, State = #state{nodeName = NodeName}) -> ?DBG_MODULE_INFO("handle_info {'EXIT',_Info, P1, P2}:~p~n", [?MODULE, {'EXIT',_Info, P1, P2}]),
  gen_server:call(?IBOT_NODES_SRV_CONNECTOR, {?RESTART_NODE, NodeName}), %% Рестарт упавшего узла
  {noreply, State};

handle_info(_Info, State) -> ?DBG_MODULE_INFO("handle_info _Info:~p~n", [?MODULE, _Info]),
  {noreply, State}.



terminate(_Reason, _State) ->
  ok.


code_change(_OldVsn, State, _Extra) ->
  {ok, State}.