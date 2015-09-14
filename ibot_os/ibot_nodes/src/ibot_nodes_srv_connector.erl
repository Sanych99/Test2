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

-export([start_link/0, run_node/1, stop_node/1, send_start_signal/2, stop_monitor/1]).

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
-include("../../ibot_db/include/ibot_db_records.hrl").

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
    NodeInfo ->
      run_node(NodeInfo) %% run node
  end,
  {reply, ok, State};
handle_call(_Request, _From, State) ->
  {reply, ok, State}.


handle_cast({?RESTART_NODE, NodeName},State) ->
  ?DMI("handle_cast restart_node", NodeName),
  %% get node info
  case ibot_db_func_config:get_node_info(NodeName) of
    [] -> ok; %% info not found
    NodeInfo ->
      run_node(NodeInfo) %% run node
  end,
  {noreply, State};

%% start node
handle_cast({start_node, NodeInfo},State) ->
  run_node(NodeInfo), %% start node
  {noreply, State};
handle_cast(_Request, State) ->
  {noreply, State}.


handle_info({start_node_from_node, NodeName}, State) ->
  ibot_nodes_srv_connector:start_node([NodeName]),
  {noreply, State};

handle_info({stop_node_from_node, NodeName}, State) ->
  ibot_nodes_srv_connector:stop_node([NodeName]),
  {noreply, State};

%% start monitor for node
handle_info({start_monitor, NodeNameString, NodeNameAtom, NodeServerAtom, NodeNameAndServerAtom}, State) ->
  %% run new process for monitoring node
  ibot_nodes_sup:start_child_monitor(NodeNameString, NodeNameAtom, NodeServerAtom, NodeNameAndServerAtom),
  {noreply, State};

%% stop node monitoring
handle_info({stop_monitor, NodeNameString}, State) ->
  ibot_nodes_srv_connector:stop_monitor(NodeNameString),
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
  mainClassName = MainClassName}) ->
  ?DMI("run_node", NodeName), %% информация отладки / debug information
  ibot_nodes_srv_connector:stop_monitor(NodeName), %% остановка монитора за узлом / stop monitor by node
  FullProjectPath = ibot_db_func_config:get_full_project_path(), %% полный путь до проекта / full path to project
  CoreConigSettings = ibot_db_func_config:get_core_config_info(), %% данные конфига ядра / core config data
  %% запуск узла / start node
  case AtomNodeLang of
    java ->
          %% проверка наличия исполняющего файла java
          case os:find_executable(NodeExecutable) of
            [] ->
              throw({stop, executable_file_missing});
            ExecutableFile ->
              case ProjectType of
                native ->
                  ArgumentList = lists:append([
                    NodePreArguments, % Аргументы для исполняемого файла
                    [NodeName, % Имя запускаемого узла
                      NodeName,
                      net_adm:localhost(), % mail box name
                      atom_to_list(node()), % host name
                      % Передаем параметры в узел
                      CoreConigSettings#core_info.connector_node, %имя узла регистратора / registraction node name
                      CoreConigSettings#core_info.topic_node, % узел регистрации топиков / topic registrator node
                      CoreConigSettings#core_info.service_node, % узел регистрации сервисов / service registration node
                      CoreConigSettings#core_info.ui_interaction_node, % узел взаимодействия с интерфейсом пользователя / user intraction node
                      erlang:get_cookie()]%, % Значение Cookies для узла
                    %NodePostArgumants] % Аргументы определенные пользователем для передачи в узел
                  ]
                );
                maven ->
                  %% Start maven java node
                  ArgumentList = ["-cp",
                    string:join([string:join([FullProjectPath, ?DEV_FOLDER, ?NODES_FOLDER, NodeName,
                      string:join([NodeName, ".jar"], "")], ?DELIM_PATH_SYMBOL),
                    ":", CoreConigSettings#core_info.java_node_otp_erlang_lib_path], ""),
                    MainClassName,
                    NodeName, % Имя запускаемого узла
                    net_adm:localhost(), % mail box name
                    atom_to_list(node()), % host name
                    % передаем параметры в узел / send parameters to node
                    CoreConigSettings#core_info.connector_node, % имя узла регистратора / registraction node name
                    CoreConigSettings#core_info.topic_node, % узел регистрации топиков / topic registrator node
                    CoreConigSettings#core_info.service_node, % узел регистрации сервисов / service registration node
                    CoreConigSettings#core_info.ui_interaction_node, % узел взаимодействия с интерфейсом пользователя / user intraction node
                    erlang:get_cookie()],

                  ?DMI("maven start", ArgumentList);

                _ ->
                  ArgumentList = [],
                  error
                end,
              % Выполянем комманду по запуску узла
              erlang:open_port({spawn_executable, ExecutableFile}, [{line,1000}, stderr_to_stdout, {args, ArgumentList}])
          end;




    python ->
      case os:find_executable(NodeExecutable) of
        [] ->
          throw({stop, executable_file_missing});

        ExecutableFile ->
        erlang:open_port({spawn_executable, ExecutableFile}, [{line,1000}, stderr_to_stdout,
          {args, [string:join([FullProjectPath, ?DEV_FOLDER, ?NODES_FOLDER, NodeName, string:join([NodeName, ".py"], "")], ?DELIM_PATH_SYMBOL),
            NodeName, net_adm:localhost(), atom_to_list(node()),
            CoreConigSettings#core_info.connector_node, %имя узла регистратора / registraction node name
            CoreConigSettings#core_info.topic_node, % узел регистрации топиков / topic registrator node
            CoreConigSettings#core_info.service_node, % узел регистрации сервисов / service registration node
            CoreConigSettings#core_info.ui_interaction_node, % узел взаимодействия с интерфейсом пользователя / user intraction node
            erlang:get_cookie()
          ]}]),

          timer:apply_after(3500, ibot_nodes_srv_connector, send_start_signal,
            [list_to_atom(string:join([NodeName, "MBoxAsync"], "_")), list_to_atom(string:join([NodeName, net_adm:localhost()], "@"))]);

        _ -> error
      end
  end.



%% ====== Nodes executing actions Start ======

%% @doc
%% запуск узла проекта / start project node
%% @spec start_node([NodeName | NodeList]) -> ok when NodeName :: atom(), NodeList :: list().
%% @end

-spec start_node([NodeName | NodeList]) -> ok when NodeName :: atom(), NodeList :: list().

start_node([NodeName | NodeList]) ->
  ?DMI("start_node", NodeName),
  %% get node info
  case ibot_db_func_config:get_node_info(NodeName) of
    [] -> ok; %% info not found
    NodeInfo ->
      run_node(NodeInfo) %% run node
  end,
  start_node(NodeList);
start_node([]) ->
  ok.


%% @doc
%% остановка узла проекта / stop project node
%% @spec stop_node([NodeName | NodeList]) -> ok when NodeName :: atom(), NodeList :: list().
%% @end

-spec stop_node([NodeName | NodeList]) -> ok when NodeName :: atom(), NodeList :: list().

stop_node([NodeName | NodeList]) ->
  ?DMI("stop_node", NodeName),
  case ibot_db_func_config:get_node_info(list_to_atom(NodeName)) of
    [] -> ok;
    NodeInfo ->
      erlang:send({NodeInfo#node_info.atomNodeSystemMailBox, NodeInfo#node_info.atomNodeNameServer}, {system, exit})
  end,
  stop_node(NodeList);
stop_node([]) ->
  ok.



%% @doc
%% отправка сигнала узлу проекта о старте работы / send signal to node about starting work
%% @spec send_start_signal(MailBoxName, ClientNodeFullName) -> term() when MailBoxName :: atom(), ClientNodeFullName :: atom().
%% @end

-spec send_start_signal(MailBoxName, ClientNodeFullName) -> term() when MailBoxName :: atom(), ClientNodeFullName :: atom().

send_start_signal(MailBoxName, ClientNodeFullName) ->
  erlang:send({MailBoxName, ClientNodeFullName},{"start"}).



%% @doc
%% остановка монитора за узлом / node monitor stop
%% @spec stop_monitor(NodeName) -> term() when NodeName :: atom().
%% @end

-spec stop_monitor(NodeName) -> term() when NodeName :: atom().

stop_monitor(NodeName) ->
  MonitorNodeName = list_to_atom(string:join([NodeName, "monitor"], "_")),
  case whereis(MonitorNodeName) of
    undefined -> ok;
    MonitorPid -> ibot_nodes_sup:stop_child_monitor(MonitorNodeName)
  end.

%% ====== Nodes executing actions End ======

