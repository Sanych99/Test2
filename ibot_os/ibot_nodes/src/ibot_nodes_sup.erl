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

-include("nodes_registration_info.hrl").

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

  NodeInfo = #node_info{nodeName = "ClientTest", nodeServer = "alex-N550JK", nodeNameServer = "bar@alex-N550JK",
    nodeLang = "Java", nodeExecutable = "java",
    %nodePreArguments = ["-classpath",
    %  "C:\\Program Files\\erl6.3\\lib\\jinterface-1.5.12\\priv\\OtpErlang.jar;C:\\_RobotOS\\RobotOS\\_RobOS\\test\\nodes\\java;C:\\_RobotOS\\RobotOS\\_RobOS\\langlib\\java\\lib\\Node.jar"],
    nodePreArguments = ["-classpath",
      "/usr/lib/erlang/lib/jinterface-1.5.12/priv/OtpErlang.jar:/home/alex/iBotOS/RobotOS/_RobOS/test/nodes/java:/home/alex/iBotOS/iBotOS/JLib/lib/Node.jar"],
    nodePostArguments = []},

  NodeInfoTopic = #node_info{nodeName = "ClientTestTopic", nodeServer = "alex-N550JK", nodeNameServer = "bar_topic@alex-N550JK",
    nodeLang = "Java", nodeExecutable = "java",
    %nodePreArguments = ["-classpath",
    %  "C:\\Program Files\\erl6.3\\lib\\jinterface-1.5.12\\priv\\OtpErlang.jar;C:\\_RobotOS\\RobotOS\\_RobOS\\test\\nodes\\java;C:\\_RobotOS\\RobotOS\\_RobOS\\langlib\\java\\lib\\Node.jar"],
    nodePreArguments = ["-classpath",
      "/usr/lib/erlang/lib/jinterface-1.5.12/priv/OtpErlang.jar:/home/alex/iBotOS/RobotOS/_RobOS/test/nodes/java:/home/alex/iBotOS/iBotOS/JLib/lib/Node.jar"],
    nodePostArguments = []},




    IBot_Comm_Topic_Child = ?CHILD(ibot_nodes_srv_topic, worker),
    IBot_Nodes_Registrator = ?CHILD(ibot_nodes_srv_registrator, worker),

    IB1 = ?CHILD_PARAM(ibot_nodes_srv_connector, ibot_nodes_srv_connector, worker, [NodeInfo | NodeInfoTopic]),
    {ok, { {one_for_one, 5, 10}, [IBot_Comm_Topic_Child, IBot_Nodes_Registrator, IB1]} },
  {ok, { {one_for_one, 5, 10}, []} }.

