%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. Oct 2015 3:38 AM
%%%-------------------------------------------------------------------
-module(ibot_events_srv_node_interaction).
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

-include("ibot_events_srv_logger_messages_type.hrl").
-include("ibot_events_logger_actions.hrl").

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

handle_call(_Request, _From, State) ->
  {reply, ok, State}.

handle_cast(_Request, State) ->
  {noreply, State}.


%% @doc
%% Логирование сообщений от узлов проекта / Nodes message logging
%% @end
handle_info({node_logger_message, MessageType, MessageText, SenderNodeName}, State) ->
  case MessageType of
    ?T_MESSAGE -> ?LOG_MESSAGE(MessageText, SenderNodeName); %% сообщение действия / message action
    ?T_WARNING -> ?LOG_WARNING(MessageText, SenderNodeName); %% сообщение предупреждение / warning message
    ?T_ERROR -> ?LOG_ERROR(MessageText, SenderNodeName); %% сообщение ошибки / error message
    _ -> ?LOG_UNDEFINE(MessageText, SenderNodeName) %% неопределенный тип сообщения / undefine type message
  end,
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