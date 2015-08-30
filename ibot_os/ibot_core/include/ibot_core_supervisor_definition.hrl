%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. Aug 2015 4:48 PM
%%%-------------------------------------------------------------------
-author("alex").
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).
-define(CHILD_PARAM(N, I, Type, P), {N, {I, start_link, [P]}, permanent, 5000, Type, [I]}).