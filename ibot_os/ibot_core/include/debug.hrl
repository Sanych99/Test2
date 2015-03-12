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
-define(DBG_MODULE_INFO(_Msg, _Params), io:format("Module ~p: -> " ++ _Msg, _Params)).
%-else.
%-define(DBG_INFO, ok).
%-endif.