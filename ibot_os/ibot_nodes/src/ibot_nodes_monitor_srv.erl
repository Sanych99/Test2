%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. Март 2015 12:22
%%%-------------------------------------------------------------------
-module(ibot_nodes_monitor_srv).
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

-include("ibot_nodes_modules.hrl").
-include("ibot_comm_commands.hrl").

-record(state, {nodeName :: atom()}).


start_link(NodeName) ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [NodeName], []). %% Запусе наблюдателя за узлом, передаем имя узла


init([NodeName]) ->
  process_flag(trap_exit, true), %% Прием сообщени о завершении работы узла
  erlang:monitor(NodeName, true), %% Устанавливаем мониторинг за узлом
  {ok, #state{nodeName = NodeName}}.


handle_call(_Request, _From, State) ->
  {reply, ok, State}.


handle_cast(_Request, State) ->
  {noreply, State}.


handle_info({nodedown, _JavaNode}, State = #state{nodeName = NodeName}) ->
  gen_server:call(?IBOT_NODES_CONNECTOR, {?RESTART_NODE, NodeName}), %% Рестарт упавшего узла
  {noreply, State};
handle_info(_Info, State) ->
  {noreply, State}.


terminate(_Reason, _State) ->
  ok.


code_change(_OldVsn, State, _Extra) ->
  {ok, State}.