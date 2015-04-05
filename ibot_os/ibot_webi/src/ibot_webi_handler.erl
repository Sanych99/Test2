-module(ibot_webi_handler).

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
        <<"compileAllNodes">> ->
          gen_server:call(?IBOT_CORE_SRV_COMPILE_NODES, {?COMPILE_ALL_NODES}),
          {reply, {text, << "responding to ", Msg/binary >>}, Req, State, hibernate };
        <<"connectToProject">> ->
          ibot_core_app:connect_to_project(binary_to_list(B)),
          {reply, {text, << "responding to ", Msg/binary >>}, Req, State, hibernate };
        <<"createProject">> ->
          case B of
            {[{_, ProjectNameBin}, {_, ProjectPath}]} ->
              ibot_core_app:create_project(binary_to_list(ProjectPath), binary_to_list(ProjectNameBin)),
              {reply, {text, << "responding to ", Msg/binary >>}, Req, State, hibernate };
            _ -> error
          end,
          {reply, {text, << "responding to ", Msg/binary >>}, Req, State, hibernate };
        <<"createNode">> ->
          case B of
            {[{_, NodeNameBin}, {_, NodeLang}]} ->
              ibot_core_app:create_node(binary_to_list(NodeNameBin), binary_to_list(NodeLang)),
              {reply, {text, << "responding to ", Msg/binary >>}, Req, State, hibernate };
            _ -> error
          end,
          {reply, {text, << "responding to ", Msg/binary >>}, Req, State, hibernate };
        <<"getNodes">> ->
          ?DBG_MODULE_INFO("<<getNodes>> : ~p~n", [?MODULE, ibot_core_app:get_project_nodes()]),
          case ibot_core_app:get_project_nodes() of
            {ok, ProjectNodes} ->
              ProjectNodesBin = list_to_binary(string:join(ProjectNodes, "|")),
              {reply, {text, jiffy:encode({[{responseType, nodeslist}, {responseJson, <<ProjectNodesBin/binary>>}]})}, Req, State};
            _ -> {reply, {text, jiffy:encode({[{error,<<"get nodes error...">>}]})}, Req, State}
          end;
        <<"generateAllMsgs">> ->
          ibot_generator_msg_srv:generate_all_msg_srv(),
          {reply, {text, << "responding to ", Msg/binary >>}, Req, State, hibernate };
        <<"startProject">> ->
          ibot_core_app:start_project(),
          {reply, {text, << "responding to ", Msg/binary >>}, Req, State, hibernate };
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