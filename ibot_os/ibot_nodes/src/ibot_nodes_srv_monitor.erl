%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%% Monitoring nodes
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

-record(state, {
  nodeNameString :: string(), %% node name
  nodeName :: atom(), %% node name as Atom
  nodeServer :: atom(), %% node host name
  nodeNameAndServer :: atom()
}).

%% start new monitor process
start_link({NodeNameString, NodeNameAtom, NodeServerAtom, NodeNameAndServerAtom}) ->
  ?DMI("start monitor", NodeNameString),
  %% Запусе наблюдателя за узлом, передаем имя узла
  gen_server:start_link({local, list_to_atom(string:join([NodeNameString, "monitor"], "_"))}, ?MODULE, [{NodeNameString, NodeNameAtom, NodeServerAtom, NodeNameAndServerAtom}], []).


init([{NodeNameString, NodeNameAtom, NodeServerAtom, NodeNameAndServerAtom}]) ->
  ?DMI("init node monitor", ?ONLY_MESSAGE),
  process_flag(trap_exit, true), %% Прием сообщени о завершении работы узла
  true = erlang:monitor_node(NodeNameAndServerAtom, true), %% Устанавливаем мониторинг за узлом
  {ok, #state{nodeNameString = NodeNameString, nodeName = NodeNameAtom, nodeServer = NodeServerAtom, nodeNameAndServer = NodeNameAndServerAtom}}.

%% stop monitor
handle_call(stop,  _From, State) ->
  {stop, normal, shutdown_ok, State};
handle_call(_Request, _From, State) ->
  {reply, ok, State}.

%% stop monitor
handle_cast(stop, State) ->
  {stop, normal, State};
handle_cast(_Request, State) ->
  {noreply, State}.



%% node down message
handle_info({nodedown, _ExternalNodeNode}, State = #state{nodeName = NodeName, nodeNameString = NodeNameString}) ->
  ?DMI("nodedown:", NodeName),
  gen_server:cast(?IBOT_NODES_SRV_CONNECTOR, {?RESTART_NODE, NodeName}), %% Рестарт упавшего узла
  %ibot_nodes_sup:stop_child_monitor(list_to_atom(string:join([NodeNameString, "monitor"], "_"))),
  {noreply, State};

%% node EXIT message
handle_info({'EXIT',_Info, P1, P2}, State = #state{nodeName = NodeName, nodeNameString = NodeNameString}) ->
  ?DMI("EXIT", NodeName),
  gen_server:cast(?IBOT_NODES_SRV_CONNECTOR, {?RESTART_NODE, NodeName}), %% Рестарт упавшего узла
  %ibot_nodes_sup:stop_child_monitor(list_to_atom(string:join([NodeNameString, "monitor"], "_"))),
  {noreply, State};

handle_info(_Info, State) -> ?DBG_MODULE_INFO("handle_info _Info:~p~n", [?MODULE, _Info]),
  {noreply, State}.



terminate(_Reason, _State) ->

  ok.


code_change(_OldVsn, State, _Extra) ->
  {ok, State}.