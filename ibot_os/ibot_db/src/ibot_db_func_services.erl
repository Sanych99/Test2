%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright iBot Robotics
%%% @doc
%%% Функции управления данными сервисов
%%% @end
%%% Created : 18. Mar 2015 2:20 AM
%%%-------------------------------------------------------------------
-module(ibot_db_func_services).

-include("..\\..\\ibot_core/include/debug.hrl").
-include("ibot_db_records_service.hrl").
-include("ibot_db_table_names.hrl").
-include("..\\..\\ibot_db/include/ibot_db_reserve_atoms.hrl").

-export([register_client_service/4, get_client_service/2, register_server_service/3, get_server_service/1]).


%%% ====== Client service methods Start ======

%% @doc
%% Регистрация клиента для сервиса / Registration client to send message to service
%% @spec register_client_service(ServerMethodName, ClientMethodName, MailBoxName, NodeFullName) -> ok
%% when ServerMethodName::atom(), ClientMethodName::atom(), MailBoxName::atom(), NodeFullName::atom().
%% @end
-spec register_client_service(ServerMethodName, ClientMethodName, MailBoxName, NodeFullName) -> ok
  when ServerMethodName::atom(), ClientMethodName::atom(), MailBoxName::atom(), NodeFullName::atom().

register_client_service(ServerMethodName, ClientMethodName, MailBoxName, NodeFullName) ->
  ClientService = #service_client{serverMethodNameAtom = list_to_atom(ServerMethodName), serverMethodName = ServerMethodName,
    clientMethodNameAtom = list_to_atom(ClientMethodName), clientMethodName = ClientMethodName,
    mailBoxName = MailBoxName, nodeFullName = NodeFullName},
  ibot_db_srv:add_record(?TABLE_SERVICES_CLIENT, {ClientMethodName, NodeFullName}, ClientService),
  ok.

%% @doc
%% Полчить данные по клиенту сервиса / Get client service info
%% @end
get_client_service(ClientMethodName, NodeFullName) ->
  case ibot_db_srv:get_record(?TABLE_SERVICES_CLIENT, {ClientMethodName, NodeFullName}) of
    {ok, Value} -> Value;
    _ -> ?RECORD_NOT_FOUND
  end.

%%% ====== Client service methods End ======


%%% ====== Server service methods Start ======

%% @doc
%% Регистрация сервера сервиса / Register service server
%% @end
register_server_service(ServerServiceName, MailBox, NodeFullName) ->
  ServerService = #service_server{serverServiceMethodNameAtom = list_to_atom(ServerServiceName), serverServiceMethodName = ServerServiceName,
  mailBox = MailBox, nodeFullName = NodeFullName},
  ibot_db_func:add_to_mnesia(ServerService),
  ok.


%% @doc
%% Получить данные сервера сервиса / Get service server info
%% @end
get_server_service(ServerServiceNameAtom) ->
  ibot_db_func:get_from_mnesia(service_server, ServerServiceNameAtom).

%%% ====== Server service methods End ======