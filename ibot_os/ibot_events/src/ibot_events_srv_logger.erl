%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, iBotRobotics
%%% @doc
%%% Запись сообщение логирования в файл
%%% @end
%%% Created : 05. Oct 2015 3:39 AM
%%%-------------------------------------------------------------------
-module(ibot_events_srv_logger).
-author("alex").
-behaviour(gen_event).

-include("ibot_events_handlers.hrl").

%% API
-export([init/1, handle_event/2, terminate/2, write_message_to_log_file/3]).
-export([log/2]).

-record(logger_state,
{
  row_counter = 0 :: integer(),
  max_row_count = 100 :: integer(),
  file_descriptor :: term(),
  is_main_core = true :: boolean(),
  is_local_write = true :: boolean()
}).


%% @doc
%% Инициализация event-а логирования сообщений в файл
%% @spec init(File) -> {ok, State} when File :: string(), State :: #logger_state{}.
%% @end
-spec init(File) -> {ok, State} when File :: string(), State :: #logger_state{}.

init(File) ->
  {ok, Fd} = file:open(File, read),
  {ok, #logger_state{file_descriptor = Fd, row_counter = 0, max_row_count = 100}}.



%% @doc
%% Обработка событий логирования сообщений
%% @spec handle_event({MessageType, MessageText}, State) -> {ok, NewState}
%% when MessageType :: atom(), MessageText :: string(), State ::#logger_state{}, NewState :: #logger_state{}.
%% @end
-spec handle_event({MessageType, MessageText}, State) -> {ok, NewState}
  when MessageType :: atom(), MessageText :: string(), State ::#logger_state{}, NewState :: #logger_state{}.

handle_event({MessageType, MessageText}, State) ->
  %% проверяем количество строк ранее записанных в файл
  case State#logger_state.row_counter > State#logger_state.max_row_count and State#logger_state.is_local_write of
    true -> %% если максимальное количество превышено
      %% закрываем текущий файл
      file:close(State#logger_state.file_descriptor),
      %% создаем новый
      {ok, Fd} = file:open("File", read),
      %% сохраняем дескриптор нового файла
      NewState = State#logger_state{file_descriptor = Fd, row_counter = 0};
    false -> %% если максимальное внорме
      %% увелииваем количество добавленных строк на 1
      NewState = State#logger_state{row_counter = State#logger_state.row_counter + 1}
  end,
  %% записваем строку сообщения в файл
  write_message_to_log_file(MessageType, MessageText, State),

  %% если сообщение пришло в дочернее ядро отправляем сообщение в главное ядро
  case State#logger_state.is_main_core of
    false ->
      %% todo отправвить сообение главному ядру для записи сообщения
      %% todo надо предусмотреть записи ядра из которого поступило сообщение
      %% todo а та же имя узла проекта который сообщение отправил, в случае если отправление было из узла
      ok;
    _ ->
      ok
  end,
  {ok, NewState}.

%% @doc
%% закрываем файл
%% @end
terminate(_Args, State) ->
  file:close(State#logger_state.file_descriptor).



%% @doc
%% записваем строку сообщения в файл
%% @end
write_message_to_log_file(MessageType, MessageText, State) ->
  io:format(State#logger_state.file_descriptor, "***Error*** ~p~n", [{MessageType, MessageText}]).

%% =======================
%% ====== API Start ======

%% @doc
%% api функция записи сообщения в файл
%% @spec log(MessageType, MessageText) -> ok when MessageType :: atom(), MessageText :: string().
%% @end
-spec log(MessageType, MessageText) -> ok when MessageType :: atom(), MessageText :: string().

log(MessageType, MessageText) ->
  gen_event:notify(?EH_EVENT_LOGGER, {MessageType, MessageText}),
  ok.

%% ======= API End =======
%% =======================