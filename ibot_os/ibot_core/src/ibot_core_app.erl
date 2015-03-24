-module(ibot_core_app).

-include("debug.hrl").
-include("env_params.hrl").
-include("../../ibot_db/include/ibot_db_table_names.hrl").
-include("../../ibot_db/include/ibot_db_project_config_param.hrl").

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).
-export([create_project/2, create_node/2, connect_to_project/1, get_project_nodes/0]).

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
  ibot_core_cmd_cdir:create_project(Path, Dir). %% Create project directories


create_node(NodeName, NodeLang) -> ?DBG_MODULE_INFO("create_node(NodeName, NodeLang) NodeName: ~p, NodeLang: ~p ...........~n", [?MODULE, NodeName, NodeLang]),
  ibot_core_cmd_cdir:create_node(NodeName, list_to_atom(NodeLang)),
  ok.

connect_to_project(ProjectPath) ->
  ibot_db_func:add(?TABLE_CONFIG,
    ?FULL_PROJECT_PATH, ProjectPath),
  ok.

get_project_nodes() ->
  ?DBG_MODULE_INFO("src folder: ~p~n", [?MODULE, string:join([ibot_db_func:get(?TABLE_CONFIG, ?FULL_PROJECT_PATH), ?SRC_FOLDER], "/")]),
  case ibot_db_func:get(?TABLE_CONFIG, ?FULL_PROJECT_PATH) of
    [{?FULL_PROJECT_PATH, ProjectPath}] ->
      ?DBG_MODULE_INFO("get_project_nodes() : ~p~n", [?MODULE, file:list_dir(string:join([ProjectPath, ?SRC_FOLDER], "/"))]),
      file:list_dir(string:join([ProjectPath, ?SRC_FOLDER], "/"));
    _ -> {error}
  end.
