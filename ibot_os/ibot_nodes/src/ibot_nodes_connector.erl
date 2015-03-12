%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Февр. 2015 21:43
%%%-------------------------------------------------------------------
-module(ibot_nodes_connector).
-author("alex").

-behaviour(gen_server).

%% API
-export([start_link/1, run_node/1]).

%% gen_server callbacks
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
-include("nodes_registration_info.hrl").

-record(state, {node_port, node_name}).


start_link([NodeInfo | NodeInfoTopic]) ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [NodeInfo | NodeInfoTopic], []).


init([NodeInfo | NodeInfoTopic]) ->
  ?DBG_MODULE_INFO("run nodes: ~p~n", [?MODULE, [NodeInfo | NodeInfoTopic]]),
  run_node(NodeInfo),
  run_node(NodeInfoTopic),
  {ok, #state{}}.


handle_call({?RESTART_NODE, NodeName}, _From, State) ->
  ?DBG_MODULE_INFO("handle_call: ~p~n", [?MODULE, [?RESTART_NODE, NodeName]]),
  case gen_server:call(?IBOT_NODES_REGISTRATOR, {?GET_NODE_INFO, NodeName}) of
    [{NodeName, NodeInfoRecord}] ->
      ?DBG_MODULE_INFO("handle_call: ~p node found: ~p~n", [?MODULE, [?RESTART_NODE, NodeName], [{NodeName, NodeInfoRecord}]]),
      run_node(NodeInfoRecord); %% Run new node (Restart)
    [] ->
      ?DBG_MODULE_INFO("handle_call: ~p node info not found ~n", [?MODULE, [?RESTART_NODE, NodeName]]),
      ok
  end,
  {reply, ok, State};
handle_call(_Request, _From, State) ->
  {reply, ok, State}.


handle_cast(_Request, State) ->
  {noreply, State}.


handle_info(Msg, State)->
  ?DBG_MODULE_INFO("Get Message ~p~n", [?MODULE, Msg]),
  {noreply, State};
handle_info({nodedown, JavaNode}, State = #state{node_name = JavaNode}) ->
  ?DBG_MODULE_INFO("Get Message ~p~n", [?MODULE, "Java node is down!"]),
  {stop, nodedown, State}.


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
run_node(NodeInfo = #node_info{nodeName = NodeName, nodeServer = NodeServer, nodeNameServer = NodeNameServer,
  nodeLang = NodeLang, nodeExecutable = NodeExecutable,
  nodePreArguments = NodePreArguments, nodePostArguments = NodePostArgumants}) ->
  ?DBG_MODULE_INFO("#node_info value: -> ~p~n", [?MODULE, NodeInfo]),
  %% Проверка наличия исполняющего файла java
  case os:find_executable(NodeExecutable) of
    [] ->
      throw({stop, executable_file_missing});
    ExecutableFile ->
      %Classpath = "C:\\Program Files\\erl6.3\\lib\\jinterface-1.5.12\\priv\\OtpErlang.jar;C:\\_RobotOS\\RobotOS\\_RobOS\\test\\nodes\\java;C:\\_RobotOS\\RobotOS\\_RobOS\\langlib\\java\\lib\\Node.jar",% ++ [$: | Priv ++ "/*"],
      ArgumentList = lists:append([NodePreArguments, % Аргументы для исполняемого файла
        [NodeName, % Имя запускаемого узла
          % Передаем параметры в узел
          atom_to_list(node()), % Имя текущего узла
          NodeNameServer, % Имя сервера
          erlang:get_cookie()], % Значение Cookies для узла
        NodePostArgumants] % Аргументы определенные пользователем для передачи в узел
      ),
      % Выполянем комманду по запуску узла
      Port =
        erlang:open_port({spawn_executable, ExecutableFile},
          [{line,1000}, stderr_to_stdout,
            {args, ArgumentList}]),
      ?DBG_MODULE_INFO("Port value: -> ~p~n", [?MODULE, Port])
      %% Ожидаем подтверждения запуска узла
      %case wait_for_ready(#state{node_port = Port, node_name = NodeNameServer}) of
      %  {ok, State} -> ok;
      %  {stop, Reason} -> ok
      %end
  end.

%% @doc
%% Ожидаем запуск узла
%% при удачном запуске, создаем наблюдатель за узлом
%% @spec wait_for_ready(State) -> {stop, Reason} | {ok, State} when State :: #state{}, Reason :: term().
%% @end
-spec wait_for_ready(State) -> {stop, Reason} | {ok, State}
  when State :: #state{}, Reason :: term().
wait_for_ready(State = #state{node_port = Port}) ->
  receive
    {Port, {data, {eol, "READY"}}} ->
      process_flag(trap_exit, true),
      true = erlang:monitor_node(list_to_atom(State#state.node_name), true),
      case handle_info("READY", State) of
        {noreply, NewState} ->
          wait_for_ready(NewState);
        {stop, Reason, _NewState} ->
          {stop, Reason}
      end,
      {ok, State};
    Info ->
      case handle_info(Info, State) of
        {noreply, NewState} ->
          wait_for_ready(NewState);
        {stop, Reason, _NewState} ->
          {stop, Reason}
      end
  end.