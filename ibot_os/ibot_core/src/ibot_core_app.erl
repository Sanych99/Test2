-module(ibot_core_app).

-include("debug.hrl").
-include("../../ibot_db/include/ibot_db_table_names.hrl").
-include("../../ibot_db/include/ibot_db_project_config_param.hrl").
-include("ibot_core_create_project_paths.hrl").
-include("ibot_core_modules_names.hrl").

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).
-export([create_project/2, create_node/2, connect_to_project/1, get_project_nodes/0]).
-export([get_cur_dir/0]).
-export([add_node_name_to_config/1]).
-export([start_project/0, start_node/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    ibot_ri_app:start(normal, []),
    ibot_core_sup:start_link().

stop(_State) ->
    ibot_db_func:delete_table(?TABLE_CONFIG), %% Удаляем таблицу с данными конфируции проекта
    ok.


%% @doc Create project
%% @spec create_project(Dir, Path) -> ok | {error, Reason} when Dir :: string(), Path :: string().

-spec create_project(Dir, Path) -> ok | {error, Reason}
  when Dir :: string(), Path :: string(), Reason :: term().

create_project(Path, Dir) ->
  ibot_db_func:add(?TABLE_CONFIG,
    ?FULL_PROJECT_PATH, string:join([Path, Dir], ?DELIM_PATH_SYMBOL)), %% Add project full path to config
  ibot_core_func_cmd_cdir:create_project(Path, Dir). %% Create project directories


create_node(NodeName, NodeLang) -> ?DBG_MODULE_INFO("create_node(NodeName, NodeLang) NodeName: ~p, NodeLang: ~p ...........~n", [?MODULE, NodeName, NodeLang]),
  ibot_core_func_cmd_cdir:create_node(NodeName, list_to_atom(NodeLang)),
  ok.

connect_to_project(ProjectPath) ->
  ibot_db_func_config:set_full_project_path(ProjectPath),
  case ibot_core_app:get_project_nodes() of
    {error} -> error;
    {ok, ProjectNodes} ->
      parse_nodes_config_file(ProjectNodes),
      {ok, ExistingNodes} = get_project_nodes(),
      add_node_name_to_config(ExistingNodes),
      ok
  end.


%%% ====== parse_nodes_config_file mathod start ======

%% @doc
%%
%% Parse node config file
%% @end

parse_nodes_config_file([NodeItem | NodesList]) ->
  case ?PATH_TO_NODE(NodeItem) of
    ?ACTION_ERROR -> ?ACTION_ERROR;
    ?FULL_PROJECT_PATH_NOT_FOUND -> ?FULL_PROJECT_PATH_NOT_FOUND;
    NodePath ->
      case filelib:is_file(NodePath) of
        true -> gen_server:call(?IBOT_CORE_SRV_PROJECT_INFO_LOADER, {?LOAD_PROJECT_NODE_INFO, NodePath});
        false -> ?DBG_MODULE_INFO("parse_nodes_config_file([NodeItem | NodesList]) -> node ~p NOT FOUND... ~n", [?MODULE, NodePath])
      end
  end,
  parse_nodes_config_file(NodesList),
  ok;
parse_nodes_config_file([]) ->
  ok.

%%% ====== parse_nodes_config_file mathod end ======




%%% ====== get_project_nodes mathod start ======

%% @doc
%%
%% Get project nodes list
%% @end

get_project_nodes() ->
  ?DBG_MODULE_INFO("src folder: ~p~n", [?MODULE, string:join([ibot_db_func:get(?TABLE_CONFIG, ?FULL_PROJECT_PATH), ?SRC_FOLDER], "/")]),
  case ibot_db_func_config:get_full_project_path() of
    ?FULL_PROJECT_PATH_NOT_FOUND -> {?FULL_PROJECT_PATH_NOT_FOUND};
    ProjectPath ->
      ?DBG_MODULE_INFO("get_project_nodes() : ~p~n", [?MODULE, file:list_dir(string:join([ProjectPath, ?SRC_FOLDER], "/"))]),
      file:list_dir(string:join([ProjectPath, ?SRC_FOLDER], "/"))
  end.

%%% ====== get_project_nodes mathod end ======

add_node_name_to_config([NodeName| NodeNamesList])->
  ibot_db_func_config:add_node_name_to_config(NodeName),
  add_node_name_to_config(NodeNamesList),
  ok;
add_node_name_to_config([]) ->
  ?DBG_MODULE_INFO("add_node_name_to_config([]) -> ~p~n", [?MODULE, ibot_db_func_config:get_nodes_name_from_config()]),
  ok.

get_cur_dir() ->
  ?DBG_MODULE_INFO("get_cur_dir() -> ~p~n", [?MODULE, file:get_cwd()]).


start_project() ->
  Nodes = ibot_db_func_config:get_nodes_name_from_config(),
  ?DBG_MODULE_INFO("start_project() -> ~p~n", [?MODULE, Nodes]),
  run_project_node(Nodes),
  ok.

start_node(NodeName) ->
  run_project_node([NodeName]),
  ok.

run_project_node([NodeName | NodeNamesList]) ->
  gen_server:cast(ibot_nodes_srv_connector, {start_node, ibot_db_func_config:get_node_info(list_to_atom(NodeName))}),
  run_project_node(NodeNamesList);
run_project_node([]) ->
  ok.

