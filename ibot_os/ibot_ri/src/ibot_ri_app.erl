%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015
%%% @doc
%%% Remote nodes interaction. Distributed nodes interaction.
%%% @end
%%% Created : 22. Февр. 2015 21:43
%%%-------------------------------------------------------------------

-module(ibot_ri_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    ibot_ri_sup:start_link().

stop(_State) ->
    ok.
