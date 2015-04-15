%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. Mar 2015 2:20 AM
%%%-------------------------------------------------------------------
-module(ibot_db_func_services).

-include("../../ibot_core/include/debug.hrl").
-include("ibot_db_records_service.hrl").
-include("ibot_db_table_names.hrl").

-export([register_client_service/4]).


%%% ====== Client service methods Start ======

%% @doc
%%
%% Registration client to send message to service
%% @spec register_client_service(ServerMethodName, ClientMethodName, MailBoxName, NodeFullName) -> ok
%% when ServerMethodName::atom(), ClientMethodName::atom(), MailBoxName::atom(), NodeFullName::atom().
%% @end

-spec register_client_service(ServerMethodName, ClientMethodName, MailBoxName, NodeFullName) -> ok
  when ServerMethodName::atom(), ClientMethodName::atom(), MailBoxName::atom(), NodeFullName::atom().

register_client_service(ServerMethodName, ClientMethodName, MailBoxName, NodeFullName) ->
  ClientService = #service_client{clientMethodName = ClientMethodName, mailBoxName = MailBoxName, nodeFullName = NodeFullName},
  ibot_db_srv:add_record(?TABLE_SERVICES_CLIENT, ServerMethodName, ClientService),
  ok.


get_client_service(ServerMethodName) ->
  case ibot_db_srv:get_record(?TABLE_SERVICES_CLIENT, ServerMethodName) of
    {ok, Value} -> Value;
    _ -> not_found
  end.

%%% ====== Client service methods End ======


