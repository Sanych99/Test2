%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. Apr 2015 2:08 AM
%%%-------------------------------------------------------------------
-module(ibot_nodes_srv_service).
-author("alex").

-behaviour(gen_server).

-include("ibot_nodes_service.hrl").

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

-record(state, {}).


start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).


init([]) ->
  {ok, #state{}}.


handle_call(_Request, _From, State) ->
  {reply, ok, State}.


handle_cast(_Request, State) ->
  {noreply, State}.


%%% ====== handle_info Start ======

handle_info({?REG_ASYNC_CLIENT_SERVICE, MailBoxName, NodeFullName, ClientMethodName}, State) ->
  {noreply, State};

handle_info({?REG_ASYNC_SERVER_SERVICE, MailBoxName, NodeFullName, ServerServiceMethodName}, State) ->
  {noreply, State};

handle_info({?REQUEST_MESSAGE, serviceMethodName, RequestMessage}, State) ->
  {noreply, State};

handle_info({?RESPONSE_MESSAGE, serviceMethodName, ResponseMessage}, State) ->
  {noreply, State};

handle_info(_Info, State) ->
  {noreply, State}.

%%% ====== handle_info End ======


terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

