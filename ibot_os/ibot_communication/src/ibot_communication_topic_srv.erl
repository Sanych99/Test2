%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. Март 2015 20:37
%%%-------------------------------------------------------------------
-module(ibot_communication_topic_srv).
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

-define(SERVER, ?MODULE).

-include("ibot_comm_commands.hrl").
-include("ibot_comm_records.hrl").

-record(state, {}).


start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).


init([]) ->
  {ok, #state{}}.


handle_call(_Request, _From, State) ->
  {reply, ok, State}.


handle_cast({?BROADCAST, TopicName, Message}, State) ->
  case ibot_communication_db_app:get_topic_nodes(TopicName) of
    [] -> ok;
    NodeInfoList -> message_broadcast(NodeInfoList, Message)
  end,
  {noreply, State};
handle_cast(_Request, State) ->
  {noreply, State}.


handle_info(_Info, State) ->
  {noreply, State}.


terminate(_Reason, _State) ->
  ok.


code_change(_OldVsn, State, _Extra) ->
  {ok, State}.


message_broadcast([], _) -> ok;
message_broadcast([NodeInfo | NodeInfoList], Msg) ->
  erlang:send({NodeInfo#node_info.nodeName, NodeInfo#node_info.serverName}, Msg),
  message_broadcast(NodeInfoList, Msg),
  ok.


