%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. Март 2015 20:06
%%%-------------------------------------------------------------------

-record(node_pubsub_info, {nodeName :: atom(), serverName :: atom()}).
-record(topic_info, {subscribeNodes = [] :: list()}).
