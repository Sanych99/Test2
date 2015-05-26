%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. May 2015 2:10 AM
%%%-------------------------------------------------------------------
-module(ibot_ui_interaction_handler).

-behaviour(cowboy_http_handler).
-behaviour(cowboy_websocket_handler).

-include("../../ibot_core/include/debug.hrl").
-include("../../ibot_core/include/ibot_core_modules_names.hrl").
-include("../../ibot_core/include/ibot_core_node_compilation_commands.hrl").

-export([init/3, handle/2, terminate/3]).

-export([
  websocket_init/3, websocket_handle/3,
  websocket_info/3, websocket_terminate/3
]).

init({tcp, http}, _Req, _Opts) ->
  {upgrade, protocol, cowboy_websocket}.


handle(Req, State) ->
  %lager:debug("Request not expected: ~p", [Req]),
  {ok, Req2} = cowboy_http_req:reply(404, [{'Content-Type', <<"text/html">>}]),
  {ok, Req2, State}.


websocket_init(_TransportName, Req, _Opts) ->
  %lager:debug("init websocket"),
  {ok, Req, undefined_state}.

websocket_handle({text, Msg}, Req, State) ->
  ?DBG_MODULE_INFO("websocket_handle({text, Msg}, Req, State) Mgs: ~p~n", [?MODULE, binary_to_list(Msg)]),
  ?DBG_MODULE_INFO("websocket_handle({text, Msg}, Req, State) decode: ~p~n", [?MODULE, jiffy:decode(Msg)]),

  try jiffy:decode(Msg) of
    {[{A, B}]}->
      case A of
        <<"sendData">> ->
          ?DBG_MODULE_INFO("websocket_handle({text, Msg}, Req, State) decode: ~p~n", [?MODULE, B]),
          ok;
        %<<"compileAllNodes">> ->
        %  gen_server:call(?IBOT_CORE_SRV_COMPILE_NODES, {?COMPILE_ALL_NODES}),
        %  {reply, {text, << "responding to ", Msg/binary >>}, Req, State, hibernate };

        _ -> {reply, {text, << "responding to ", Msg/binary >>}, Req, State, hibernate }
      end;

    %{reply, {text, jiffy:encode({[{registered,B}]})}, Req, State};
    _ ->
      {reply, {text, jiffy:encode({[{error,<<"invalid json">>}]})}, Req, State}
  catch
    _:_ ->
      {reply, {text, jiffy:encode({[{error,<<"invalid json">>}]})}, Req, State}
  end;


websocket_handle(_Any, Req, State) ->
  {reply, {text, << "whut?">>}, Req, State, hibernate }.

websocket_info({timeout, _Ref, Msg}, Req, State) ->
  {reply, {text, Msg}, Req, State};

websocket_info(_Info, Req, State) ->
  %lager:debug("websocket info"),
  {ok, Req, State, hibernate}.

websocket_terminate(_Reason, _Req, _State) ->
  ok.

terminate(_Reason, _Req, _State) ->
  ok.