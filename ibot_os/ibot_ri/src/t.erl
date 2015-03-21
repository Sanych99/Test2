%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Mar 2015 12:05 AM
%%%-------------------------------------------------------------------
-module(t).
-author("alex").

%% API
-export([s/0, t/0]).

s() ->
  ibot_core_app:start(normal, []),
  ok.

t() ->
  ibot_ri_srv_distribute:cast_remote_node('core2@127.0.0.1', node(), callingNodeName, {message, "Hello!"}),
  ok.
