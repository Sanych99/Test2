%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. Mar 2015 2:20 AM
%%%-------------------------------------------------------------------
-module(ibot_db_func_topics).
-author("alex").

%% API
-export([add_node_to_topic/3, get_topic_nodes/1]).

-include("../../ibot_core/include/debug.hrl").
-include("ibot_db_table_names.hrl").
-include("ibot_db_records.hrl").
-include("ibot_db_table_commands.hrl").
-include("ibot_db_modules.hrl").

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