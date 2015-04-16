%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% Compilation prject nodes.
%%%
%%% @end
%%% Created : 27. Mar 2015 1:10 AM
%%%-------------------------------------------------------------------
-module(ibot_core_srv_compile_nodes).
-author("alex").

-behaviour(gen_server).

-include("debug.hrl").
-include("ibot_core_node_compilation_commands.hrl").
-include("../../ibot_db/include/ibot_db_reserve_atoms.hrl").
-include("env_params.hrl").

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-export([compile_all_nodes/0]).

-define(SERVER, ?MODULE).

-record(state, {}).


start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).


init([]) ->
  {ok, #state{}}.



%% === handle_call method start ===

%% @doc
%%
%% Compile all nodes command

handle_call({?COMPILE_ALL_NODES}, _From, State) ->
  ?DBG_MODULE_INFO("handle_call({?COMPILE_ALL_NODES}, _From, State) -> ~p~n", [?MODULE, {?COMPILE_ALL_NODES}]),
  ibot_core_srv_compile_nodes:compile_all_nodes(),
  {reply, ok, State};

%% @doc
%%
%% Compile one node

handle_call({?COMPILE_NODE, NodeName}, _From, State) ->
  {reply, ok, State};

handle_call(_Request, _From, State) ->
  {reply, ok, State}.

%% === handle_call method end ===



handle_cast(_Request, State) ->
  {noreply, State}.


handle_info(_Info, State) ->
  {noreply, State}.


terminate(_Reason, _State) ->
  ok.


code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

%%% ====== compile_all_nodes function start ======

compile_all_nodes() ->

  case ibot_db_func_config:get_nodes_name_from_config() of
    NodesList ->
      case ibot_db_func_config:get_full_project_path() of
        ?FULL_PROJECT_PATH_NOT_FOUND -> ?FULL_PROJECT_PATH_NOT_FOUND;
        Full_Project_Path ->
          compile_node(NodesList, Full_Project_Path)
      end,
      ok;
    _ -> ?DBG_MODULE_INFO("compile_all_nodes() -> error from ibot_db_func_config:get_nodes_name_from_config() ~n", [?MODULE])
  end,
  ok.

%%% ====== compile_all_nodes function end ======


compile_node([NodeName | NodeNamesList], Full_Project_Path) ->
  NodeCompilePath = string:join([Full_Project_Path, ?DEV_FOLDER, ?NODES_FOLDER, NodeName], ?DELIM_PATH_SYMBOL),

  ExecuteCommand = string:join(["javac", "-d", NodeCompilePath, "-classpath",
  "/usr/lib/erlang/lib/jinterface-1.5.12/priv/OtpErlang.jar:/home/alex/iBotOS/iBotOS/JLib/lib/Node.jar:/home/alex/iBotOS/RobotOS/_RobOS/test/nodes/java:/home/alex/ErlangTest/test_from_bowser/dev/msg/java:/home/alex/ErlangTest/test_from_bowser/dev/srv/java",
    string:join([Full_Project_Path, ?PROJECT_SRC, NodeName, ?JAVA_NODE_SRC, "*.java"], ?DELIM_PATH_SYMBOL)], " "),

  ibot_core_func_cmd:run_exec(ExecuteCommand),

  compile_node(NodeNamesList, Full_Project_Path),
  ok;
compile_node([],Full_Project_Path) -> ok.

