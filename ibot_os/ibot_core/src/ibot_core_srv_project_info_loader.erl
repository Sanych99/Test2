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

%% API
-export([start_link/0]).

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
          string:join(["/usr/lib/erlang/lib/jinterface-1.5.12/priv/OtpErlang.jar:/home/alex/iBotOS/RobotOS/_RobOS/test/nodes/java:/home/alex/iBotOS/iBotOS/JLib/lib/Node.jar:/home/alex/ErlangTest/test_from_bowser/dev/msg/java:/home/alex/ErlangTest/test_from_bowser/dev/nodes/", StrVal], "")],
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