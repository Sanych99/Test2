%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. Aug 2015 1:24 AM
%%%-------------------------------------------------------------------
-module(ibot_nodes_srv_ui_interaction).
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

-export([send_message_yo_webi_client/2]).

-include("../../ibot_core/include/debug.hrl").
-include("../../ibot_webi/include/ibot_webi_ui_client_process_name.hrl").

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


handle_info({send_data_to_ui, NodeName, Msg}, State) ->
  ?DMI("send_data_to_ui", {NodeName, Msg}),
  ibot_nodes_srv_ui_interaction:send_message_yo_webi_client(NodeName, Msg),
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

send_message_yo_webi_client(NodeName, Msg) ->
  gproc:send({p, l, ?WSKey}, {self(), ?WSKey, {send_data_to_ui, NodeName, Msg}}).