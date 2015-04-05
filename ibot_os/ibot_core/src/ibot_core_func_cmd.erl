%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015
%%% @doc
%%%
%%% @end
%%%-------------------------------------------------------------------
-module(ibot_core_func_cmd).

-include("debug.hrl").

-export([exec/1, run_exec/1]).

%% @doc Выполнение комманд в коммандной строке ОС
-spec exec(Command) -> ok when Command :: list(), Command :: atom().
exec(Command) when is_list(Command) ->
  os:cmd(list_to_atom(Command)),
  ok;
exec(Command) when is_atom(Command) ->
  os:cmd(Command),
  ok.

%% @doc Запуск исполняющих файлов системы
-spec run_exec(Command) -> ok when Command :: list() | string().
run_exec(Command) ->
  % Откарываем порт
  Port = open_port({spawn, Command}, [stream, in, eof, hide, exit_status, stderr_to_stdout]),
  % Ожидаем завершения выполнения комманды
  case get_data(Port, []) of
    true -> ok;
    _ -> port_close(Port),
      ?DBG_INFO("Port was closed... ~n", []),
      ok
  end.

%% @doc Ожидание ответа от выполненной комманды
-spec get_data(Port, Sofar) -> true | ok when Port :: term(), Sofar :: list().
get_data(Port, Sofar) ->
  receive
    {Port, {data, Bytes}} ->
      ?DBG_INFO("{Port, {data, Bytes}} ->... ~p~n", [{Port, {data, Bytes}}]),
      get_data(Port, [Sofar|Bytes]);
    {Port, eof} ->
      ?DBG_INFO("{Port, eof} ->... ~p~n", [{Port, eof}]),
      Port ! {self(), close},
      receive
        {Port, closed} ->
          ?DBG_INFO("Port was closed... ~n", []),
          true
      end,
      receive
        {'EXIT',  Port,  _} ->
          ok
      after 1 ->
        ok
      end,
      ExitCode =
        receive
          {Port, {exit_status, Code}} ->
            Code
        end,
      {ExitCode, lists:flatten(Sofar)};
    {Port, {exit_status, _Code}} -> ok;
    _ -> ok
  end.