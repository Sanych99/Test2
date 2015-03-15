%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. Март 2015 19:57
%%%-------------------------------------------------------------------
-module(ibot_nodes_comm_db_srv).

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

-export([add_node_to_topic/3, get_topic_nodes/1]).

-define(SERVER, ?MODULE).

-include("debug.hrl").
-include("ibot_comm_tables.hrl").
-include("ibot_comm_records.hrl").
-include("../../ibot_db/include/ibot_db_table_commands.hrl").
-include("../../ibot_db/include/ibot_db_modules.hrl").

-record(state, {}).


start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []). %% Start server


init([]) ->
  ibot_db_func:create_db(?TABLE_TOPICS), %% Create topics table
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


%%============================
%% API finctions
%%============================

add_node_to_topic(TopicName, NodeName, ServerName) -> ?DBG_INFO("add_node_to_topic -> ~p~n", [[TopicName, NodeName, ServerName]]),
  case gen_server:call(?IBOT_DB_SRV, {?GET_RECORD, ?TABLE_TOPICS, TopicName}) of
    {ok, TopicInfo} -> ?DBG_INFO("add_node_to_topic find -> ~p~n", [{TopicName, TopicInfo}]),
      gen_server:call(?IBOT_DB_SRV, {?ADD_RECORD, ?TABLE_TOPICS, TopicName,
        #topic_info{subscribeNodes = [#node_pubsub_info{nodeName = NodeName, serverName = ServerName}
          | TopicInfo#topic_info.subscribeNodes]}});

    Vals -> ?DBG_INFO("add_node_to_topic topic ~p not found...~n", [TopicName]),  ?DBG_INFO("add_node_to_topic format ~p ...~n", [Vals]),
      gen_server:call(?IBOT_DB_SRV, {?ADD_RECORD, ?TABLE_TOPICS, TopicName,
      #topic_info{subscribeNodes = [#node_pubsub_info{nodeName = NodeName, serverName = ServerName}]}})
  end.

get_topic_nodes(TopicName) ->
  case gen_server:call(?IBOT_DB_SRV, {?GET_RECORD, ?TABLE_TOPICS, TopicName}) of
    {ok, {topic_info, Topicinfo}} ->  ?DBG_MODULE_INFO("get_topic_nodes Topicinfo: ~p~n", [?MODULE, Topicinfo]),
      Topicinfo;
    [] -> ?DBG_MODULE_INFO("get_topic_nodes [] ~n", [?MODULE]),
      ok;
    Vals -> ?DBG_MODULE_INFO("get_topic_nodes Vals: ~p~n", [?MODULE, Vals]),
      ok
  end.
