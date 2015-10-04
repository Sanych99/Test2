-module(ibot_events_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

-include("ibot_events_handlers.hrl").

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    ibot_events_sup:start_link().

stop(_State) ->
  %% останавливаем event handler логирования
  gen_event:stop(?EH_EVENT_LOGGER),
  ok.


