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
-include("../../ibot_db/include/ibot_db_records.hrl").
-include("env_params.hrl").
-include("ibot_core_spec_symbols.hrl").

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
%% Compile all nodes command

handle_call({?COMPILE_ALL_NODES}, _From, State) ->
  ?DMI("handle_call COMPILE_ALL_NODES", ?COMPILE_ALL_NODES),
  ibot_core_srv_compile_nodes:compile_all_nodes(), %% compile all nodes
  {reply, ok, State};



%% @doc
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
%% Compile all nodes in project
%% @spec compile_all_nodes() -> ok.
%% @end
-spec compile_all_nodes() -> ok.

compile_all_nodes() ->
  case ibot_db_func_config:get_nodes_name_from_config() of %% get all nodes name
    error -> ?DMI("compile_all_nodes", "error from ibot_db_func_config:get_nodes_name_from_config()");
    NodesList ->
      case ibot_db_func_config:get_full_project_path() of %% get full path to project directory
        ?FULL_PROJECT_PATH_NOT_FOUND -> ?FULL_PROJECT_PATH_NOT_FOUND; %% full ptoject path not found
        Full_Project_Path ->
          compile_node(NodesList, Full_Project_Path) %% compile all nodes
      end
  end,
  ok.



%% @doc
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
%% Компиляция узла
%% @spec compile_node([NodeName | NodeNamesList], Full_Project_Path) -> ok
%% when NodeName :: string(), NodeNamesList :: list(), Full_Project_Path :: string().
%% @end
-spec compile_node([NodeName | NodeNamesList], Full_Project_Path) -> ok
  when NodeName :: string(), NodeNamesList :: list(), Full_Project_Path :: string().

compile_node([NodeName | NodeNamesList], Full_Project_Path) ->
  CompileDevPath = string:join([Full_Project_Path, ?DEV_FOLDER, ?NODES_FOLDER], ?PATH_DELIMETER_SYMBOL),
  NodeCompilePath = string:join([CompileDevPath, NodeName], ?PATH_DELIMETER_SYMBOL), %% node compilation directory

  MessagePath = string:join([Full_Project_Path, ?DEV_FOLDER, ?MESSAGE_DIR], ?PATH_DELIMETER_SYMBOL),
  ServicePath = string:join([Full_Project_Path, ?DEV_FOLDER, ?SERVICE_DIR], ?PATH_DELIMETER_SYMBOL),

  CoreConigSettings = ibot_db_func_config:get_core_config_info(), %% данные конфига ядра / core config data

  case ibot_db_func_config:get_node_info(list_to_atom(NodeName)) of %% get node info from config db
    ?NODE_INFO_NOT_FOUND -> error; %% node info not found in config db
    ?ACTION_ERROR -> error; %% action error
    NodeInfoRecord ->
      case NodeInfoRecord#node_info.atomNodeLang of %% chack node lang
        %% compile java node
        java ->
          NodePath = string:join([Full_Project_Path, ?PROJECT_SRC, NodeName], ?PATH_DELIMETER_SYMBOL),
          NodeSourcePath = string:join([NodePath, ?JAVA_NODE_SRC], ?PATH_DELIMETER_SYMBOL),
          ExecuteCommand = string:join(["javac", "-d", NodeCompilePath, "-classpath",
          string:join([
            CoreConigSettings#core_info.java_node_otp_erlang_lib_path ,
            ":",
            CoreConigSettings#core_info.java_ibot_lib_jar_path,
            ":",
            ibot_db_func_config:get_full_project_path(), "/dev/msg/java:",
            ibot_db_func_config:get_full_project_path(),"/dev/srv/java"], ""),
          string:join([NodeSourcePath, "*.java"], ?PATH_DELIMETER_SYMBOL)], " "),
          ?DMI("compile_node", [ExecuteCommand]),
          copy_node_config_to_dev_node(NodePath, NodeCompilePath),
          ibot_core_func_cmd:run_exec(ExecuteCommand);

        python ->
          copy_msg_srv_files_to_dev_node(NodeCompilePath, MessagePath, NodeInfoRecord#node_info.messageFile, "python", ".py"),
          copy_msg_srv_files_to_dev_node(NodeCompilePath, ServicePath, NodeInfoRecord#node_info.serviceFile, "python", ".py"),
          NodePath = string:join([Full_Project_Path, ?PROJECT_SRC, NodeName], ?PATH_DELIMETER_SYMBOL),
          NodeSourcePath = string:join([NodePath, ?PYTHON_NODE_SRC], ?PATH_DELIMETER_SYMBOL),
          ibot_core_func_cmd_cdir:copy_dir(NodeSourcePath, NodeCompilePath),
          copy_node_config_to_dev_node(NodePath, NodeCompilePath);

        _ -> error
      end
  end,
  compile_node(NodeNamesList, Full_Project_Path); %% compile next node
compile_node([],_) -> ok.



copy_msg_srv_files_to_dev_node(_NodeCompilePath, _SourcePath, [], _Lang, _Ext) ->
  ok;
copy_msg_srv_files_to_dev_node(NodeCompilePath, SourcePath, [MsgFile | MsgFileList], Lang, Ext) ->
  FileName = string:join([MsgFile, Ext], ""),
  SourcePathFile = string:join([SourcePath, Lang, FileName], ?PATH_DELIMETER_SYMBOL),
  DestinationPathFile = string:join([NodeCompilePath, FileName], ?PATH_DELIMETER_SYMBOL),
  ?DMI("copy_msg_srv_files_to_dev_node -> source | destination", [SourcePathFile, DestinationPathFile]),
  file:copy(SourcePathFile, DestinationPathFile),
  copy_msg_srv_files_to_dev_node(NodeCompilePath, SourcePath, MsgFileList, Lang, Ext).



copy_node_config_to_dev_node(RootNodeFolder, DestinationNodeFolder) ->
  SourceConfigFilePath = string:join([RootNodeFolder, "node_config.conf"], ?PATH_DELIMETER_SYMBOL),
  DestinationConfigFilePath = string:join([DestinationNodeFolder, "node_config.conf"], ?PATH_DELIMETER_SYMBOL),
  file:copy(SourceConfigFilePath, DestinationConfigFilePath).