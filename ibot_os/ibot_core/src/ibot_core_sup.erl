-module(ibot_core_sup).

-behaviour(supervisor).

-include("debug.hrl").
-include("ibot_core_modules_names.hrl").

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    IBOT_CORE_SRV_PIL = ?CHILD(?IBOT_CORE_SRV_PROJECT_INFO_LOADER, worker),
    IBOT_CORE_COMPILE_NODES = ?CHILD(?IBOT_CORE_SRV_COMPILE_NODES, worker),
    {ok, { {one_for_one, 5, 10}, [IBOT_CORE_SRV_PIL, IBOT_CORE_COMPILE_NODES]} }.

