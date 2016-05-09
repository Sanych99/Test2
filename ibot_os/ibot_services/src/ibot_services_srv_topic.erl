%%%-------------------------------------------------------------------
%%% @author Tsaregorodtsev Alexandr
%%% @copyright (C) 2015
%%% @doc
%%%
%%% Communication between nodes by pusblish and subscribe to topic
%%% @end
%%% Created : 10. Март 2015 20:37
%%%-------------------------------------------------------------------
-module(ibot_services_srv_topic).

-behaviour(gen_server).

-export([start_link/0]).

-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-export([broadcats_message/2]).

-define(SERVER, ?MODULE).
-define(REG_SUBSCR, reg_subscr).

-include("../../ibot_core/include/debug.hrl").
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
%% Отправляем сообщение всем подписчикам / Broadcast message to subscribers
%% @end

handle_cast({?BROADCAST, TopicName, Message}, State) ->
  case ibot_db_func_topics:get_topic_nodes(TopicName) of %% поисе данных о подписчиках в бд
    [] -> ok; %% данных о подписчиках нет
    NodeInfoList -> %% оправляем сообщение всем подписчикам
      spawn(fun() -> message_broadcast(NodeInfoList, Message, TopicName) end)
  end,
  {noreply, State};
handle_cast(_Request, State) ->
  {noreply, State}.

%% ====== handle_cast function end ======



%% ====== handle_info function start ======

%% @doc
%% Подписка узла на сообщения / Subscribe node to topic
%% @spec handle_info({?REG_SUBSCR, MBoxName, NodeServerName, TopicName}, State) -> {noreply, State}
%% when MBoxName :: atom(), NodeServerName :: atom(), TopicName :: atom().
%% @end

handle_info({?REG_SUBSCR, MBoxName, NodeServerName, TopicName}, State) -> ?DBG_INFO("ibot_nodes_comm_topic_srv:handle_info -> ~p~n", [[?REG_SUBSCR, MBoxName, NodeServerName, TopicName]]),
  ?DBG_MODULE_INFO("handle_info({?REG_SUBSCR, MBoxName, NodeServerName, TopicName}, State): ~p~n", [?MODULE, {?REG_SUBSCR, MBoxName, NodeServerName, TopicName}]),
  ibot_db_func_topics:add_node_to_topic(TopicName, MBoxName, NodeServerName), %% Add subscribe node info
  {noreply, State};


%% @doc
%% Отправляем сообщение всем подписчикам / Broadcast message to subscribers
%% @spec handle_info({?BROADCAST, MBoxName, NodeServerName, TopicName, Message}, State) ->-> {noreply, State}
%% when MBoxName :: atom(), NodeServerName :: atom(), TopicName :: atom(), Message :: tuple().
%% @end

handle_info({?BROADCAST, MBoxName, NodeServerName, TopicName, Message}, State) ->
  ?DMI("handle_info", {?BROADCAST, MBoxName, NodeServerName, TopicName, Message}),
  case ibot_db_func_topics:get_topic_nodes(TopicName) of
    [] -> ok; %% данных о подписчиках нет
    NodeInfoList -> %% оправляем сообщение всем подписчикам
      spawn(fun() -> message_broadcast(NodeInfoList, Message, TopicName) end)
  end,
  {noreply, State};
handle_info(_Info, State) -> ?DMI("handle_info Info:", _Info),
  {noreply, State}.

%% ====== handle_info function end ======




terminate(_Reason, _State) ->
  ok.


code_change(_OldVsn, State, _Extra) ->
  {ok, State}.


%%==================================
%% API functions
%%==================================


%% @doc
%% API метод Отправляем сообщение подписчикам
%% @end
broadcats_message(TopicName, Msg) ->
  ?DBG_MODULE_INFO("broadcats_message(TopicName, Msg) -> ~p~n...", [?MODULE, {TopicName, Msg}]),
  gen_server:cast(?MODULE, {?BROADCAST, TopicName, Msg}).



%%==================================
%% Internal usage functions
%%==================================


%% ====== message_broadcast function start ======

%% @doc
%% Отправка сообения подписчикам / Broadcast message function
%% @end

message_broadcast([], _, _) -> %% сообщение отправлено всем подписчикам
  ?DMI("message_broadcast", "End function"),
  ok;
message_broadcast([NodeInfo | NodeInfoList], Msg, TopicName) ->
  ?DMI("message_broadcast", {{NodeInfo#node_pubsub_info.nodeMBoxName, NodeInfo#node_pubsub_info.nodeServerName}, {?SUBSRIBE, TopicName, Msg}}),
  %% отправляем сообщение узлу
  spawn(fun() -> erlang:send({NodeInfo#node_pubsub_info.nodeMBoxName, NodeInfo#node_pubsub_info.nodeServerName}, {?SUBSRIBE, TopicName, Msg}) end) ,
  %% следующая итерация по отправке сообщения
  message_broadcast(NodeInfoList, Msg, TopicName),
  ok.

%% ====== message_broadcast function start ======


