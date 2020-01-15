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

-export([add_project_config_info/1, get_project_config_info/0, get_project_config_info_in_sync/0,
  get_children_project_names_list/0, get_projectStatus/0]).

-include("..\\..\\ibot_core/include/debug.hrl").
-include("..\\..\\ibot_core/include/ibot_core_project_statuses.hrl").
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
  ?DBG_MODULE_INFO("add_project_config_info -> ~n", [?MODULE]),
  ibot_db_srv:add_record(?TABLE_CONFIG, project_config_info, ProjectInfo),
  {reply, ok, State};

handle_call({get_project_config_info}, _From, State) ->
  ?DBG_MODULE_INFO("get_project_config_info -> ~n", [?MODULE]),
  case ibot_db_srv:get_record(?TABLE_CONFIG, project_config_info) of
    record_not_found ->
      {reply, record_not_found, State};
    {ok, ProjectInfo} ->
      {reply, ProjectInfo, State}
  end;

handle_call({get_children_project_names_list}, _From, State) ->
  ?DBG_MODULE_INFO("get_children_project_names_list -> ~n", [?MODULE]),
  case ?MODULE:get_project_config_info_in_sync() of
    [] ->
      {reply, ok, State};
    ProjectInfo ->
      {reply, ProjectInfo#project_info.childrenProjectName, State}
  end;

handle_call(_Request, _From, State) ->
  ?DBG_MODULE_INFO("handle_call(_Request, _From, State) -> ~p~n", [?MODULE, _Request]),
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
%% Add information from project configuration file
%% @spec add_project_config_info(ProjectInfo) -> ok when ProjectInfo :: #project_info{}.
%% @end
-spec add_project_config_info(ProjectInfo) -> ok when ProjectInfo :: #project_info{}.

add_project_config_info(ProjectInfo) ->
  gen_server:call(?MODULE, {add_project_config_info, ProjectInfo}),
  ok.


%% @doc
%% Get information about project from DB
%% @spec get_project_config_info() -> [] | #project_info{}.
%% @end
-spec get_project_config_info() -> [] | #project_info{}.

get_project_config_info() ->
  gen_server:call(?MODULE, {get_project_config_info}).


%% @doc
%% Get information about project from DB
%% @spec get_project_config_info_in_sync() -> [] | #project_info{}.
%% @end
-spec get_project_config_info_in_sync() -> [] | #project_info{}.

get_project_config_info_in_sync() ->
  ?DMI("get_project_config_info_in_sync", ?ONLY_MESSAGE),
  case ibot_db_srv:get_record(?TABLE_CONFIG, project_config_info) of
    record_not_found ->
      [];
    {ok, ProjectInfo} ->
      ProjectInfo
  end.


%% @doc
%% Дочерние проекты / ядра / Children cores
%% @spec get_children_project_names_list() -> list() | ok.
%% @end
-spec get_children_project_names_list() -> list() | ok.

get_children_project_names_list() ->
  gen_server:call(?MODULE, {get_children_project_names_list}).
%%% ====== Project Config Information End ======


%% @doc
%% Статус ядра: разработка / релиз / Core state: develop / release
%% @spec get_projectStatus() -> atom(). develop / release
%% @end
-spec get_projectStatus() -> atom().

get_projectStatus() ->
  case ?MODULE:get_project_config_info() of
    record_not_found -> ?DEVELOP; %% по умолчанию статус равен develop
    ProjectInfoRecord ->
      %% передаем найденный статус
      ProjectInfoRecord#project_info.projectState
  end.