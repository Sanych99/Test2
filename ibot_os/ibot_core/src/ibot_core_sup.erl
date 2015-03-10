-module(ibot_core_sup).

-behaviour(supervisor).

-include("debug.hrl").

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
    DbChild = ?CHILD(ibot_core_db_srv, worker),
    ?DBG_INFO("start dbchild: ~p~n", [DbChild]),
    {ok, { {one_for_one, 5, 10}, [DbChild]} }.

