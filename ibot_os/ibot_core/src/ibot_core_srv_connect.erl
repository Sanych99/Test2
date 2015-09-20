%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. May 2015 1:00 AM
%%%-------------------------------------------------------------------
-module(ibot_core_srv_connect).
-author("alex").

-behaviour(gen_server).

-include("debug.hrl").
-include("../../ibot_db/include/ibot_db_records.hrl").

%% API
-export([start_link/0]).
-export([
  connect_to_distributed_projects/0 %% подключить к дочерним распределенным проектам
]).
-export([
  connect_to_other_cores/1, %% подключить к дочерним распределенным проектам
  disconnect_from_other_core/1 %% отключение от дочерних распределенных проектов
]).

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

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================


init([]) ->
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

%% @doc
%% Соединение с распределенными ядрами / Connect to distiduted cores
%% @spec connect_to_distributed_projects() -> ok.
%% @end
-spec connect_to_distributed_projects() -> ok.

connect_to_distributed_projects() ->
  connect_to_node_list(ibot_db_srv_func_project:get_children_project_names_list()),
  ok.


%% @doc
%% Соединение с распределенными ядрами / Connect to distiduted cores
%% @spec connect_to_node_list([NodeName | NodeList]) -> ok
%% when NodeName :: atom(), NodeList :: list().
%% @end
-spec connect_to_node_list([NodeName | NodeList]) -> ok
  when NodeName :: atom(), NodeList :: list().

connect_to_node_list([]) ->
  ok;
connect_to_node_list([NodeName | NodeList]) ->
  connect_to_node(NodeName),
  connect_to_node_list(NodeList).


%% @doc
%% Соединение с ядром / Connect to core
%% @spec connect_to_node(Node) -> ping | pang when Node :: atom().
%% @end
-spec connect_to_node(Node) -> ping | pang when Node :: atom().

connect_to_node(Node) ->
  ?DMI("connect_to_node(Node) ", [Node]),
  net_adm:ping(Node).




%% ====== ibot_core_func_connect_to_cores.erl file Start ======

%% @doc
%% Connect to cores
%% @spec connect_to_other_cores([OtherCoreName | OtherCoreNamesList]) -> ok
%% when OtherCoreName :: atom(), OtherCoreNamesList :: list().
%% @end
-spec connect_to_other_cores([OtherCoreName | OtherCoreNamesList]) -> ok
  when OtherCoreName :: atom(), OtherCoreNamesList :: list().

connect_to_other_cores([OtherCoreName | OtherCoreNamesList]) ->
  connect_to_other_core(OtherCoreName),
  connect_to_other_cores(OtherCoreNamesList);
connect_to_other_cores([]) -> ok.


%% @doc
%% Connect to other core
%% @spec connect_to_other_core(OtherCoreName) -> ok | error when OtherCoreName :: atom().
%% @end
-spec connect_to_other_core(OtherCoreName) -> ok | error when OtherCoreName :: atom().

connect_to_other_core(OtherCoreName) ->
  case net_adm:ping(OtherCoreName) of
    pong-> ok;
    pang -> error
  end.

%% @doc
%% Disconnect from other core
%% @spec disconnect_from_other_core(OtherCorename) -> oboolean() | ignored when OtherCorename :: node().
%% @end
-spec disconnect_from_other_core(OtherCorename) -> boolean() | ignored when OtherCorename :: node().

disconnect_from_other_core(OtherCorename) ->
  erlang:disconnect_node(OtherCorename).

%% ====== ibot_core_func_connect_to_cores.erl file End ======