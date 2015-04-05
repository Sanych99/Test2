%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Февр. 2015 23:57
%%%-------------------------------------------------------------------
-module(r).
-author("alex").
-include("ibot_nodes_registration_info.hrl").
-include("debug.hrl").
-include("../../ibot_db/include/ibot_db_records.hrl").
%% API
-export([start/0, c/0, s/0, test/0]).

start() ->
  Info = gen_server:start({local, ibot_nodes_connector}, ibot_nodes_connector, [], []),
  io:format("RUNNER TEST INFO: -> ~p~n", [Info]),
  ok.

c() ->
  ibot_db_app:start(normal, []),
  ibot_core_app:start(normal, []),
  ibot_nodes_app:start(normal, []),

  ok.

s() ->
  case ibot_db_func_topics:get_topic_nodes(test_topic) of
    NodeInfoList ->
      ?DBG_MODULE_INFO("get info: ~p~n", [?MODULE, NodeInfoList]),
      spawn(fun() -> message_broadcast(NodeInfoList, {"Hello from Erlang!"}) end);
    [] -> ok
  end,
  ok.

message_broadcast([], _) -> ok;
message_broadcast([NodeInfo | NodeInfoList], Msg) ->
  erlang:send({ NodeInfo#node_pubsub_info.nodeName, NodeInfo#node_pubsub_info.serverName}, Msg),
  ?DBG_MODULE_INFO("send values: ~p~n", [?MODULE, {NodeInfo#node_pubsub_info.nodeName, NodeInfo#node_pubsub_info.serverName}]),
  message_broadcast(NodeInfoList, Msg),
  ok.

test() ->
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

  NodeInfoTopic2 = #node_info{nodeName = "BLA_BLA_BLA", nodeServer = "alex-N550JK", nodeNameServer = "bar_topic@alex-N550JK",
    nodeLang = "Java", nodeExecutable = "java",
    %nodePreArguments = ["-classpath",
    %  "C:\\Program Files\\erl6.3\\lib\\jinterface-1.5.12\\priv\\OtpErlang.jar;C:\\_RobotOS\\RobotOS\\_RobOS\\test\\nodes\\java;C:\\_RobotOS\\RobotOS\\_RobOS\\langlib\\java\\lib\\Node.jar"],
    nodePreArguments = ["-classpath",
      "/usr/lib/erlang/lib/jinterface-1.5.12/priv/OtpErlang.jar:/home/alex/iBotOS/RobotOS/_RobOS/test/nodes/java:/home/alex/iBotOS/iBotOS/JLib/lib/Node.jar"],
    nodePostArguments = []},

  %%ibot_nodes_connector:run_node(NodeInfo),
  %%ibot_nodes_connector:run_node(NodeInfoTopic),
  gen_server:start({local, ibot_nodes_connector2}, ibot_nodes_srv_connector, [NodeInfoTopic2 | []], []),
  ?DBG_INFO("ibot_nodes_connector2 run...~n", []),
  %gen_server:start({local, ibot_nodes_connector}, ibot_nodes_connector_srv, [NodeInfo | []], []),
  %?DBG_INFO("ibot_nodes_connector run...~n", []),
  ok.
