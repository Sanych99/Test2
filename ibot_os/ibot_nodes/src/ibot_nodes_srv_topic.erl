%%%-------------------------------------------------------------------
%%% @author Tsaregorodtsev Alexandr
%%% @copyright (C) 2015
%%% @doc
%%%
%%% Communication between nodes by pusblish and subscribe to topic
%%% @end
%%% Created : 10. Март 2015 20:37
%%%-------------------------------------------------------------------
-module(ibot_nodes_srv_topic).

-behaviour(gen_server).

-export([start_link/0]).

-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).
-define(REG_SUBSCR, reg_subscr).

-include("debug.hrl").
-include("ibot_comm_commands.hrl").
-include("../../ibot_db/include/ibot_db_records.hrl").

-record(state, {}).


start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).


init([]) ->
  {ok, #state{}}.


handle_call(_Request, _From, State) ->
  {reply, ok, State}.


%% ====== handle_cast function start ======

%% @doc
%%
%% Broadcast message to subscribers
%% @end

handle_cast({?BROADCAST, TopicName, Message}, State) ->
  case ibot_db_func_topics:get_topic_nodes(TopicName) of
    [] -> ok;
    NodeInfoList ->
      spawn(fun() -> message_broadcast(NodeInfoList, Message) end)
  end,
  {noreply, State};
handle_cast(_Request, State) ->
  {noreply, State}.

%% ====== handle_cast function end ======



%% ====== handle_info function start ======

%% @doc
%%
%% Subscribe node to topic
%% @end

handle_info({?REG_SUBSCR, MBoxName, NodeServerName, TopicName}, State) -> ?DBG_INFO("ibot_nodes_comm_topic_srv:handle_info -> ~p~n", [[?REG_SUBSCR, MBoxName, NodeServerName, TopicName]]),
  ibot_db_func_topics:add_node_to_topic(TopicName, MBoxName, NodeServerName), %% Add subscribe node info
  {noreply, State};
handle_info(_Info, State) -> ?DBG_INFO("ibot_nodes_comm_topic_srv:handle_info Not handle...~p~n", [_Info]),
  {noreply, State}.

%% ====== handle_info function end ======




terminate(_Reason, _State) ->
  ok.


code_change(_OldVsn, State, _Extra) ->
  {ok, State}.


%%==================================
%% API functions
%%==================================



%%==================================
%% Internal usage functions
%%==================================


%% ====== message_broadcast function start ======

%% @doc
%%
%% Broadcast message function
%% @end

message_broadcast([], _) -> ok;
message_broadcast([NodeInfo | NodeInfoList], Msg) ->
  erlang:send({NodeInfo#node_pubsub_info.nodeName, NodeInfo#node_pubsub_info.serverName}, Msg),
  message_broadcast(NodeInfoList, Msg),
  ok.

%% ====== message_broadcast function start ======


