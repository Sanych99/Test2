%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015
%%% @doc
%%%
%%% Load project information to data base.
%%%
%%% @end
%%% Created : 25. Mar 2015 8:00 PM
%%%-------------------------------------------------------------------
-module(ibot_core_srv_project_info_loader).
-author("alex").

-behaviour(gen_server).

-include("debug.hrl").
-include("ibot_core_create_project_paths.hrl").
-include("ibot_core_modules_names.hrl").
-include("ibot_core_spec_symbols.hrl").
-include("../../ibot_db/include/ibot_db_records.hrl").

%% API
-export([start_link/0]).
-export([load_core_config/0, load_project_config/1]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-export([read_node_config/1]).


-define(SERVER, ?MODULE).

-record(state, {}).


start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).


init([]) ->
  %%timer:apply_after(5000, ibot_db_srv, load_all_configs, []),
  {ok, #state{}}.

%% NOT USE
handle_call({?LOAD_PROJECT_ALL_NODES_INFO}, _From, State) ->
  case ibot_db_func_config:get_full_project_path() of
    ?ACTION_ERROR -> {reply, {?ACTION_ERROR}, State};
    ?FULL_PROJECT_PATH_NOT_FOUND -> {reply, {?FULL_PROJECT_PATH_NOT_FOUND}, State};
    ProjectPath ->
      %% load nodes information to db
      {reply, {ok, ProjectPath}, State}
  end;
handle_call({?LOAD_PROJECT_NODE_INFO, NodePath}, _From, State) ->
  ibot_core_srv_project_info_loader:read_node_config(NodePath), %% parse node configuration file
  {reply, ok, State};
handle_call({?LOAD_CORE_CONFIG}, _From, State) ->
  load_info_from_core_config(),
  {reply, ok, State};
handle_call({?LOAD_PROJECT_CONFIG, FullProjectPath}, _From, State) ->
  load_info_from_project_config(FullProjectPath),
  {reply, ok, State};
handle_call(_Request, _From, State) ->
  {reply, ok, State}.


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

%% @doc
%%
%% Read node configuration file
%%
%% @spec read_node_config(NodePath) -> ok when NodePath :: string().
%% @end

-spec read_node_config(NodePath) -> ok when NodePath :: string().

read_node_config(NodePath) ->
  {ok, FileContent} = file:read_file(NodePath),
  case jiffy:decode(FileContent) of
    {NodeConfigFileList} ->
      ?DBG_MODULE_INFO("read_node_config(NodeName) {ok, FileContent} = file:read_file(NodePath), -> ~p~n", [?MODULE, NodeConfigFileList]),
      create_node_config_record(NodeConfigFileList, #node_info{})
  end,
  ok.


%% @doc
%%
%% Create node configuration record from node configuration file
%%
%% @spec create_node_config_record([NodeConfigItem | NodeConfigList], NodeConfigRecord) -> ok when NodeConfigItem :: string(),
%% NodeConfigList :: list(), NodeConfigRecord :: #node_info{}.
%% @end

-spec create_node_config_record([NodeConfigItem | NodeConfigList], NodeConfigRecord) -> ok when NodeConfigItem :: string(),
  NodeConfigList :: list(), NodeConfigRecord :: #node_info{}.

create_node_config_record([NodeConfigItem | NodeConfigList], NodeConfigRecord) ->
  {Key, Val} = NodeConfigItem,
  case Key of
    <<"nodeName">> ->
      StrVal = binary_to_list(Val),
      {'ok', Hostname} = inet:gethostname(),
      NewNodeConfigRecord = NodeConfigRecord#node_info{nodeName = StrVal, atomNodeName = list_to_atom(StrVal),
      nodeSystemMailBox = string:join([StrVal, "_MBoxAsync"], ""), atomNodeSystemMailBox = list_to_atom(string:join([StrVal, "_MBoxAsync"], "")),
      nodeServer = Hostname, atomNodeServer = list_to_atom(Hostname),
      nodeNameServer = string:join([StrVal, "@", Hostname], ""), atomNodeNameServer = list_to_atom(string:join([StrVal, "@", Hostname], "")),
        nodePreArguments = ["-classpath",
          string:join(["/usr/lib/erlang/lib/jinterface-1.5.12/priv/OtpErlang.jar:/home/alex/iBotOS/RobotOS/_RobOS/test/nodes/java:/home/alex/iBotOS/iBotOS/JLib/lib/Node.jar:/home/alex/ErlangTest/test_from_bowser/dev/msg/java:", ibot_db_func_config:get_full_project_path(),"/dev/nodes/", StrVal], "")],
        nodePostArguments = []};
    <<"nodeLang">> ->
      StrVal = binary_to_list(Val),
      NewNodeConfigRecord = NodeConfigRecord#node_info{nodeLang = StrVal, atomNodeLang = list_to_atom(StrVal)};
    <<"nodeExecutable">> ->
      StrVal = binary_to_list(Val),
      NewNodeConfigRecord = NodeConfigRecord#node_info{nodeExecutable = StrVal};
    <<"runPreAgruments">> ->
      StrVal = binary_to_list(Val),
      NewNodeConfigRecord = NodeConfigRecord; %NodeConfigRecord#node_info{nodePreArguments = StrVal};
    <<"runPostArguments">> ->
      StrVal = binary_to_list(Val),
      NewNodeConfigRecord = NodeConfigRecord; %NodeConfigRecord#node_info{nodePostArguments = StrVal}
    Val ->
      ?DBG_MODULE_INFO("=====> .... try monitor: ~p~n", [?MODULE, Val]),
      NewNodeConfigRecord = NodeConfigRecord
  end,
  create_node_config_record(NodeConfigList, NewNodeConfigRecord);
create_node_config_record([], NodeConfigRecord) ->
  ?DBG_MODULE_INFO("create_node_config_record([], NodeConfigRecord) -> ~p~n", [?MODULE, NodeConfigRecord]),
  ibot_db_func_config:set_node_info(NodeConfigRecord),
  ok.


%% ====== Read Core Configuraion File Start ======

%% @doc API load core info
%% @spec load_core_config() -> ok.
%% @end

-spec load_core_config() -> ok.

load_core_config() ->
  ?DBG_MODULE_INFO("load_core_config() -> ...~n", [?MODULE]),
  %%gen_server:call({local, ?IBOT_CORE_SRV_PROJECT_INFO_LOADER}, {?LOAD_CORE_CONFIG}),
  load_info_from_core_config(),
  ok.


%% @doc
%%
%% Parse core.conf file
%% @spec load_info_from_core_config() -> ok | error.
%% @end

-spec load_info_from_core_config() -> ok | error.

load_info_from_core_config() ->
  case file:get_cwd() of %% get CORE path
    {ok, CorePath} ->
      ?DBG_MODULE_INFO("load_info_from_core_config() -> CorePath: ~p~n", [?MODULE, CorePath]),
      ?DBG_MODULE_INFO("load_info_from_core_config() -> Path Delim Symbol: ~p~n", [?MODULE, ?PATH_DELIMETER_SYMBOL]),
      ?DBG_MODULE_INFO("load_info_from_core_config() -> Full Path: ~p~n", [?MODULE, string:join([CorePath, "core.conf"], ?PATH_DELIMETER_SYMBOL)]),

      case file:read_file(string:join([CorePath, "core.conf"], ?PATH_DELIMETER_SYMBOL)) of %% try read core.conf file
        {ok, FileContent} ->
          ?DBG_MODULE_INFO("load_info_from_core_config() -> Core Config Content: ~p~n", [?MODULE, FileContent]),
          ?DBG_MODULE_INFO("load_info_from_core_config() -> jiffy:decode(FileContent): ~p~n", [?MODULE, jiffy:decode(FileContent)]),
          case jiffy:decode(FileContent) of %% Parse JSON from core.conf file
            {CoreConfigFileList} ->
              ?DBG_MODULE_INFO("read_node_config(NodeName) {ok, FileContent} = file:read_file(NodePath), -> ~p~n", [?MODULE, CoreConfigFileList]),
              FullProjectPath = create_core_config_record(CoreConfigFileList, #core_info{}), %% Parse core.conf
              load_project_config(FullProjectPath) %% Parse project.conf
          end,
          ok;
        _ -> error
      end;
    _ -> error
  end.


%% @doc
%%
%% Create core config record
%% @spec create_core_config_record([CoreInfo | CoreInfoList], CoreInfoRecord) -> string()
%% when CoreInfo :: term(), CoreInfoList :: list(), CoreInfoRecord :: #core_info{}.
%% @end

-spec create_core_config_record([CoreInfo | CoreInfoList], CoreInfoRecord) -> string()
  when CoreInfo :: term(), CoreInfoList :: list(), CoreInfoRecord :: #core_info{}.

create_core_config_record([], CoreInfoRecord) ->
  ibot_db_func_config:add_core_config_info(CoreInfoRecord),
  ?DBG_MODULE_INFO("create_core_config_record([], CoreInfoRecord) -> get from core config record db: ~p~n", [?MODULE, ibot_db_func_config:get_core_config_info()]),
  CoreInfoRecord#core_info.projectPath;
create_core_config_record([CoreInfo | CoreInfoList], CoreInfoRecord) ->
  {Key, Val} = CoreInfo,
  case Key of
    <<"projectPath">> ->
      ProjectPath = binary_to_list(Val), %% get full ptoject path from core.conf
      CoreInfoRecordNew = CoreInfoRecord#core_info{projectPath = ProjectPath}, %% set project path to core config report
      ibot_db_func_config:set_full_project_path(ProjectPath); %% set full project path to config db
    _ ->
      CoreInfoRecordNew = CoreInfoRecord,
      ok
  end,
  create_core_config_record(CoreInfoList, CoreInfoRecordNew).

%% ====== Read Core Configuraion File End ======





%% ====== Read Core Configuraion File Start ======

load_project_config(FullProjectPath) ->
  %%gen_server:call({local, ?IBOT_CORE_SRV_PROJECT_INFO_LOADER}, {?LOAD_PROJECT_CONFIG, FullProjectPath}),
  load_info_from_project_config(FullProjectPath),
  ok.

load_info_from_project_config(FullProjectPath) ->
  case file:read_file(string:join([FullProjectPath, "project.conf"], ?PATH_DELIMETER_SYMBOL)) of %% try read core.conf file
    {ok, FileContent} ->
      case jiffy:decode(FileContent) of %% Parse JSON from core.conf file
        {ProjectConfigFileList} ->
          ?DBG_MODULE_INFO("load_info_from_project_config(FullProjectPath) -> {ok, FileContent} = file:read_file(NodePath), -> ~p~n", [?MODULE, ProjectConfigFileList]),
          create_project_config_record(ProjectConfigFileList, #project_info{}), %% Parse project.config
          ibot_core_app:connect_to_project(FullProjectPath)
      end,
      ok;
    _ -> error
  end.

create_project_config_record([ProjectConfig | ProjectConfigList], ProjectConfigRecord) ->
  ok.

%% ====== Read Core Configuraion File End ======