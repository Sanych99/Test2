%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015
%%% @doc
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

handle_call({?LOAD_PROJECT_ALL_NODES_INFO}, _From, State) ->
  case ibot_db_func_config:get_full_project_path() of
    ?ACTION_ERROR -> {reply, {?ACTION_ERROR}, State};
    ?FULL_PROJECT_PATH_NOT_FOUND -> {reply, {?FULL_PROJECT_PATH_NOT_FOUND}, State};
    ProjectPath ->
      %% load nodes information to db
      {reply, {ok, ProjectPath}, State}
  end;
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

read_node_config(NodePath) ->
  ?DBG_MODULE_INFO("read_node_config(NodeName) -> ~p~n", [?MODULE, {NodePath}]),
  ?DBG_MODULE_INFO("read_node_config(NodeName) NodePath -> ~p~n", [?MODULE, NodePath]),
  {ok, FileContent} = file:read_file(NodePath),
  ?DBG_MODULE_INFO("read_node_config(NodeName) {ok, FileContent} = file:read_file(NodePath), -> ~n", [?MODULE]),
  case jiffy:decode(FileContent) of
    {NodeConfigFileList} ->
      ?DBG_MODULE_INFO("read_node_config(NodeName) {ok, FileContent} = file:read_file(NodePath), -> ~p~n", [?MODULE, NodeConfigFileList]),
      create_node_config_record(NodeConfigFileList, #node_info{})
  end,
  ok.


create_node_config_record([NodeConfigItem | NodeConfigList], NodeConfigRecord) ->
  {Key, Val} = NodeConfigItem,
  case Key of
    <<"nodeName">> ->
      StrVal = binary_to_list(Val),
      NewNodeConfigRecord = NodeConfigRecord#node_info{nodeName = StrVal, atomNodeName = list_to_atom(StrVal)};
    <<"nodeLang">> ->
      StrVal = binary_to_list(Val),
      NewNodeConfigRecord = NodeConfigRecord#node_info{nodeLang = StrVal, atomNodeLang = list_to_atom(StrVal)};
    <<"runPreAgruments">> ->
      StrVal = binary_to_list(Val),
      NewNodeConfigRecord = NodeConfigRecord#node_info{nodePreArguments = StrVal};
    <<"runPostArguments">> ->
      StrVal = binary_to_list(Val),
      NewNodeConfigRecord = NodeConfigRecord#node_info{nodePostArguments = StrVal}
  end,
  create_node_config_record(NodeConfigList, NewNodeConfigRecord);
create_node_config_record([], NodeConfigRecord) ->
  ?DBG_MODULE_INFO("create_node_config_record([], NodeConfigRecord) -> ~p~n", [?MODULE, NodeConfigRecord]),
  ibot_db_func_config:set_node_info(NodeConfigRecord),
  ok.