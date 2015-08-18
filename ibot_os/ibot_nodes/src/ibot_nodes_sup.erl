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

-include("ibot_nodes_registration_info.hrl").

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).
-define(CHILD_PARAM(N, I, Type, P), {N, {I, start_link, [P]}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
  IBot_Comm_Topic_Child = ?CHILD(ibot_nodes_srv_topic, worker),
  %IBot_Nodes_Registrator = ?CHILD(ibot_nodes_srv_registrator, worker),

  IB1 = ?CHILD(ibot_nodes_srv_connector, worker),
  IBot_Nodes_Srv_Service = ?CHILD(ibot_nodes_srv_service, worker),
  IBot_Nodes_Srv_UI_Interaction = ?CHILD(ibot_nodes_srv_ui_interaction, worker),
  {ok, { {one_for_one, 5, 10}, [IBot_Comm_Topic_Child, IB1, IBot_Nodes_Srv_Service, IBot_Nodes_Srv_UI_Interaction]} }.

