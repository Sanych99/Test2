-module(ibot_core_app).

-include("debug.hrl").
-include("config_db_keys.hrl").
-include("env_params.hrl").

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).
-export([create_project/2, create_node/2]).
-export([add/2, look/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    ibot_core_sup:start_link().

stop(_State) ->
    ibot_core_config_db:delete_db(),
    ok.


%% @doc Create project
%% @spec create_project(Dir, Path) -> ok | {error, Reason} when Dir :: string(), Path :: string().

-spec create_project(Dir, Path) -> ok | {error, Reason}
  when Dir :: string(), Path :: string(), Reason :: term().

create_project(Path, Dir) ->
  set_project_path(string:join([Path, Dir], ?DELIM_PATH_SYMBOL)),
  ibot_core_cmd_cdir:create_project(Path, Dir).


create_node(NodeName, NodeLang) ->
  ?DBG_INFO("func create_node NodeName: ~p, NodeLang: ~p ...........~n", [NodeName, NodeLang]),
  ibot_core_cmd_cdir:create_node(NodeName, list_to_atom(NodeLang)),
  ok.

set_project_path(Path) ->
  ?DBG_INFO("func set_project_path, Path: ~p ...........~n", [Path]),
  ibot_core_config_db:add(?FULL_PROJECT_PATH, Path),
  ok.

add(Key, Value) ->
  ibot_core_config_db:add(Key, Value).

look(Key) ->
  ibot_core_config_db:get(Key).
