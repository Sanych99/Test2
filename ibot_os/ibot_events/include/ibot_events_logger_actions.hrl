%%%-------------------------------------------------------------------
%%% @author Alexandr Tsaregorodtsev
%%% @copyright (C) 2015, iBot Robotics
%%% @doc
%%% Макросы логирования событий / Log actions macros
%%% @end
%%% Created : 07. Oct 2015 3:51 AM
%%%-------------------------------------------------------------------

%% сообщение действия / action message
-define(LOG_MESSAGE(MessageText), ibot_events_srv_logger:log_message(MessageText, {node(), ?MODULE})).
%% сообщение о предупреждении / warning message
-define(LOG_WARNING(MessageText), ibot_events_srv_logger:log_warning(MessageText, {node(), ?MODULE})).
%% сообщение об ошибке / error message
-define(LOG_ERROR(MessageText), ibot_events_srv_logger:log_error(MessageText, {node(), ?MODULE})).
%% сообщение с неизвестным типом / undefine type message
-define(LOG_UNDEFINE(MessageText), ibot_events_srv_logger:log_undefine(MessageText, {node(), ?MODULE})).

%% сообщение действия / action message
-define(LOG_MESSAGE(MessageText, SenderNodeName), ibot_events_srv_logger:log_message(MessageText, SenderNodeName)).
%% сообщение о предупреждении / warning message
-define(LOG_WARNING(MessageText, SenderNodeName), ibot_events_srv_logger:log_warning(MessageText, SenderNodeName)).
%% сообщение об ошибке / error message
-define(LOG_ERROR(MessageText, SenderNodeName), ibot_events_srv_logger:log_error(MessageText, SenderNodeName)).
%% сообщение с неизвестным типом / undefine type message
-define(LOG_UNDEFINE(MessageText, SenderNodeName), ibot_events_srv_logger:log_undefine(MessageText, SenderNodeName)).