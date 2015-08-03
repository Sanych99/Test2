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
          case B of
            {[{_, SendType}, {_, TopicOrServiceName}, {_, ListParameters}]} ->
              case SendType of
                <<"broadcast">> ->
                  %% bradcast message to all subcribed topics
                  ibot_nodes_srv_topic:broadcats_message(TopicOrServiceName, list_to_tuple(ListParameters)),
                  ok;

                _ ->
                  %% message send type undefined
                  ?ERROR_MSG("sendData: SendType not fond..."),
                  {reply, {text, jiffy:encode({[{error,<<"ibot_ui_interaction_handler sendData: SendType not fond...">>}]})},
                    Req, State, hibernate }
              end,
              ok;

            _ ->
              %% template for send data undefied
              ?ERROR_MSG("sendData: Not fond template..."),
              {reply, {text, jiffy:encode({[{error,<<"ibot_ui_interaction_handler sendData: Not fond template...">>}]})},
                Req, State, hibernate }
          end;

        _ -> {reply, {text, << "responding to ", Msg/binary >>}, Req, State, hibernate }
      end;

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