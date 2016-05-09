%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. Apr 2015 2:08 AM
%%%-------------------------------------------------------------------
-module(ibot_services_srv_service).
-author("alex").

-behaviour(gen_server).

-include("../../ibot_core/include/debug.hrl").
-include("ibot_nodes_service.hrl").
-include("../../ibot_db/include/ibot_db_reserve_atoms.hrl").
-include("../../ibot_db/include/ibot_db_records_service.hrl").

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-export([sendMessageToService/7]).

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

%% @doc
%% Регистрация метода клиента (не используется, так как данные отправляются непосредствнно сервер сервисом)
%% @end
handle_info({?REG_ASYNC_CLIENT_SERVICE, MailBoxName, NodeFullName, ClientMethodName, ServerMethodName}, State) ->
  ibot_db_func_services:register_client_service(ServerMethodName, ClientMethodName, MailBoxName, NodeFullName),
  {noreply, State};

%% @doc
%% Регистрация матода сервер сервиса
%% @end
handle_info({?REG_ASYNC_SERVER_SERVICE, MailBoxName, NodeFullName, ServerServiceMethodName}, State) ->
  ?DBG_MODULE_INFO("handle_info ~p~n...", [?MODULE, {?REG_ASYNC_SERVER_SERVICE, MailBoxName, NodeFullName, ServerServiceMethodName}]),
  ibot_db_func_services:register_server_service(ServerServiceMethodName, MailBoxName, NodeFullName),
  {noreply, State};

%% @doc
%% Отправляем запрос методу сервиса
%% @end
handle_info({?REQUEST_SERVICE_MESSAGE, ClientMailBoxName, ClientNodeFullName, ClientMethodName, ServiceMethodName, RequestMessage}, State) ->
  case ibot_db_func_services:get_server_service(list_to_atom(ServiceMethodName)) of %% поиск данных о сервисе в бд
    ?RECORD_NOT_FOUND -> ?RECORD_NOT_FOUND; %% данные не найдены
    Record -> spawn(fun() ->
      sendMessageToService(Record#service_server.mailBox, Record#service_server.nodeFullName, ServiceMethodName,
        ClientMailBoxName, ClientNodeFullName, ClientMethodName, RequestMessage)
    end) %% данные найдены, отправляем запрос
  end,
  {noreply, State};


%% @doc
%% Получаем ответ от сервиса
%% @end
handle_info({?RESPONSE_SERVICE_MESSAGE, ServiceMethodName, ClientMailBoxName, ClientNodeFullName, ClientMethodName, RequestMessage, ResponseMessage}, State) ->
  ?DMI("RESPONSE_SERVICE_MESSAGE", {?RESPONSE_SERVICE_MESSAGE, ClientMailBoxName, ClientNodeFullName, ClientMethodName, RequestMessage, ResponseMessage}),
  %% отправляем ответ клиенту
  spawn(fun() ->
    sendMessageToClient(ServiceMethodName, ClientMailBoxName, ClientNodeFullName, ClientMethodName, RequestMessage, ResponseMessage)
  end),
  {noreply, State};

handle_info(_Info, State) -> ?DBG_MODULE_INFO("handle_info Not handle...~p~n", [?MODULE, _Info]),
  {noreply, State}.

%%% ====== handle_info End ======


terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

%% @doc
%% Отправляем запрос сервису
%% @spec sendMessageToService(ServiceMailBoxName, ServiceNodeFullName, ServiceMethodName, ClientMailBoxName, ClientNodeFullName, ClientMethodName, RequestMessage) -> ok.
%% @end
-spec sendMessageToService(ServiceMailBoxName, ServiceNodeFullName, ServiceMethodName, ClientMailBoxName,
    ClientNodeFullName, ClientMethodName, RequestMessage) -> ok
  when ServiceMailBoxName :: term(), ServiceNodeFullName :: term(), ServiceMethodName :: term(), ClientMailBoxName :: term(),
  ClientNodeFullName :: term(), ClientMethodName :: term(), RequestMessage :: term().

sendMessageToService(ServiceMailBoxName, ServiceNodeFullName, ServiceMethodName, ClientMailBoxName, ClientNodeFullName, ClientMethodName, RequestMessage) ->
  ?DMI("sendMessageToService", {?CALL_SERVICE_METHOD, ServiceMethodName, ClientMailBoxName, ClientNodeFullName, ClientMethodName, RequestMessage}),
  erlang:send({ServiceMailBoxName, ServiceNodeFullName}, {?CALL_SERVICE_METHOD, ServiceMethodName, ClientMailBoxName, ClientNodeFullName, ClientMethodName, RequestMessage}),
  ok.

%% @doc
%% Отправляем ответ клиенту
%% @spec sendMessageToClient(ServiceMethodName, ClientMailBoxName, ClientNodeFullName, ClientMethodName, RequestMessage, ResponceMessage) -> ok.
%% @end
-spec sendMessageToClient(ServiceMethodName, ClientMailBoxName, ClientNodeFullName,
    ClientMethodName, RequestMessage, ResponceMessage) -> ok
  when ServiceMethodName :: term(), ClientMailBoxName :: term(), ClientNodeFullName :: term(),
  ClientMethodName :: term(), RequestMessage :: term(), ResponceMessage :: term().

sendMessageToClient(ServiceMethodName, ClientMailBoxName, ClientNodeFullName, ClientMethodName, RequestMessage, ResponceMessage) ->
  erlang:send({ClientMailBoxName, ClientNodeFullName}, {?CALL_CLIENT_SERVICE_CALLBACK_METHOD, ServiceMethodName, ClientMethodName, RequestMessage, ResponceMessage}),
  ok.