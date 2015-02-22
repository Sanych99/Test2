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
-export([start_link/0, run_node/1]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-include("debug.hrl").
-include("nodes_registration_info.hrl").

-record(state, {node_port, node_name}).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
  {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term()} | ignore).
init([]) ->
  {ok, #state{}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #state{}) ->
  {reply, Reply :: term(), NewState :: #state{}} |
  {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_call(_Request, _From, State) ->
  {reply, ok, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_cast(Request :: term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_cast(_Request, State) ->
  {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
-spec(handle_info(Info :: timeout() | term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_info(Msg, State)->
  io:format("Get Message ~p~n", [Msg]),
  {noreply, State};
handle_info({nodedown, JavaNode}, State = #state{node_name = JavaNode}) ->
  io:format("Java node is down!"),
  {stop, nodedown, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #state{}) -> term()).
terminate(_Reason, _State) ->
  ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
    Extra :: term()) ->
  {ok, NewState :: #state{}} | {error, Reason :: term()}).
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
      ?DBG_MODULE_INFO("Port value: -> ~p~n", [?MODULE, Port]),
      %% Ожидаем подтверждения запуска узла
      case wait_for_ready(#state{node_port = Port, node_name = NodeNameServer}) of
        {ok, State} -> ok;
        {stop, Reason} -> ok
      end
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