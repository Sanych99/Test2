%% ==============================
%% @doc Приложение управления внешними узлами
%% спроектированными разрабочками на языках (C/C++, Python, Java)
%% ==============================
-module(ibot_nodes_sup).

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
    IBot_Comm_Db_Child = ?CHILD(ibot_nodes_comm_db_srv, worker),
    IBot_Comm_Topic_Child = ?CHILD(ibot_nodes_comm_topic_srv, worker),
    IBot_Nodes_Registrator = ?CHILD(ibot_nodes_registrator_srv, worker),
    IBot_Nodes_Connecor = ?CHILD(ibot_nodes_connector, worker),
    {ok, { {one_for_one, 5, 10}, [IBot_Comm_Db_Child, IBot_Comm_Topic_Child, IBot_Nodes_Registrator, IBot_Nodes_Connecor]} }.

