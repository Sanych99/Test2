%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015
%%% @doc
%%%
%%% @end
%%% Created : 13. May 2015 12:01 AM
%%%-------------------------------------------------------------------
-module(ibot_core_func_connect_to_cores).

%% API
-export([connect_to_other_cores/1, disconnect_from_other_core/1]).

%% @doc
%%
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
%%
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
%%
%% Disconnect from other core
%% @spec disconnect_from_other_core(OtherCorename) -> oboolean() | ignored when OtherCorename :: node().
%% @end
-spec disconnect_from_other_core(OtherCorename) -> boolean() | ignored when OtherCorename :: node().
disconnect_from_other_core(OtherCorename) ->
  erlang:disconnect_node(OtherCorename).