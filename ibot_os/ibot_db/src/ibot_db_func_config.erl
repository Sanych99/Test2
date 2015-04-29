%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. Mar 2015 8:14 PM
%%%-------------------------------------------------------------------
-module(ibot_db_func_config).

-include("../../ibot_core/include/debug.hrl").
-include("ibot_db_reserve_atoms.hrl").
-include("ibot_db_table_names.hrl").
-include("ibot_db_project_config_param.hrl").
-include("../../ibot_core/include/ibot_core_reserve_atoms.hrl").
-include("../../ibot_nodes/include/ibot_nodes_registration_info.hrl").
-include("ibot_db_modules.hrl").
-include("ibot_db_table_commands.hrl").

%% API
-export([get_full_project_path/0, set_full_project_path/1, set_node_info/1, get_node_info/1, get_all_registered_nodes/0]).
-export([add_node_name_to_config/1, get_nodes_name_from_config/0]).


%%% ====== full project path mathods start ======

%% @doc
%% Get project path from config db
%%
%% @spec get_full_project_path() -> [{?FULL_PROJECT_PATH, string()}] | ?FULL_PROJECT_PATH_NOT_FOUND | ?ACTION_ERROR.
%% @end

-spec get_full_project_path() -> [{?FULL_PROJECT_PATH, string()}] | ?FULL_PROJECT_PATH_NOT_FOUND | ?ACTION_ERROR.

get_full_project_path() ->
  case gen_server:call(?IBOT_DB_SRV, {?GET_RECORD, ?TABLE_CONFIG, ?FULL_PROJECT_PATH}) of
    {ok, Full_Project_Path} ->  ?DBG_MODULE_INFO("get_full_project_path: ~p~n", [?MODULE, Full_Project_Path]),
      Full_Project_Path;
    [] -> ?FULL_PROJECT_PATH_NOT_FOUND
  end.


%% @doc
%% Set project path from config db
%%
%% @spec set_full_project_path(ProjectPath) -> ok when ProjectPath :: string().
%% @end

-spec set_full_project_path(ProjectPath) -> ok when ProjectPath :: string().

set_full_project_path(ProjectPath) ->
  ?DBG_MODULE_INFO("set_full_project_path(ProjectPath) -> ~p~n", [?MODULE, ProjectPath]),
  gen_server:call(?IBOT_DB_SRV, {?ADD_RECORD, ?TABLE_CONFIG, ?FULL_PROJECT_PATH, ProjectPath}),
  ok.

%%% ====== full project path mathods end ======


add_node_name_to_config(NodeName) ->
  case gen_server:call(?IBOT_DB_SRV, {?GET_RECORD, ?TABLE_CONFIG, ?PROJECT_NODES_LIST}) of
    {ok, ConfigNodeNamesList} ->
      gen_server:call(?IBOT_DB_SRV, {?ADD_RECORD, ?TABLE_CONFIG, ?PROJECT_NODES_LIST, lists:append(ConfigNodeNamesList, [NodeName])});

    Vals -> ?DBG_MODULE_INFO("add_node_name_to_config(NodeName) Vals ->...~p~n", [? MODULE, Vals]),
      gen_server:call(?IBOT_DB_SRV, {?ADD_RECORD, ?TABLE_CONFIG, ?PROJECT_NODES_LIST, [NodeName]})
  end,
  ok.

get_nodes_name_from_config() ->
  ?DBG_MODULE_INFO("get_node_name_from_config() -> ~p~n", [?MODULE, gen_server:call(?IBOT_DB_SRV, {?GET_RECORD, ?TABLE_CONFIG, ?PROJECT_NODES_LIST})]),
  %gen_server:call(?IBOT_DB_SRV, {?GET_RECORD, ?TABLE_CONFIG, ?PROJECT_NODES_LIST}).
  case ibot_db_srv:get_record(?TABLE_CONFIG, ?PROJECT_NODES_LIST) of
    {ok, NodesNameList} -> NodesNameList;
    _ -> error
  end.




set_node_info(NodeInfoRecord) ->
  ibot_db_func:add_to_mnesia(NodeInfoRecord),
  %ibot_db_srv:add_record(?TABLE_NODE_INFO, NodeInfoRecord#node_info.atomNodeName, NodeInfoRecord),
  ?DBG_MODULE_INFO("set_node_info(NodeInfoRecord) -> -> ~p~n", [?MODULE, NodeInfoRecord]),
  ok.

get_node_info(AtomNodeName) ->
  %?DBG_MODULE_INFO("get_node_info(AtomNodeName) -> ~p~n", [?MODULE, ibot_db_srv:get_record(?TABLE_NODE_INFO, AtomNodeName)]),
  %case ibot_db_srv:get_record(?TABLE_NODE_INFO, AtomNodeName) of
  %  {ok, NodeInfoRecord} -> NodeInfoRecord;
  %  [] -> ?NODE_INFO_NOT_FOUND;
  %  _ -> ?ACTION_ERROR
  %end.
  ?DBG_MODULE_INFO("get_node_info(AtomNodeName) -> ~p~n", [?MODULE, ibot_db_func:get_from_mnesia(node_info, AtomNodeName)]),
  case ibot_db_func:get_from_mnesia(node_info, AtomNodeName) of
    [] -> not_found;
    {atomic, [Vals]} -> Vals
  end.

get_all_registered_nodes() ->
  ok.