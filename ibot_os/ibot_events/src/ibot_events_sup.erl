-module(ibot_events_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).
-define(CHILD_PARAMS(I, Type, Param), {I, {I, start_link, [Param]}, permanent, 5000, Type, [I]}).

-include("ibot_events_handlers.hrl").

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->

  %% Event Manager Child
  EvenManager = ?CHILD_PARAMS(gen_event, worker, {local, ?EH_EVENT_LOGGER}),
  %% Event Manager Nodes Interaction
  EvenManagerNodesInteraction = ?CHILD(?IBOT_EVENTS_SRV_NODE_INTERACTION, worker),
  {ok, { {one_for_one, 5, 10}, [EvenManager, EvenManagerNodesInteraction]} }.

