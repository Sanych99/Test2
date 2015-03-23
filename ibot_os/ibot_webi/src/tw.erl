%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. Mar 2015 11:32 PM
%%%-------------------------------------------------------------------
-module(tw).
-author("alex").

%% API
-export([t/0]).

t() ->
  application:start(crypto),
  application:start(ranch),
  application:start(cowboy),
  application:start(webserver),
  ok.