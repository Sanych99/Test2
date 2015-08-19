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

-export([start_link/0, run_node/1, stop_node/1, send_start_signal/2]).

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


start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).


init([]) ->
  {ok, #state{}}.

%% restart node
handle_call({?RESTART_NODE, NodeName}, _From, State) ->
  ?DMI("handle_call restart_node", NodeName),
  %% get node info
  case ibot_db_func_config:get_node_info(NodeName) of
    [] -> ok; %% info not found
    NodeInfo -> run_node(NodeInfo) %% run node
  end,
  {reply, ok, State};
handle_call(_Request, _From, State) ->
  {reply, ok, State}.

%% start node
handle_cast({start_node, NodeInfo},State) ->
  run_node(NodeInfo), %% start node
  {noreply, State};
handle_cast(_Request, State) ->
  {noreply, State}.


%% start monitor for node
handle_info({start_monitor, NodeNameString, NodeNameAtom, NodeServerAtom, NodeNameAndServerAtom}, State) ->
  %% run new process for monitoring node
  ibot_nodes_srv_monitor:start_link({NodeNameString, NodeNameAtom, NodeServerAtom, NodeNameAndServerAtom}),
  {noreply, State};

%% stop node monitoring
handle_info({stop_monitor, NodeNameString}, State) ->
  gen_server:call({string:join([NodeNameString, "monitor"], "_"), node()}, {stop}),
  %erlang:send({local, string:join([NodeNameString, "monitor"], "_")}, {stop}),
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
  nodePreArguments = NodePreArguments, nodePostArguments = NodePostArgumants, projectType = ProjectType,
  mainClassName = MainClassName}) -> ?DBG_MODULE_INFO("run_node(NodeInfo) -> ~p~n", [?MODULE, {NodeInfo, net_adm:localhost()}]),

  FullProjectPath = ibot_db_func_config:get_full_project_path(),

  case AtomNodeLang of
    java ->
          %% Проверка наличия исполняющего файла java
          case os:find_executable(NodeExecutable) of
            [] ->
              throw({stop, executable_file_missing});
            ExecutableFile ->
              case ProjectType of
                native ->
                  ArgumentList = lists:append([
                    %["-classpath",
                    %  "/usr/lib/erlang/lib/jinterface-1.5.12/priv/OtpErlang.jar:/home/alex/iBotOS/RobotOS/_RobOS/test/nodes/java:/home/alex/iBotOS/iBotOS/JLib/lib/Node.jar:/home/alex/ErlangTest/test_from_bowser/dev/nodes/"++NodeName],
                    NodePreArguments, % Аргументы для исполняемого файла
                    %["BLA_BLA_BLA", "BLA_BLA_BLA", "alex-N550JK", "core@alex-N550JK", "BLA_BLA_BLA_MBOX", "ibot_nodes_srv_topic", "jv"]
                    [NodeName, % Имя запускаемого узла
                      NodeName,
                      net_adm:localhost(), % mail box name
                      atom_to_list(node()), % host name
                      % Передаем параметры в узел
                      "ibot_nodes_srv_connector", % Имя текущего узла
                      "ibot_nodes_srv_topic", % Topic registrator
                      "ibot_nodes_srv_service",
                      "ibot_nodes_srv_ui_interaction",
                      erlang:get_cookie()]%, % Значение Cookies для узла
                    %NodePostArgumants] % Аргументы определенные пользователем для передачи в узел
                  ]
                );
                maven ->
                  %% Start maven java node
                  ArgumentList = ["-cp",
                    string:join([string:join([FullProjectPath, ?DEV_FOLDER, ?NODES_FOLDER, NodeName,
                      string:join([NodeName, ".jar"], "")], ?DELIM_PATH_SYMBOL),
                    ":", "/usr/lib/erlang/lib/jinterface-1.5.12/priv/OtpErlang.jar"], ""),
                    MainClassName,
                    NodeName, % Имя запускаемого узла
                    net_adm:localhost(), % mail box name
                    atom_to_list(node()), % host name
                    % Передаем параметры в узел
                    "ibot_nodes_srv_connector", % Имя текущего узла
                    "ibot_nodes_srv_topic", % Topic registrator
                    "ibot_nodes_srv_service",
                    "ibot_nodes_srv_ui_interaction",
                    erlang:get_cookie()],

                  ?DMI("maven start", ArgumentList);

                _ ->
                  ArgumentList = [],
                  error
                end,
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
            %"BLA_BLA_BLA_CLIENT", "alex-N550JK", "core@alex-N550JK", "ibot_nodes_srv_connector", "ibot_nodes_srv_topic", "ibot_nodes_srv_service", "jv"
            NodeName, net_adm:localhost(), atom_to_list(node()), "ibot_nodes_srv_connector", "ibot_nodes_srv_topic", "ibot_nodes_srv_service", "ibot_nodes_srv_ui_interaction", erlang:get_cookie()
          ]}]),

          timer:apply_after(7000, ibot_nodes_srv_connector, send_start_signal,
            [list_to_atom(string:join([NodeName, "MBoxAsync"], "_")), list_to_atom(string:join([NodeName, net_adm:localhost()], "@"))]);

        _ -> error
      end
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

