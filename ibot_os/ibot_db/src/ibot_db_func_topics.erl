%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright iBot Robotics
%%% @doc
%%% Методы управления информацие о подписчиках (узлах) на топик
%%% @end
%%% Created : 18. Mar 2015 2:20 AM
%%%-------------------------------------------------------------------
-module(ibot_db_func_topics).
-author("alex").

%% API
-export([
  add_node_to_topic/3, %% добавить узел как подписчика на топик
  get_topic_nodes/1  %% получить списко узлов подписанных на топик
]).

-include("../../ibot_core/include/debug.hrl").
-include("ibot_db_table_names.hrl").
-include("ibot_db_records.hrl").
-include("ibot_db_table_commands.hrl").
-include("ibot_db_modules.hrl").

%%============================
%% API finctions
%%============================

%% @doc
%% Добавить узел как подписчика на топик / Add node as subscriber to topic
%% @end
add_node_to_topic(TopicName, NodeName, ServerName) -> ?DBG_INFO("add_node_to_topic -> ~p~n", [[TopicName, NodeName, ServerName]]),
  ?DMI("add_node_to_topic", {TopicName, NodeName, ServerName}),
  case ibot_db_func:get_from_mnesia(topic_info, TopicName) of
    not_found ->
      %% запись не найдена, создаем новую
      ibot_db_func:add_to_mnesia(#topic_info{id = TopicName, subscribeNodes = [#node_pubsub_info{nodeMBoxName = NodeName, nodeServerName = ServerName}]});

    TopicInfo ->
      %% добавляем новый узел к подписчикам на топик, исключаем дублирование
      SubscribeNodeInfo = #node_pubsub_info{nodeMBoxName = NodeName, nodeServerName = ServerName},%% new subscribe node info
      DeleteExistFromTopicInfo = lists:delete(SubscribeNodeInfo, TopicInfo#topic_info.subscribeNodes), %% remove old node info if exist
      ibot_db_func:add_to_mnesia(#topic_info{id = TopicName, subscribeNodes = [SubscribeNodeInfo
         | DeleteExistFromTopicInfo]})
  end.


%% @doc
%% Получить подписанные на топик узлы / Get subscribed nodes to topic
%% @end
get_topic_nodes(TopicName) ->
  ?DMI("get_topic_nodes", TopicName),
  case ibot_db_func:get_from_mnesia(topic_info, TopicName) of
    not_found ->
      ?DMI("get_topic_nodes", "row not found"),
      [];
    TopicInfo ->
      ?DMI("get_topic_nodes row found", TopicInfo#topic_info.subscribeNodes),
      TopicInfo#topic_info.subscribeNodes
  end.