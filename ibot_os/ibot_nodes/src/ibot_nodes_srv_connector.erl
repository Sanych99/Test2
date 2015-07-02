%%%-------------------------------------------------------------------
%%% @author Tsaregorodtsev Alexandr
%%% @copyright (C) 2015
%%% @doc
%%%
%%% @end
%%% Created : 22. Февр. 2015 21:43
%%%-------------------------------------------------------------------
-module(ibot_nodes_srv_connector).

-behaviour(gen_server).

-export([start_link/1, run_node/1, stop_node/1, send_start_signal/2]).

-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-include("../../ibot_core/include/debug.hrl").
-include("ibot_comm_commands.hrl").
-include("ibot_nodes_modules.hrl").
-include("ibot_nodes_registration_info.hrl").
-include("../../ibot_core/include/env_params.hrl").

-record(state, {node_port, node_name}).


start_link([NodeInfo | NodeInfoTopic]) ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [NodeInfo | NodeInfoTopic], []).


init([NodeInfo | NodeInfoTopic]) -> ?DBG_MODULE_INFO("run nodes: ~p~n", [?MODULE, [NodeInfo | NodeInfoTopic]]),
  %ibot_db_srv:add_record(node_registrator_db, 'bar@alex-N550JK', NodeInfo),
  %ibot_db_srv:add_record(node_registrator_db, 'bar_topic@alex-N550JK', NodeInfoTopic),
  %run_node(NodeInfo),
  %run_node(NodeInfoTopic),
  {ok, #state{node_name = NodeInfo#node_info.nodeNameServer}}.


handle_call({?RESTART_NODE, NodeName}, _From, State) -> ?DBG_MODULE_INFO("handle_call: ~p~n", [?MODULE, [?RESTART_NODE, NodeName]]),
  case ibot_db_func_config:get_node_info(NodeName) of
    [] -> ok;
    NodeInfo -> run_node(NodeInfo)
  end,
  %case gen_server:call(?IBOT_NODES_SRV_REGISTRATOR, {?GET_NODE_INFO, NodeName}) of
  %  [{NodeName, NodeInfoRecord}] -> ?DBG_MODULE_INFO("handle_call: ~p node found: ~p~n", [?MODULE, [?RESTART_NODE, NodeName], [{NodeName, NodeInfoRecord}]]),
  %    run_node(NodeInfoRecord); %% Run new node (Restart)
  %  {response, {ok, NodeInfoRecord}} -> ?DBG_MODULE_INFO("handle_call: ~p node found: ~p~n", [?MODULE, [?RESTART_NODE, NodeName], [{NodeName, NodeInfoRecord}]]),
  %    run_node(NodeInfoRecord); %% Run new node (Restart)
  %  [] -> ?DBG_MODULE_INFO("handle_call: ~p node info not found ~n", [?MODULE, [?RESTART_NODE, NodeName]]),
  %    ok;
  %  Vals -> ?DBG_MODULE_INFO("handle_call: ~p ~n", [?MODULE, Vals]),
  %    ok
  %end,
  {reply, ok, State};
handle_call(_Request, _From, State) ->
  {reply, ok, State}.


handle_cast({start_node, NodeInfo},State) ->
  run_node(NodeInfo),
  {noreply, State};
handle_cast(_Request, State) ->
  {noreply, State}.


%handle_info({_Port, {data, {eol, "READY!"}}}, State)-> ?DBG_MODULE_INFO("handle_info {eol, READY} start monitor: -> ~n", [?MODULE]),
%  ibot_nodes_srv_monitor:start_link("BLA_BLA_BLA@alex-N550JK"),
%  {noreply, State};


handle_info({start_monitor, NodeNameString, NodeNameAtom, NodeServerAtom, NodeNameAndServerAtom}, State) ->
  ibot_nodes_srv_monitor:start_link({NodeNameString, NodeNameAtom, NodeServerAtom, NodeNameAndServerAtom}),
  {noreply, State};

handle_info({stop_monitor, NodeNameString}, State) ->
  %gen_server:call({string:join([NodeNameString, "monitor"], "_"), node()}, {stop}),
  %erlang:send({local, string:join([NodeNameString, "monitor"], "_")}, {}),
  {noreply, State};


%% @doc Pass start signal to node
%% @spec handle_info({get_me_start_signal, MailBoxName, ClientNodeFullName}, State) -> {noreply, State}
%% when MailBoxName :: atom(), ClientNodeFullName :: atom().
%% @end

handle_info({get_me_start_signal, MailBoxName, ClientNodeFullName}, State) ->
  ?DBG_MODULE_INFO("handle_info(Msg, State) ~p~n", [?MODULE, {get_me_start_signal, MailBoxName, ClientNodeFullName}]),
  erlang:send({MailBoxName, ClientNodeFullName},{"start"}),
  {noreply, State};

handle_info(Msg, State)-> ?DBG_MODULE_INFO("handle_info(Msg, State) ~p~n", [?MODULE, Msg]),
  {noreply, State}.


terminate(_Reason, _State) ->
  ok.


code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

%% @doc
%% Запуск узла
%% @spec run_node(NodeInfo) -> ok when NodeInfo :: #node_info{}.
%% @end

-spec run_node(NodeInfo) -> ok when NodeInfo :: #node_info{}.

run_node([]) ->
  ?DBG_MODULE_INFO("run_node([]) -> ...~n", [?MODULE]),
  ok;

run_node(NodeInfo = #node_info{nodeName = NodeName, nodeServer = NodeServer, nodeNameServer = NodeNameServer,
  nodeLang = NodeLang, atomNodeLang = AtomNodeLang, nodeExecutable = NodeExecutable,
  nodePreArguments = NodePreArguments, nodePostArguments = NodePostArgumants}) -> ?DBG_MODULE_INFO("run_node(NodeInfo) -> ~p~n", [?MODULE, {NodeInfo, net_adm:localhost()}]),

  FullProjectPath = ibot_db_func_config:get_full_project_path(),

  case AtomNodeLang of
    java ->
      %% Проверка наличия исполняющего файла java
      case os:find_executable(NodeExecutable) of
        [] ->
          throw({stop, executable_file_missing});
        ExecutableFile ->
          ArgumentList = lists:append([
            %["-classpath",
            %  "/usr/lib/erlang/lib/jinterface-1.5.12/priv/OtpErlang.jar:/home/alex/iBotOS/RobotOS/_RobOS/test/nodes/java:/home/alex/iBotOS/iBotOS/JLib/lib/Node.jar:/home/alex/ErlangTest/test_from_bowser/dev/nodes/"++NodeName],
            NodePreArguments, % Аргументы для исполняемого файла
            %["BLA_BLA_BLA", "BLA_BLA_BLA", "alex-N550JK", "core@alex-N550JK", "BLA_BLA_BLA_MBOX", "ibot_nodes_srv_topic", "jv"]
            [NodeName, % Имя запускаемого узла
              NodeName, % mail box name
              net_adm:localhost(), % host name
              % Передаем параметры в узел
              atom_to_list(node()), % Имя текущего узла
              "ibot_nodes_srv_topic", % Topic registrator
              erlang:get_cookie()]%, % Значение Cookies для узла
            %NodePostArgumants] % Аргументы определенные пользователем для передачи в узел
          ]
          ),
          % Выполянем комманду по запуску узла
          erlang:open_port({spawn_executable, ExecutableFile}, [{line,1000}, stderr_to_stdout, {args, ArgumentList}])
      %erlang:open_port({spawn, "java"}, [{line,1000}, stderr_to_stdout, {args, [" -classpath /usr/lib/erlang/lib/jinterface-1.5.12/priv/OtpErlang.jar:/home/alex/iBotOS/RobotOS/_RobOS/test/nodes/java:/home/alex/iBotOS/iBotOS/JLib/lib/Node.jar:/home/alex/ErlangTest/test_from_bowser/dev/nodes/"]}])
      end;

    python ->
      case os:find_executable(NodeExecutable) of
        [] ->
          throw({stop, executable_file_missing});

        ExecutableFile ->
        erlang:open_port({spawn_executable, ExecutableFile}, [{line,1000}, stderr_to_stdout,
          {args, [string:join([FullProjectPath, ?DEV_FOLDER, ?NODES_FOLDER, NodeName, string:join([NodeName, ".py"], "")], ?DELIM_PATH_SYMBOL),
            "BLA_BLA_BLA_CLIENT", "alex-N550JK", "core@alex-N550JK", "ibot_nodes_srv_connector", "ibot_nodes_srv_topic", "ibot_nodes_srv_service", "jv"]}]),
          timer:apply_after(7000, ibot_nodes_srv_connector, send_start_signal, ['BLA_BLA_BLA_CLIENT_MBoxAsync', 'BLA_BLA_BLA_CLIENT@alex-N550JK'])

      end;

    _ -> error
  end.


stop_node([NodeName | NodeList]) ->
  ?DBG_MODULE_INFO("stop_node([NodeName | NodeList]): ~p~n", [?MODULE, NodeName]),
  case ibot_db_func_config:get_node_info(list_to_atom(NodeName)) of
    [] -> ok;
    NodeInfo ->
      ?DBG_MODULE_INFO("stop_node([NodeName | NodeList]) -> try exit from node... ~p~n", [?MODULE, {NodeInfo#node_info.atomNodeSystemMailBox, NodeInfo#node_info.atomNodeServer}]),
      erlang:send({NodeInfo#node_info.atomNodeSystemMailBox, NodeInfo#node_info.atomNodeNameServer}, {system, exit})
  end,
  stop_node(NodeList);
stop_node([]) ->
  ok.

send_start_signal(MailBoxName, ClientNodeFullName) ->
  erlang:send({MailBoxName, ClientNodeFullName},{"start"}).

