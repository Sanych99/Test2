%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Февр. 2015 23:57
%%%-------------------------------------------------------------------
-module(runner_test).
-author("alex").
-include("nodes_registration_info.hrl").
%% API
-export([start/0, crate_node/0]).

start() ->
  Info = gen_server:start({local, ibot_nodes_connector}, ibot_nodes_connector, [], []),
  io:format("RUNNER TEST INFO: -> ~p~n", [Info]),
  ok.

crate_node() ->
  NodeInfo = #node_info{nodeName = "ClientTest", nodeServer = "alexandr", nodeNameServer = "bar@alexandr",
  nodeLang = "Java", nodeExecutable = "java",
    nodePreArguments = ["-classpath",
      "C:\\Program Files\\erl6.3\\lib\\jinterface-1.5.12\\priv\\OtpErlang.jar;C:\\_RobotOS\\RobotOS\\_RobOS\\test\\nodes\\java;C:\\_RobotOS\\RobotOS\\_RobOS\\langlib\\java\\lib\\Node.jar"],
  nodePostArguments = []},

  ibot_nodes_connector:run_node(NodeInfo),

  ok.
