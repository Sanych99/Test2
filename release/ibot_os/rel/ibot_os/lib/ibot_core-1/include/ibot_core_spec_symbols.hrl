%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015
%%% @doc
%%%
%%% @end
%%% Created : 19. May 2015 1:39 AM
%%%-------------------------------------------------------------------
%-define(PATH_DELIMETER_SYMBOL,
%    case os:type() of
%      {unix, linux} -> "/";
%      _ -> "\\"
%    end).

-define(PATH_DELIMETER_SYMBOL, case os:type() of
                             {unix, linux} -> "/";
                             _ -> "\\"
                           end).