%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. Mar 2015 2:24 AM
%%%-------------------------------------------------------------------
-record(node_pubsub_info, {nodeMBoxName :: atom(), nodeServerName :: atom()}).
-record(topic_info, {subscribeNodes = [] :: list()}).
