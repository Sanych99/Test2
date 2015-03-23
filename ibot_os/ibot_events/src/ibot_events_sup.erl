-module(ibot_events_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).
-define(CHILD_PARAMS(I, Type, Param), {I, {I, start_link, [Param]}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
  %%{ok, Pid} = gen_event:start_link("my_event_bus"),
  %{ok, Pid} = gen_server:start_link({local, test1}, test, [], []),
  %io:format("~p~n", [Pid]),
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    % Event Manager Child
    EvenManager = ?CHILD_PARAMS(gen_event, worker, gen_event),
    {ok, { {one_for_one, 5, 10}, [EvenManager]} }.

