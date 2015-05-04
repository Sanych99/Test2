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
  %case gen_server:call(?IBOT_DB_SRV, {?GET_RECORD, ?TABLE_TOPICS, TopicName}) of
  ?DBG_MODULE_INFO("ibot_db_func:get_from_mnesia(topic_info, TopicName): ~p~n", [?MODULE, ibot_db_func:get_from_mnesia(topic_info, TopicName)]),
  case ibot_db_func:get_from_mnesia(topic_info, TopicName) of
    not_found -> %?DBG_INFO("add_node_to_topic topic ~p not found...~n", [TopicName]),  ?DBG_INFO("add_node_to_topic format ~p ...~n", [Vals]),
      %gen_server:call(?IBOT_DB_SRV, {?ADD_RECORD, ?TABLE_TOPICS, TopicName,
      %  #topic_info{subscribeNodes = [#node_pubsub_info{nodeMBoxName = NodeName, nodeServerName = ServerName}]}})
      ibot_db_func:add_to_mnesia(#topic_info{id = TopicName, subscribeNodes = [#node_pubsub_info{nodeMBoxName = NodeName, nodeServerName = ServerName}]});

    TopicInfo -> ?DBG_INFO("add_node_to_topic find -> ~p~n", [{TopicName, TopicInfo}]),
      SubscribeNodeInfo = #node_pubsub_info{nodeMBoxName = NodeName, nodeServerName = ServerName},%% new subscribe node info
      DeleteExistFromTopicInfo = lists:delete(SubscribeNodeInfo, TopicInfo#topic_info.subscribeNodes), %% remove old node info if exist
      %gen_server:call(?IBOT_DB_SRV, {?ADD_RECORD, ?TABLE_TOPICS, TopicName,
      %  #topic_info{id = TopicName, subscribeNodes = [SubscribeNodeInfo
      %    | DeleteExistFromTopicInfo]}});
      ibot_db_func:add_to_mnesia(#topic_info{id = TopicName, subscribeNodes = [SubscribeNodeInfo
         | DeleteExistFromTopicInfo]})
  end.

get_topic_nodes(TopicName) ->
  %case gen_server:call(?IBOT_DB_SRV, {?GET_RECORD, ?TABLE_TOPICS, TopicName}) of
  ?DBG_MODULE_INFO("ibot_db_func:get_from_mnesia(topic_info, TopicName): ~p~n", [?MODULE, ibot_db_func:get_from_mnesia(topic_info, TopicName)]),
  case ibot_db_func:get_from_mnesia(topic_info, TopicName) of
    %{ok, {topic_info, Topicinfo}} ->  ?DBG_MODULE_INFO("get_topic_nodes Topicinfo: ~p~n", [?MODULE, Topicinfo]),
    not_found -> [];
    TopicInfo -> ?DBG_MODULE_INFO("get_topic_nodes Topicinfo: ~p~n", [?MODULE, TopicInfo#topic_info.subscribeNodes]),
      TopicInfo#topic_info.subscribeNodes;
    [] -> ?DBG_MODULE_INFO("get_topic_nodes [] ~n", [?MODULE]),
      [];
    Vals -> ?DBG_MODULE_INFO("get_topic_nodes Vals: ~p~n", [?MODULE, Vals]),
      []
  end.