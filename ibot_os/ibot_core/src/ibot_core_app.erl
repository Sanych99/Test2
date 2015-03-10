-module(ibot_core_app).

-include("debug.hrl").
-include("config_db_keys.hrl").
-include("env_params.hrl").
-include("ibot_gen_srvs.hrl").
-include("ibot_table_names.hrl").

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).
-export([create_project/2, create_node/2]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    ibot_core_sup:start_link().

stop(_State) ->
    ibot_core_db_srv:delete_table(?TABLE_CONFIG), %% Удаляем таблицу с данными конфируции проекта
    ok.


%% @doc Create project
%% @spec create_project(Dir, Path) -> ok | {error, Reason} when Dir :: string(), Path :: string().

-spec create_project(Dir, Path) -> ok | {error, Reason}
  when Dir :: string(), Path :: string(), Reason :: term().

create_project(Path, Dir) ->
  ibot_core_db_srv:add_record(?TABLE_CONFIG,
    ?FULL_PROJECT_PATH, string:join([Path, Dir], ?DELIM_PATH_SYMBOL)), %% Add project full path to config
  ibot_core_cmd_cdir:create_project(Path, Dir). %% Create project directories


create_node(NodeName, NodeLang) ->
  ?DBG_INFO("func create_node NodeName: ~p, NodeLang: ~p ...........~n", [NodeName, NodeLang]),
  ibot_core_cmd_cdir:create_node(NodeName, list_to_atom(NodeLang)),
  ok.
