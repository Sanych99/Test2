%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. Apr 2015 3:07 AM
%%%-------------------------------------------------------------------

-record(service_client, {clientMethodName, mailBoxName, nodeFullName}).

-record(service_server, {serverServiceMethodName, mailBox, nodeFullName}).
