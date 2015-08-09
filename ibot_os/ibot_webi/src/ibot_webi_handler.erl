-module(ibot_webi_handler).

-behaviour(cowboy_http_handler).
-behaviour(cowboy_websocket_handler).

-include("ibot_webi_ui_client_process_name.hrl").
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
  gproc:reg({p, l, ?WSKey}),
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
        <<"compileOneNode">> ->
          gen_server:call(?IBOT_CORE_SRV_COMPILE_NODES, {?COMPILE_NODE, binary_to_list(B)}),
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
          case ibot_core_app:get_project_node_from_config() of
            {ok, ProjectNodes} ->
              ProjectNodesBin = list_to_binary(ProjectNodes),%(string:join(ProjectNodes, "|")),
              {reply, {text, jiffy:encode({[{responseType, nodeslist}, {responseJson, <<ProjectNodesBin/binary>>}]})}, Req, State};
            _ -> {reply, {text, jiffy:encode({[{error,<<"get nodes error...">>}]})}, Req, State}
          end;
        <<"generateAllMsgs">> ->
          ibot_generator_msg_srv:generate_all_msg_srv(),
          {reply, {text, << "responding to ", Msg/binary >>}, Req, State, hibernate };
        <<"startProject">> ->
          ibot_core_app:start_project(),
          {reply, {text, << "responding to ", Msg/binary >>}, Req, State, hibernate };
        <<"startNode">> ->
          ibot_core_app:start_node(binary_to_list(B)),
          {reply, {text, << "responding to ", Msg/binary >>}, Req, State, hibernate };
        <<"stopNode">> ->
          ibot_nodes_srv_connector:stop_node([binary_to_list(B)]),
          {reply, {text, << "responding to ", Msg/binary >>}, Req, State, hibernate };



        <<"sendData">> ->
          ?DBG_MODULE_INFO("websocket_handle({text, Msg}, Req, State) decode: ~p~n", [?MODULE, B]),
          case B of
            {[{_, SendType}, {_, TopicOrServiceName}, {_, ListParameters}]} ->
              case SendType of
                <<"broadcast">> ->
                  ?DMI("broadcast start...", ?ONLY_MESSAGE),
                  %% bradcast message to all subcribed topicslist_to_tuple(ListParameters)list_to_tuple(ListParameters)
                  NewListParametersTuple = list_to_tuple([case E of
                               El when is_binary(E) -> binary_to_list(E);
                               _ -> E
                             end || E <- ListParameters]),
                  ?DMI("new parameters list", NewListParametersTuple),
                  ibot_nodes_srv_topic:broadcats_message(binary_to_atom(TopicOrServiceName, utf8), NewListParametersTuple),
                  {reply, {text, jiffy:encode({[{ok,<<"send data cpmplete...">>}]})},
                    Req, State, hibernate };

                _ ->
                  %% message send type undefined
                  ?ERROR_MSG("sendData: SendType not fond..."),
                  {reply, {text, jiffy:encode({[{error,<<"ibot_ui_interaction_handler sendData: SendType not fond...">>}]})},
                    Req, State, hibernate }
              end;

            _ ->
              %%{reply, {text, << "responding to ", Msg/binary >>}, Req, State, hibernate }
              %% template for send data undefied
              ?ERROR_MSG("sendData: Not fond template..."),
              {reply, {text, jiffy:encode({[{error,<<"ibot_ui_interaction_handler sendData: Not fond template...">>}]})},
                Req, State, hibernate }
          end;


        _ ->
          %%{reply, {text, << "responding to ", Msg/binary >>}, Req, State, hibernate }
          %% template for send data undefied
          ?ERROR_MSG("sendData: Not fond template..."),
          {reply, {text, jiffy:encode({[{error,<<"ibot_ui_interaction_handler sendData: Not fond template...">>}]})},
            Req, State, hibernate }
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
  ?DMI("websocket_info", _Info),
  case _Info of
    {_PID, ?WSKey, {send_data_to_ui, NodeName, MsgClassName, AdditionalInfo, Msg}} ->
      ?DMI("websocket_info", "try send message to ui"),
      {reply, {text, jiffy:encode({[{message_type, send_data_to_ui}, {node_name, NodeName}, {message_class_name, MsgClassName}, {additional_info, AdditionalInfo}, {message, Msg}]})}, Req, State, hibernate};

    _ ->
      ?DMI("websocket_info", "don't send message to ui"),
      {ok, Req, State, hibernate}
  end.

websocket_terminate(_Reason, _Req, _State) ->
  ok.

terminate(_Reason, _Req, _State) ->
  ok.