%% ==============================
%% @doc Приложение управления внешними узлами
%% спроектированными разрабочками на языках (C/C++, Python, Java)
%% ==============================
-module(ibot_services_sup).

-behaviour(supervisor).

%% API
-export([start_link/0, start_child_monitor/4, stop_child_monitor/1]).

%% Supervisor callbacks
-export([init/1]).

-include("ibot_nodes_registration_info.hrl").
-include("../../ibot_core/include/debug.hrl").

-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).
-define(CHILD_PARAM(N, I, Type, P), {N, {I, start_link, [P]}, permanent, 5000, Type, [I]}).

%% Helper macro for declaring children of supervisor


%% ===================================================================
%% API functions
%% ===================================================================

%% @doc
%% Запуск наблюдателя
%% @end
start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).


%% @doc
%% Запуск монитора за узлом
%% @end
start_child_monitor(NodeNameString, NodeNameAtom, NodeServerAtom, NodeNameAndServerAtom) ->
  ?DMI("start_child_monitor", {NodeNameString, NodeNameAtom, NodeServerAtom, NodeNameAndServerAtom}),
  supervisor:start_child(?MODULE, ?CHILD_PARAM(list_to_atom(string:join([NodeNameString, "monitor"], "_")),
    ibot_services_srv_monitor, worker, {NodeNameString, NodeNameAtom, NodeServerAtom, NodeNameAndServerAtom})).

%% @doc
%% Остановка узла монитора за узлом
%% @end
stop_child_monitor(NodeName) ->
  ?DMI("stop_child_monitor", NodeName),
  supervisor:terminate_child(?MODULE, NodeName),
  supervisor:delete_child(?MODULE, NodeName).


%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

%% @doc
%% Запуск узлов и наблюдателя
%% @end
init([]) ->
  IBot_Comm_Topic_Child = ?CHILD(ibot_services_srv_topic, worker),
  %IBot_Nodes_Registrator = ?CHILD(ibot_nodes_srv_registrator, worker),

  IB1 = ?CHILD(ibot_services_srv_connector, worker),
  IBot_Services_Srv_Service = ?CHILD(ibot_services_srv_service, worker),
  IBot_Services_Srv_UI_Interaction = ?CHILD(ibot_services_srv_ui_interaction, worker),
  {ok, { {one_for_one, 5, 10}, [IBot_Comm_Topic_Child, IB1, IBot_Services_Srv_Service, IBot_Services_Srv_UI_Interaction]} }.