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
-export([load_core_config/0, load_project_config/1, load_info_from_core_config/0]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-export([read_node_config/1]).
-export([create_node_config_record/2, parse_msg_srv_file_list_from_config/2, load_info_from_core_config/0,
  create_core_config_record/2, load_info_from_project_config/1, create_project_config_record/2,
  parse_project_config_children_projects/2, parse_children_list/3, parse_project_node_list/1]).


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
  ibot_core_srv_project_info_loader:load_info_from_core_config(),
  {reply, ok, State};
handle_call({?LOAD_PROJECT_CONFIG, FullProjectPath}, _From, State) ->
  ibot_core_srv_project_info_loader:load_info_from_project_config(FullProjectPath),
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


%% ====== Read node config file Start ======

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
      ?DMI("read_node_config(NodeName) {ok, FileContent} = file:read_file(NodePath)", [NodeConfigFileList]),
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
          string:join(["/usr/lib/erlang/lib/jinterface-1.5.12/priv/OtpErlang.jar:/home/alex/iBotOS/RobotOS/_RobOS/test/nodes/java:/home/alex/iBotOS/iBotOS/JLib/lib/Node.jar:", ibot_db_func_config:get_full_project_path(),"/dev/msg/java:", ibot_db_func_config:get_full_project_path(),"/dev/nodes/", StrVal], "")],
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
    <<"msgFileList">> ->
      NewNodeConfigRecord = NodeConfigRecord#node_info{messageFile = parse_msg_srv_file_list_from_config(Val, [])};
    <<"srvFileList">> ->
      NewNodeConfigRecord = NodeConfigRecord#node_info{serviceFile = parse_msg_srv_file_list_from_config(Val, [])};
    Other ->
      ?DMI("try monitor other | val", [Other, Val]),
      NewNodeConfigRecord = NodeConfigRecord
  end,
  ibot_core_srv_project_info_loader:create_node_config_record(NodeConfigList, NewNodeConfigRecord);
create_node_config_record([], NodeConfigRecord) ->
  %?DBG_MODULE_INFO("create_node_config_record([], NodeConfigRecord) -> ~p~n", [?MODULE, NodeConfigRecord]),
  ibot_db_func_config:set_node_info(NodeConfigRecord),
  ok.


%% @doc
%% Parse message and servise file list from node config file
%% @spec parse_msg_srv_file_list_from_config([FileName | FileNameList], FileList) -> FileList
%% when FileList :: list(), FileName :: binary(), FileNameList :: list().
%% @end

-spec parse_msg_srv_file_list_from_config([FileName | FileNameList], FileList) -> FileList
  when FileList :: list(), FileName :: binary(), FileNameList :: list().

parse_msg_srv_file_list_from_config([], FileList) ->
  ?DMI("parse_msg_srv_file_list_from_config([FileName | FileNameList], FileList)", [FileList]),
  FileList;
parse_msg_srv_file_list_from_config([FileName | FileNameList], FileList) ->
  NewFileList = lists:append(FileList, [binary_to_list(FileName)]),
  ibot_core_srv_project_info_loader:parse_msg_srv_file_list_from_config(FileNameList, NewFileList).

%% ====== Read node config file End ======


%% ====== Read Core Configuraion File Start ======

%% @doc API load core info
%% @spec load_core_config() -> ok.
%% @end
-spec load_core_config() -> ok.

load_core_config() ->
  ?DBG_MODULE_INFO("load_core_config() -> ...~n", [?MODULE]),
  ibot_core_srv_project_info_loader:load_info_from_core_config(), %% Parse core.conf file

  %% todo  Создание схемы расределенной бд. Запуск Mnesia.
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
              ibot_core_srv_project_info_loader:load_project_config(FullProjectPath) %% Parse project.conf
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





%% ====== Read Project Configuraion File Start ======

%% @doc
%%
%% load project configuration
%% @spec load_project_config(FullProjectPath) -> ok when FullProjectPath :: string().
%% @end
-spec load_project_config(FullProjectPath) -> ok when FullProjectPath :: string().

load_project_config(FullProjectPath) ->
  %%gen_server:call({local, ?IBOT_CORE_SRV_PROJECT_INFO_LOADER}, {?LOAD_PROJECT_CONFIG, FullProjectPath}),
  ibot_core_srv_project_info_loader:load_info_from_project_config(FullProjectPath),
  ok.



%% @doc
%%
%% Read project configuration file
%% @spec load_info_from_project_config(FullProjectPath) -> ok | error when FullProjectPath :: string().
%% @end
-spec load_info_from_project_config(FullProjectPath) -> ok | error when FullProjectPath :: string().

load_info_from_project_config(FullProjectPath) ->
  %?DBG_MODULE_INFO("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", [?MODULE]),
  %ibot_core_app:connect_to_project(FullProjectPath),
  ?DBG_MODULE_INFO("load_info_from_project_config(FullProjectPath) -> ~p~n", [?MODULE, string:join([FullProjectPath, "project.conf"], ?PATH_DELIMETER_SYMBOL)]),
  ?DBG_MODULE_INFO("load_info_from_project_config(FullProjectPath) -> FileContent: ~p~n", [?MODULE, file:read_file(string:join([FullProjectPath, "project.conf"], ?PATH_DELIMETER_SYMBOL))]),
  case file:read_file(string:join([FullProjectPath, "project.conf"], ?PATH_DELIMETER_SYMBOL)) of %% try read core.conf file
    {ok, FileContent} ->
      case jiffy:decode(FileContent) of %% Parse JSON from core.conf file
        {ProjectConfigFileList} ->
          ?DBG_MODULE_INFO("load_info_from_project_config(FullProjectPath) -> {ok, FileContent} = file:read_file(NodePath), -> ~p~n", [?MODULE, ProjectConfigFileList]),
          ?DBG_MODULE_INFO("load_info_from_project_config(FullProjectPath) -> , -> ~p~n", [?MODULE, FullProjectPath]),
          ibot_core_srv_project_info_loader:create_project_config_record(ProjectConfigFileList, #project_info{}) %% Parse project.config
          %ibot_core_app:connect_to_project(FullProjectPath)
      end,
      ok;
    _ -> error
  end.



%% @doc
%%
%% Parse and save project configuration info
%% @spec create_project_config_record([ProjectConfig | ProjectConfigList], ProjectConfigRecord) -> ok
%% when ProjectConfig :: term(), ProjectConfigList :: list(), ProjectConfigRecord :: #project_info{}.
%% @end
-spec create_project_config_record([ProjectConfig | ProjectConfigList], ProjectConfigRecord) -> ok
  when ProjectConfig :: term(), ProjectConfigList :: list(), ProjectConfigRecord :: #project_info{}.

create_project_config_record([ProjectConfig | ProjectConfigList], ProjectConfigRecord) ->
  {Key, Val} = ProjectConfig,
  ?DBG_INFO("===> ~p~n", [ProjectConfig]),
  case Key of
    <<"projectName">> -> %% Имя проекта (Project name)
      ProjectNameStr = binary_to_list(Val),
      ProjectInfoRecordNew = ProjectConfigRecord#project_info{projectName = ProjectNameStr, projectNameAtom = list_to_atom(ProjectNameStr)}; %% project name
    <<"mainProject">> -> %% Проект является родительским (Project is parent)
      ProjectInfoRecordNew = ProjectConfigRecord#project_info{mainProject = case binary_to_list(Val) of
                                                                              "false" -> false;
                                                                              _ -> true
                                                                            end}; %% main project
    <<"distributedProject">> -> %% Проект распределенный (Project is destributed)
      ProjectInfoRecordNew = ProjectConfigRecord#project_info{distributedProject = case binary_to_list(Val) of
                                                                              "false" -> false;
                                                                              _ -> true
                                                                            end}; %% distributed project
    <<"projectAutoRun">> -> %% Автозапуск узлов после запуска ядра (Auto run nodes)
      ProjectInfoRecordNew = ProjectConfigRecord#project_info{projectAutoRun = case binary_to_list(Val) of
                                                                                     "false" -> false;
                                                                                     _ -> true
                                                                                   end}; %% distributed project
    <<"childrenProjects">> ->
      %[{[{V1, V2}]}] = Val,
      ?DBG_MODULE_INFO("create_project_config_record -> ~p~n",[?MODULE, {Val}]),
      ProjectInfoRecordNew = ibot_core_srv_project_info_loader:parse_project_config_children_projects(Val, ProjectConfigRecord);

    <<"projectState">> ->
      ?DBG_MODULE_INFO("create_project_config_record : projectState -> ~p~n",[?MODULE, {Val}]),
      ProjectInfoRecordNew = ProjectConfigRecord#project_info{projectState = binary_to_atom(Val, utf8)};

    <<"projectNodes">> ->
      ProjectInfoRecordNew = ProjectConfigRecord,
      ibot_core_srv_project_info_loader:parse_project_node_list(Val);
      %ChildrenProjects = 0,
      %ProjectInfoRecordNew =
      %  ProjectConfigRecord#project_info{childrenProjects = [ProjectConfigRecord#project_info.childrenProjects
      %    | ChildrenProjects]};

    %[{[{<<"projectName">>,<<"Test1@alex-N55A">>}]},
    %  {[{<<"projectName">>,<<"Test2@alex-N55A">>}]}]

    _ ->
      ProjectInfoRecordNew = ProjectConfigRecord
  end,
  create_project_config_record(ProjectConfigList, ProjectInfoRecordNew);

create_project_config_record([], ProjectInfoRecord) ->
  ?DBG_MODULE_INFO("create_project_config_record([], ProjectInfoRecord) -> ProjectInfoRecord: ~p~n", [?MODULE, ProjectInfoRecord]),
  ibot_db_srv_func_project:add_project_config_info(ProjectInfoRecord),
  ok.


parse_project_config_children_projects([], ProjectConfigRecord) ->
  ?DBG_MODULE_INFO("parse_project_config_children_projects([], ProjectConfigRecord) -> ~p~n", [?MODULE, ProjectConfigRecord]),
  ProjectConfigRecord;
parse_project_config_children_projects([{ChildrenProject} | ChildrenProjectList], ProjectConfigRecord) ->
  ?DBG_MODULE_INFO("parse_project_config_children_projects -> ~p~n", [?MODULE, ChildrenProject]),
  ProjectConfigRecordNew = parse_children_list(ChildrenProject, ProjectConfigRecord, #project_children{}),
  parse_project_config_children_projects(ChildrenProjectList, ProjectConfigRecordNew).

parse_children_list([], ProjectConfigRecord, ChildrenRecord) ->
  ?DBG_MODULE_INFO("parse_children_list FINAL -> ~p~n", [?MODULE, ProjectConfigRecord]),
  ?DBG_MODULE_INFO("parse_children_list FINAL -> ~p~n", [?MODULE, ProjectConfigRecord#project_info{childrenProjects = lists:append(ProjectConfigRecord#project_info.childrenProjects, [ChildrenRecord])}]),
  ProjectConfigRecord#project_info{childrenProjects = lists:append(ProjectConfigRecord#project_info.childrenProjects, [ChildrenRecord])};
parse_children_list([Children | ChildrenList], ProjectConfigRecord, ChildrenRecord) ->
  {Key, Val} = Children,
  case Key of
    <<"projectName">> ->
      StrVal = binary_to_list(Val),
      AtomVal = list_to_atom(StrVal),
      ChildrenRecordNew = ChildrenRecord#project_children{childrenName = StrVal, childrenNameAtom = AtomVal},
      ProjectConfigRecordNew = ProjectConfigRecord#project_info{childrenProjectName = lists:append(ProjectConfigRecord#project_info.childrenProjectName, [AtomVal])};
    _ ->
      ChildrenRecordNew = ChildrenRecord,
      ProjectConfigRecordNew = ProjectConfigRecord
  end,
  ?DBG_MODULE_INFO("parse_children_list -> ~p~n", [?MODULE, ChildrenRecordNew]),
  parse_children_list(ChildrenList, ProjectConfigRecordNew, ChildrenRecordNew).


parse_project_node_list([]) ->
  ok;
parse_project_node_list([NodeName | NodeNameList]) ->
  ibot_db_func_config:add_node_name_to_config(binary_to_list(NodeName)),
  ibot_core_srv_project_info_loader:parse_project_node_list(NodeNameList).
%% ====== Read Project Configuraion File End ======