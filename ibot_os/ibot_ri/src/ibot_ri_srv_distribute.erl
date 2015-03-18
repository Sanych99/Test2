%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. Mar 2015 1:17 AM
%%%-------------------------------------------------------------------
-module(ibot_ri_srv_distribute).
-author("alex").

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).
-define(IBOT_RI_RESPONSE_TIMEOUT, 5000).

-include("../../ibot_core/include/debug.hrl").
-include("ibot_ri_command.hrl").

-record(state, {}).


start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).


init([]) ->
  {ok, #state{}}.


handle_call({?IBOT_RI_REMOTE_CALL, CallingNodeName,  CallingRegName, Message}, _From, State) ->
  {reply, ok, State};
handle_call(_Request, _From, State) ->
  {reply, ok, State}.


handle_cast({?IBOT_RI_REMOTE_CAST, CallingNodeName, CallingRegName, Message}, State) ->
  {noreply, State};
handle_cast(_Request, State) ->
  {noreply, State}.


handle_info({?IBOT_RI_REMOTE_CAST, RemoteCore, CallingNodeName, CallingRegName, Message}, State) ->
  spawn(fun() -> cast_remote_node(RemoteCore, CallingNodeName, CallingRegName, Message) end),
  {noreply, State};
handle_info({?IBOT_RI_REMOTE_CALL, CurrentNodeName, CurrentRegName, RemoteCore, CallingNodeName, CallingRegName, Message}, State) ->
  spawn(fun() -> call_remote_node(CurrentNodeName, CurrentRegName, RemoteCore, CallingNodeName, CallingRegName, Message) end),
  {noreply, State};
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
%% Send message to remote node without return response
%%
%% @spec cast_remote_node(RemoteCore, CallingNodeName, CallingRegName, Message) -> ok
%% when CurrentNodeName :: node(), CurrentRegName :: atom(), RemoteCore :: node(), CallingNodeName :: atom(), CallingRegName :: atom(), Message :: term().
%% @end

-spec cast_remote_node(RemoteCore, CallingNodeName, CallingRegName, Message) -> ok
  when CurrentNodeName :: node(), CurrentRegName :: atom(), RemoteCore :: node(), CallingNodeName :: atom(), CallingRegName :: atom(), Message :: term().

cast_remote_node(RemoteCore, CallingNodeName, CallingRegName, Message) ->
  rpc:call(RemoteCore, ?MODULE, handle_cast, [{?IBOT_RI_REMOTE_CAST, CallingNodeName, CallingRegName, Message}], ?IBOT_RI_RESPONSE_TIMEOUT),
  ok.




%% @doc
%% Send message to remote node with return response
%%
%% @spec call_remote_node(CurrentNodeName, CurrentRegName, RemoteCore, CallingNodeName, CallingRegName, Message) -> ok
%% when CurrentNodeName :: node(), CurrentRegName :: atom(), RemoteCore :: node(), CallingNodeName :: atom(),  CallingRegName :: atom(), Message :: term().
%% @end

-spec call_remote_node(CurrentNodeName, CurrentRegName, RemoteCore, CallingNodeName, CallingRegName, Message) -> ok
  when CurrentNodeName :: node(), CurrentRegName :: atom(), RemoteCore :: node(), CallingNodeName :: atom(), CallingRegName :: atom(), Message :: term().

call_remote_node(CurrentNodeName, CurrentRegName, RemoteCore, CallingNodeName, CallingRegName, Message) ->
  case rpc:call(RemoteCore, ?MODULE, handle_call, [{?IBOT_RI_REMOTE_CALL, CallingNodeName, CallingRegName, Message}], ?IBOT_RI_RESPONSE_TIMEOUT) of
    {badrpc, Reason} -> erlang:send({CurrentRegName, CurrentNodeName}, {?IBOT_RI_BADRPC ,Reason});
    Res -> erlang:send({CurrentRegName, CurrentNodeName}, {?IBOT_RI_RESPONSE ,Res})
  end,
  ok.