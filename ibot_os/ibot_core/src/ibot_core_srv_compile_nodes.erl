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
-include("../../ibot_nodes/include/ibot_nodes_registration_info.hrl").
-include("../../ibot_core/include/ibot_core_reserve_atoms.hrl").
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

-export([compile_all_nodes/0, compile_one_node/1]).

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
  ibot_core_srv_compile_nodes:compile_all_nodes(), %% compile all nodes
  {reply, ok, State};

%% @doc
%%
%% Compile one node

handle_call({?COMPILE_NODE, NodeName}, _From, State) ->
  ibot_core_srv_compile_nodes:compile_one_node(NodeName), %% compile node by name
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

%%% ====== compile nodes functions start ======


%% @doc
%%
%% Compile all nodes in project
%% @spec compile_all_nodes() -> ok.
%% @end

-spec compile_all_nodes() -> ok.
compile_all_nodes() ->
  case ibot_db_func_config:get_nodes_name_from_config() of %% get all nodes name
    NodesList ->
      case ibot_db_func_config:get_full_project_path() of %% get full path to project directory
        ?FULL_PROJECT_PATH_NOT_FOUND -> ?FULL_PROJECT_PATH_NOT_FOUND; %% full ptoject path not found
        Full_Project_Path ->
          compile_node(NodesList, Full_Project_Path) %% compile all nodes
      end;
    _ -> ?DBG_MODULE_INFO("compile_all_nodes() -> error from ibot_db_func_config:get_nodes_name_from_config() ~n", [?MODULE])
  end,
  ok.


%% @doc
%%
%% Compile one node by name
%% @spec compile_one_node(NodeName) -> ok when NodeName :: string().
%% @end

-spec compile_one_node(NodeName) -> ok when NodeName :: string().
compile_one_node(NodeName) ->
  case ibot_db_func_config:get_full_project_path() of %% get full path to project directory
    ?FULL_PROJECT_PATH_NOT_FOUND -> ?FULL_PROJECT_PATH_NOT_FOUND; %% full ptoject path not found
    Full_Project_Path ->
      compile_node([NodeName], Full_Project_Path) %% compile node
  end,
  ok.

%%% ====== compile nodes functions end ======



%% @doc
%%
%% Компиляция узла
%% @spec compile_node([NodeName | NodeNamesList], Full_Project_Path) -> ok
%% when NodeName :: string(), NodeNamesList :: list(), Full_Project_Path :: string().
%% @end

-spec compile_node([NodeName | NodeNamesList], Full_Project_Path) -> ok
  when NodeName :: string(), NodeNamesList :: list(), Full_Project_Path :: string().

compile_node([NodeName | NodeNamesList], Full_Project_Path) ->
  NodeCompilePath = string:join([Full_Project_Path, ?DEV_FOLDER, ?NODES_FOLDER, NodeName], ?DELIM_PATH_SYMBOL), %% node compilation directory

  case ibot_db_func_config:get_node_info(list_to_atom(NodeName)) of %% get node info from config db
    ?NODE_INFO_NOT_FOUND -> error; %% node info not found in config db
    ?ACTION_ERROR -> error; %% action error
    NodeInfoRecord ->
      case NodeInfoRecord#node_info.atomNodeLang of %% chack node lang
        %% compile java node
        java -> ExecuteCommand = string:join(["javac", "-d", NodeCompilePath, "-classpath",
          string:join(["/usr/lib/erlang/lib/jinterface-1.5.12/priv/OtpErlang.jar:/home/alex/iBotOS/iBotOS/JLib/lib/Node.jar:", ibot_db_func_config:get_full_project_path(),"/dev/msg/java:", ibot_db_func_config:get_full_project_path(),"/dev/srv/java"], ""),
          string:join([Full_Project_Path, ?PROJECT_SRC, NodeName, ?JAVA_NODE_SRC, "*.java"], ?DELIM_PATH_SYMBOL)], " "),
          ?DBG_MODULE_INFO("compile_node: ~p~n", [?MODULE, ExecuteCommand]),
          ibot_core_func_cmd:run_exec(ExecuteCommand);

        _ -> error
      end
  end,
  compile_node(NodeNamesList, Full_Project_Path); %% compile next node
compile_node([],_) -> ok.

