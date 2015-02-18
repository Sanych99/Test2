-module(ibot_core_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).
-export([create_project/2]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    ibot_core_sup:start_link().

stop(_State) ->
    ok.

%% @doc Create project
%% @spec create_project(Dir, Path) -> ok | {error, Reason} when Dir :: string(), Path :: string().
-spec create_project(Dir, Path) -> ok | {error, Reason}
  when Dir :: string(), Path :: string(), Reason :: term().
create_project(Path, Dir) ->
  ibot_core_cmd_cdir:create_project(Path, Dir).

