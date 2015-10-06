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
-include("ibot_events_srv_logger_messages_type.hrl").
-include("../../ibot_db/include/ibot_db_records.hrl").
-include("../../ibot_core/include/ibot_core_spec_symbols.hrl").

%% API
-export([init/1, handle_event/2, terminate/2, write_message_to_log_file/4]).
-export([log/3, log_message/2, log_error/2, log_warning/2, log_undefine/2]).

-record(logger_state,
{
  row_counter = 0 :: integer(),
  max_row_count = 5000 :: integer(),
  file_descriptor = undefine :: term(),
  is_main_core = true :: boolean(),
  is_local_write = true :: boolean()
}).


%% @doc
%% Инициализация event-а логирования сообщений в файл / init logger
%% @spec init(File) -> {ok, State} when State :: #logger_state{}.
%% @end
-spec init([]) -> {ok, State} when State :: #logger_state{}.

init([]) ->
  %% данные конфигурации ядра / core configuration info
  CoreConfigInfo = ibot_db_func_config:get_core_config_info(),
  %% текущая системная дата и время / current system date time
  {{Year, Month, Day},{Hour, Minutes, Seconds}} = calendar:local_time(),
  %% создаем файл логирования / create log file
  {ok, Fd} = file:open(string:join([CoreConfigInfo#core_info.logger_log_file_path, ?PATH_DELIMETER_SYMBOL,
    io_lib:format(CoreConfigInfo#core_info.logger_log_file_name, [Year, Month, Day, Hour, Minutes, Seconds])], ""), write),
  %% сохраняем начальное состояние логгера / save start logger state
  {ok, #logger_state{file_descriptor = Fd, row_counter = 0, max_row_count = CoreConfigInfo#core_info.logger_log_file_max_row_count}}.



%% @doc
%% Обработка событий логирования сообщений
%% @spec handle_event({MessageType, MessageText, SenderNodeName}, State) -> {ok, NewState}
%% when MessageType :: atom(), MessageText :: string(), SenderNodeName :: term(),
%% State :: #logger_state{}, NewState :: #logger_state{}.
%% @end
-spec handle_event({MessageType, MessageText, SenderNodeName}, State) -> {ok, NewState}
  when MessageType :: atom(), MessageText :: string(), SenderNodeName :: term(),
  State :: #logger_state{}, NewState :: #logger_state{}.

handle_event({MessageType, MessageText, SenderNodeName}, State) ->
  %% проверяем количество строк ранее записанных в файл / chech inserted rows to logger file
  case (State#logger_state.row_counter > State#logger_state.max_row_count) and State#logger_state.is_local_write of
    true -> %% если максимальное количество превышено / last logger row inserted
      %% закрываем текущий файл / close current logger file
      file:close(State#logger_state.file_descriptor),
      %% текущая системная дата и время / current system date time
      {{Year, Month, Day},{Hour, Minutes, Seconds}} = calendar:local_time(),
      %% данные конфигурации ядра / core configuration info
      CoreConfigInfo = ibot_db_func_config:get_core_config_info(),
      %% создаем новый
      {ok, Fd} = file:open(string:join([CoreConfigInfo#core_info.logger_log_file_path, ?PATH_DELIMETER_SYMBOL,
        io_lib:format(CoreConfigInfo#core_info.logger_log_file_name, [Year, Month, Day, Hour, Minutes, Seconds])], ""), write),
      %% сохраняем дескриптор нового файла / create new logger file
      NewState = State#logger_state{file_descriptor = Fd, row_counter = 0};
    false -> %% если максимальное внорме
      %% увелииваем количество добавленных строк на 1 / increase inserted row count by 1
      NewState = State#logger_state{row_counter = State#logger_state.row_counter + 1}
  end,
  %% записваем строку сообщения в файл / write message to log file
  write_message_to_log_file(MessageType, MessageText, SenderNodeName, NewState),

  %% если сообщение пришло в дочернее ядро отправляем сообщение в главное ядро / send log message to main core
  case NewState#logger_state.is_main_core of
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
%% закрываем файл / close log file
%% @end
terminate(_Args, State) ->
  file:close(State#logger_state.file_descriptor).



%% @doc
%% записваем строку сообщения в файл / write message to log file
%% @end
write_message_to_log_file(MessageType, MessageText, SenderNodeName, State) ->
  io:format(State#logger_state.file_descriptor, "#~p ***~p*** from: ~p -> ~p ***~p***~n",
    [State#logger_state.row_counter, MessageType, SenderNodeName, MessageText, State#logger_state.file_descriptor]).

%% =======================
%% ====== API Start ======

%% @doc
%% api функция записи сообщения в файл
%% @spec log(MessageType, MessageText) -> ok
%% when MessageType :: string(), MessageText :: string(), SenderNodeName :: term() | atom().
%% @end
-spec log(MessageType, MessageText, SenderNodeName) -> ok
  when MessageType :: string(), MessageText :: string(), SenderNodeName :: term().

log(MessageType, MessageText, SenderNodeName) ->
  gen_event:notify(?EH_EVENT_LOGGER, {MessageType, MessageText, SenderNodeName}).

log_message(MessageText, SenderNodeName) ->
  ibot_events_srv_logger:log(?T_MESSAGE, MessageText, SenderNodeName).

log_error(MessageText, SenderNodeName) ->
  ibot_events_srv_logger:log(?T_ERROR, MessageText, SenderNodeName).

log_warning(MessageText, SenderNodeName) ->
  ibot_events_srv_logger:log(?T_WARNING, MessageText, SenderNodeName).

log_undefine(MessageText, SenderNodeName) ->
  ibot_events_srv_logger:log(?T_UNDEFINE, MessageText, SenderNodeName).

%% ======= API End =======
%% =======================