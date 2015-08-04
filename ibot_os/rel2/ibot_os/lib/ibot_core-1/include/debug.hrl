%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. Февр. 2015 19:08
%%%-------------------------------------------------------------------
-author("alex").

%-ifdef(debug).
-define(DBG_INFO(_Msg, _Params), io:format(_Msg, _Params)).
-define(DBG_MODULE_INFO(_Msg, _Params), io:format("=> module ~p: -> " ++ _Msg, _Params)).
-define(DMI(_Mgs, _Params), io:format("=> module: ~p ! line in code: ~p ! message: ~p ! parameters: ~p~n", [?MODULE, ?LINE, _Mgs, _Params])).
-define(ERROR_MSG(_Msg), io:format("Module ~p: -> ~p~n", [?MODULE, _Msg])).
-define(ONLY_MESSAGE, only_message).
%-else.
%-define(DBG_INFO, ok).
%-endif.