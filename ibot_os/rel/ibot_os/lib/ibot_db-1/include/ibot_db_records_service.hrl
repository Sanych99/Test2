%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. Apr 2015 3:07 AM
%%%-------------------------------------------------------------------

%% serverMethodName - service method name
%% serverMethodNameAtom - service method name atom
%% clientMethodName - client method name
%% clientMethodNameAtom - client method name atom
%% mailBoxName - client mail box
%% nodeFullName - client node full name
-record(service_client, {serverMethodName::string(), serverMethodNameAtom::atom(),
  clientMethodName::string(), clientMethodNameAtom::atom(),
  mailBoxName::atom(), nodeFullName::atom()}).


%% serverServiceMethodName - service method name
%% serverServiceMethodNameAtom - service mathod atom
%% mailBox - service mail box
%% nodeFullName - service node full name
-record(service_server, {serverServiceMethodName::string(), serverServiceMethodNameAtom::atom(),
  mailBox::atom(), nodeFullName::atom()}).
