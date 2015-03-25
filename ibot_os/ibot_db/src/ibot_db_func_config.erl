%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. Mar 2015 8:14 PM
%%%-------------------------------------------------------------------
-module(ibot_db_func_config).
-author("alex").

-include("../../ibot_core/include/debug.hrl").
-include("ibot_db_reserve_atoms.hrl").
-include("ibot_db_table_names.hrl").
-include("ibot_db_project_config_param.hrl").
-include("../../ibot_core/include/ibot_core_reserve_atoms.hrl").
-include("../../ibot_nodes/include/ibot_nodes_registration_info.hrl").

%% API
-export([get_full_project_path/0, set_full_project_path/1, set_node_info/1, get_node_info/1]).

%% @doc
%% Get project path from config db
%%
%% @spec get_full_project_path() -> [{?FULL_PROJECT_PATH, string()}] | ?FULL_PROJECT_PATH_NOT_FOUND | ?ACTION_ERROR.
%% @end

-spec get_full_project_path() -> [{?FULL_PROJECT_PATH, string()}] | ?FULL_PROJECT_PATH_NOT_FOUND | ?ACTION_ERROR.

get_full_project_path() ->
  case ibot_db_func:get(?TABLE_CONFIG, ?FULL_PROJECT_PATH) of
    [{?FULL_PROJECT_PATH, ProjectPath}] -> ProjectPath;
    [] -> ?FULL_PROJECT_PATH_NOT_FOUND;
    _ -> ?ACTION_ERROR
  end.


%% @doc
%% Set project path from config db
%%
%% @spec set_full_project_path(ProjectPath) -> ok when ProjectPath :: string().
%% @end

-spec set_full_project_path(ProjectPath) -> ok when ProjectPath :: string().

set_full_project_path(ProjectPath) ->
  ibot_db_func:add(?TABLE_CONFIG,
    ?FULL_PROJECT_PATH, ProjectPath),
  ok.




set_node_info(NodeInfoRecord) ->
  ibot_db_func:add(?TABLE_NODE_INFO, NodeInfoRecord#node_info.atomNodeName, NodeInfoRecord),
  ?DBG_MODULE_INFO("set_node_info(NodeInfoRecord) -> -> ~p~n", [?MODULE, NodeInfoRecord]),
  ok.

get_node_info(AtomNodeName) ->
  case ibot_db_func:get(?TABLE_NODE_INFO, AtomNodeName) of
    [{AtomNodeName, NodeInfoRecord}] -> NodeInfoRecord;
    [] -> ?NODE_INFO_NOT_FOUND;
    _ -> ?ACTION_ERROR
  end.