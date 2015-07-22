
-module(ibot_db_sup).

-behaviour(supervisor).

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
    IBOT_DB_SRV = ?CHILD(ibot_db_srv, worker), %% Run ibot_db_srv server
    IBOT_DB_SRV_FUNC_PROJECT = ?CHILD(ibot_db_srv_func_project, worker), %% Run ibot_db_srv server
    IBOT_DB_SRV_FUNC_NODES = ?CHILD(ibot_db_srv_func_nodes, worker), %% Run ibot_db_srv server
    {ok, { {one_for_one, 5, 10}, [IBOT_DB_SRV, IBOT_DB_SRV_FUNC_PROJECT, IBOT_DB_SRV_FUNC_NODES]} }.

