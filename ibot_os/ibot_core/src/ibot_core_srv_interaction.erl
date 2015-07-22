%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. May 2015 1:13 AM
%%%-------------------------------------------------------------------
-module(ibot_core_srv_interaction).
-author("alex").

-behaviour(gen_server).

-include("debug.hrl").
-include("ibot_core_modules_names.hrl").
-include("../../ibot_db/include/ibot_db_records.hrl").

%% API
-export([start_link/0]).
-export([start_distribute_db/0, stop_distribute_db/0]).
-export([all_children_projects_start_distribute_db/0, all_children_projects_stop_distribute_db/0]).
-export([connect_to_distribute_project/0, connect_to_project/0]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {}).


start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).


init([]) ->
  timer:apply_after(7000, ?IBOT_CORE_SRV_INTERACTION, connect_to_distribute_project, []),
  %?DBG_MODULE_INFO("init([]) -> after 7 seconds..............", [?MODULE]),
  {ok, #state{}}.


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

start_distribute_db() ->
  ibot_db_srv:start_distibuted_db().

stop_distribute_db() ->
  ibot_db_srv:stop_distributed_db().


connect_to_project() ->
  ibot_core_app:connect_to_project(ibot_db_func_config:get_full_project_path()).


start_chiled_core() ->
  rpc:multicall(ibot_db_srv_func_project:get_children_project_names_list(), ibot_core_srv_interaction, connect_to_project, []).



all_children_projects_start_distribute_db() ->
  rpc:multicall(ibot_db_srv_func_project:get_children_project_names_list(), ibot_core_srv_interaction, start_distribute_db, []).

all_children_projects_stop_distribute_db() ->
  rpc:multicall(ibot_db_srv_func_project:get_children_project_names_list(), ibot_core_srv_interaction, stop_distribute_db, []).


connect_to_distribute_project() ->
  case mnesia:stop() of
    _ ->
      mnesia:delete_schema([node()]), % Remove local mnesia schema
      case ibot_db_srv_func_project:get_project_config_info() of
        record_not_found ->
          ok;

        ProjectInfo ->
          case ProjectInfo#project_info.mainProject of
            true ->
                  ibot_core_srv_connect:connect_to_distributed_projects(),
                  ibot_db_srv:create_distributed_shema(),
                  all_children_projects_start_distribute_db(),
                  case mnesia:start() of
                    Res when Res == {error, {already_started, mnesia}}; Res == ok ->
                      ibot_db_srv:create_distributed_tables(),
                      start_chiled_core(),
                      connect_to_project();

                    {error, Result} ->
                      ?DBG_MODULE_INFO("connect_to_distribute_project() -> fail start mnesia ~p~n", [?MODULE, Result])
                  end;

          _Other -> ok
          end
      end
  end.

