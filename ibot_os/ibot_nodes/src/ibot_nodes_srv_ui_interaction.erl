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

-export([send_message_to_webi_client/2, init_state/0, send_data_from_children_core/2]).

-include("../../ibot_core/include/debug.hrl").
-include("../../ibot_webi/include/ibot_webi_ui_client_process_name.hrl").
-include("../../ibot_db/include/ibot_db_records.hrl").

-define(SERVER, ?MODULE).

-record(state, {isMainNode ::  boolean(), mainNodeName :: atom()}).


start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).


init([]) ->
  {ok, #state{}}.


handle_call(_Request, _From, State) ->
  {reply, ok, State}.



handle_cast({init_state}, _State) ->
  ProjectInfo = ibot_db_srv_func_project:get_project_config_info(),
  NewState = #state{isMainNode = ProjectInfo#project_info.mainProject,
    mainNodeName = ProjectInfo#project_info.mainProjectNodeName},
  {noreply, NewState};

handle_cast({send_data_to_ui, NodeName, Msg}, State) ->
  spawn(fun() ->
    ?DMI("send_data_to_ui", {NodeName, Msg}),
    case State#state.isMainNode of
      true ->
        ibot_nodes_srv_ui_interaction:send_message_to_webi_client(NodeName, Msg);

      false ->
        spawn(State#state.mainNodeName, ?MODULE, send_data_from_children_core, [NodeName, Msg])
    end
  end),
  {noreply, State};

handle_cast(_Request, State) ->
  {noreply, State}.


handle_info({send_data_to_ui, NodeName, Msg}, State) ->
  spawn(fun() ->
    ?DMI("send_data_to_ui", {NodeName, Msg}),
    case State#state.isMainNode of
      true ->
        ibot_nodes_srv_ui_interaction:send_message_to_webi_client(NodeName, Msg);

      false ->
        spawn(State#state.mainNodeName, ?MODULE, send_data_from_children_core, [NodeName, Msg])
    end
  end),
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

-spec send_message_to_webi_client(NodeName, Msg) -> ok
  when NodeName :: atom(), Msg :: tuple().
send_message_to_webi_client(NodeName, Msg) ->
  ConvertedMsg = tuple_to_list(Msg),
  NewMessage = [case E of
                  El when is_list(E) -> list_to_binary(E);
                  _ -> E
                end || E <- ConvertedMsg],
  gproc:send({p, l, ?WSKey}, {self(), ?WSKey, {send_data_to_ui, NodeName, NewMessage}}),
  ok.


send_data_from_children_core(NodeName, Msg) ->
  gen_server:cast(?MODULE, {send_data_to_ui, NodeName, Msg}).


init_state() ->
  gen_server:cast(?MODULE, {init_state}).