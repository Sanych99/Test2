%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. Mar 2015 7:41 PM
%%%-------------------------------------------------------------------
-module(test).
-author("alex").

%% API
-export([run/0, list_dir/0, gen/0, dir/0, jn/0]).


run() ->
  ibot_core_app:start(1,1),
  ibot_core_app:create_project("/home/alex/ErlangTest", "test_project"),
  ibot_core_app:create_node("test_node", "java"),
  ibot_core_app:stop({}),
  ok.

list_dir() ->
  Dir = "/home/alex/ErlangTest",
  case file:list_dir(Dir) of
    {ok, Filenames} ->
      lists:foreach(fun(Name) -> io:format("~s~n", [Name]) end, Filenames);
    {error, enoent} ->
      io:format("The directory(~s) does not exist.~n", [Dir]),
      ng
  end.

gen() ->
  ibot_generator_msg_srv:generate_msg_srv("/home/alex/ErlangTest/test_project"),

  io:format("wc files: ~p~n", [filelib:wildcard("/home/alex/ErlangTest/test_project/src/*/msg/*.msg")]),
                                                %/home/alex/ErlangTest/test_project/src/*/msg/*.msg
  ok.

dir() ->
  Res = filelib:is_("/home/alex/ErlangTest/test_project/src/test_node/msg"),
  io:format("is dir: ~p~n", [Res]),
  ok.

jn() ->
  Res = string:join(["Path", "Node", "Msg"], "/"),
  io:format("~p~n", [Res]),
  ok.