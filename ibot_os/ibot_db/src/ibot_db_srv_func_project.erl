%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. Jul 2015 2:48 AM
%%%-------------------------------------------------------------------
-module(ibot_db_srv_func_project).
-author("alex").

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-export([add_project_config_info/1, get_project_config_info/0, get_children_project_names_list/0]).

-include("../../ibot_core/include/debug.hrl").
-include("ibot_db_records.hrl").
-include("ibot_db_table_names.hrl").

-define(SERVER, ?MODULE).

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================


start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================


init([]) ->
  {ok, #state{}}.


handle_call({add_project_config_info, ProjectInfo}, _From, State) ->
  ibot_db_srv:add_record(?TABLE_CONFIG, project_config_info, ProjectInfo),
  {reply, ok, State};

handle_call({get_project_config_info}, _From, State) ->
  case ibot_db_srv:get_record(?TABLE_CONFIG, project_config_info) of
    record_not_found ->
      {reply, ok, State};
    {ok, ProjectInfo} ->
      {reply, ProjectInfo, State}
  end;

handle_call({get_children_project_names_list}, _From, State) ->
  case ibot_db_srv_func_project:get_project_config_info() of
    [] ->
      {reply, ok, State};
    ProjectInfo ->
      {reply, ProjectInfo#project_info.childrenProjectName, State}
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

%%% ====== Project Config Information Start ======

%% @doc
%%
%% Add information from project configuration file
%% @spec add_project_config_info(ProjectInfo) -> ok when ProjectInfo :: #project_info{}.
%% @end
-spec add_project_config_info(ProjectInfo) -> ok when ProjectInfo :: #project_info{}.

add_project_config_info(ProjectInfo) ->
  gen_server:call(ibot_db_srv_func_project, {add_project_config_info, ProjectInfo}),
  ok.

%% @doc
%%
%% Get information about project from DB
%% @spec get_project_config_info() -> [] | #project_info{}.
%% @end
-spec get_project_config_info() -> [] | #project_info{}.

get_project_config_info() ->
  gen_server:call(ibot_db_srv_func_project, {get_project_config_info}).


%%get_project_config_projectState() ->


get_children_project_names_list() ->
  ?DBG_MODULE_INFO("get_children_project_names_list() -> ~p~n", [?MODULE, get_project_config_info()]),
  gen_server:call(ibot_db_srv_func_project, {get_children_project_names_list}).
%%% ====== Project Config Information End ======