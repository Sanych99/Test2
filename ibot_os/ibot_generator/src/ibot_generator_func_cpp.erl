%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. Jun 2015 1:02 AM
%%%-------------------------------------------------------------------
-module(ibot_generator_func_cpp).

-include("../../ibot_core/include/debug.hrl").
-include("project_paths.hrl").
-include("msg_srv_cpp_generate_templates.hrl").

%% API
-export([generate_msg_source_files/2, generate_srv_source_files/2]).

%% @doc
%% Generate message source files for language
%%
%% @spec
%% @end

-spec generate_msg_source_files([FileName | FilesList], ProjectDir) -> ok when FileName ::string(),
  FilesList :: string(), ProjectDir :: string().

generate_msg_source_files([FileName | FilesList], ProjectDir) ->
  ?DBG_INFO("files for generate: ~p~n", [[FileName | FilesList]]),

  RawFileName = filename:basename(FileName, ".msg"), %% File name without path and extension

  ProjectMsgPath = ?DEV_MSG_PATH_DIR(ProjectDir), %% Project path

  CppProjectMsgPath = ?DEV_MSG_CPP_PATH(ProjectMsgPath), %% Java msg generated files folder

  {ok, GeneratedFile} = file:open(string:join([CppProjectMsgPath, ?PATH_DELIMETER_SYMBOL, RawFileName, ".h"], ""), [write]), %% Open generated file

  for_each_line_in_msg_file(FileName, GeneratedFile, RawFileName), %% Generate properties code

  generate_msg_source_files(FilesList, ProjectDir), %% Generate next file
  ok;
generate_msg_source_files([], _ProjectDir) ->
  %% Create JAR library for JAVA messages
  %% ibot_core_cmd:run_exec(?JAVA_COMPILE_MSG_SRV_SOURCES),
  ok.



%% @doc
%% Generate services source files for language
%%
%% @spec
%% @end

-spec generate_srv_source_files([FileName | FilesList], ProjectDir) -> ok when FileName ::string(),
  FilesList :: string(), ProjectDir :: string().

generate_srv_source_files([FileName | FilesList], ProjectDir) ->
  ?DBG_INFO("files for generate: ~p~n", [[FileName | FilesList]]),

  RawFileName = filename:basename(FileName, ".srv"), %% File name without path and extension

  ProjectMsgPath = ?DEV_SRV_PATH_DIR(ProjectDir), %% Project path

  CppProjectMsgPath = ?DEV_SRV_CPP_PATH(ProjectMsgPath), %% Java msg generated files folder

  {ok, GeneratedFileReq} = file:open(string:join([CppProjectMsgPath, ?PATH_DELIMETER_SYMBOL, RawFileName, "Req.h"], ""), [write]), %% Open generated file

  {ok, GeneratedFileResp} = file:open(string:join([CppProjectMsgPath, ?PATH_DELIMETER_SYMBOL, RawFileName, "Resp.h"], ""), [write]), %% Open generated file

  for_each_line_in_srv_file(FileName, GeneratedFileReq, GeneratedFileResp,RawFileName), %% Generate properties code

  generate_srv_source_files(FilesList, ProjectDir), %% Generate next file
  ok;
generate_srv_source_files([], _ProjectDir) ->
  %% Create JAR library for JAVA messages
  %% ibot_core_cmd:run_exec(?JAVA_COMPILE_MSG_SRV_SOURCES),
  ok.



%% @doc
%% Read lines from message files
%%
%% @spec
%% @end

-spec for_each_line_in_msg_file(FileName, GeneratedFile, RawFileName) -> ok when FileName :: string(), GeneratedFile :: term(),
  RawFileName :: string().

for_each_line_in_msg_file(FileName, GeneratedFile, RawFileName) ->
  {ok, Device} = file:open(FileName, [read]),
  file:write(GeneratedFile, ?CPP_MSG_FILE_HEADER(RawFileName)), %% Write header template
  for_each_line(Device, GeneratedFile, RawFileName, 0, [], true, false),
  ?DBG_MODULE_INFO("for_each_line_in_file(FileName, GeneratedFile, RawFileName) -> -> end method...  ~n", [?MODULE]),

  file:close(Device),
  ok.


%% @doc
%% Read lines from message files
%%
%% @spec
%% @end

-spec for_each_line_in_srv_file(FileName, GeneratedFileReq, GeneratedFileResp, RawFileName) -> ok when FileName :: string(), GeneratedFileReq :: term(),
  GeneratedFileResp :: term(), RawFileName :: string().

for_each_line_in_srv_file(FileName, GeneratedFileReq, GeneratedFileResp, RawFileName) ->
  {ok, Device} = file:open(FileName, [read]),
  file:write(GeneratedFileReq, ?CPP_MSG_FILE_HEADER(string:join([RawFileName, "Req"], ""))), %% Write header template
  for_each_line(Device, GeneratedFileReq, string:join([RawFileName, "Req"], ""), 0, [], false, true),
  ?DBG_MODULE_INFO("for_each_line_in_file(FileName, GeneratedFile, RawFileName) -> -> end method...  ~n", [?MODULE]),

  file:write(GeneratedFileResp, ?CPP_MSG_FILE_HEADER(string:join([RawFileName, "Resp"], ""))),
  for_each_line(Device, GeneratedFileResp, string:join([RawFileName, "Resp"], ""), 0, [], false, false),
  ?DBG_MODULE_INFO("for_each_line_in_file(FileName, GeneratedFile, RawFileName) -> -> end method...  ~n", [?MODULE]),

  file:close(Device),
  ok.


for_each_line(Device, GeneratedFile, RawFileName, ObjCount, AllFieldsList, IsMessage, IsRequest) ->
  case io:get_line(Device, "") of
    EndPath when EndPath == eof;EndPath == "---\n" ->

      parameters_constructor_generate(GeneratedFile, AllFieldsList),

      file:write(GeneratedFile, ?CONSRTUCTOR(RawFileName, ObjCount)), %% Generate class constructor

      ResultString = generate_constructor_matchable_return_value("", AllFieldsList),

      file:write(GeneratedFile, ?CONSTRUCTOR_HEADER_WITH_PARAMS(RawFileName, ObjCount, ResultString)),

      case IsMessage of
        true ->
          file:write(GeneratedFile, ?SEND_MESSAGE_FUNCTION(generate_send_topic_message_tuple("", AllFieldsList))),
          file:write(GeneratedFile, ?SEND_SERVICE_RESPONSE_FOR_MESSAGES_FUNCTION);

        _ ->
          file:write(GeneratedFile, ?SEND_MESSAGE_FOR_SERVICE_FUNCTION)
      end,

      case IsRequest of
        true when IsMessage == false ->
          file:write(GeneratedFile, ?SEND_SERVICE_RESPONSE_FOR_MESSAGES_FUNCTION);

        false when IsMessage == false ->
          ServiceResultString = generate_send_topic_message_tuple("", AllFieldsList),
          file:write(GeneratedFile, ?SEND_SERVICE_RESPONSE_FOR_RESP_FUNCTION(RawFileName, ServiceResultString));

        _ -> ok
      end,

      file:write(GeneratedFile, ?GET_TUPLE_MESSAGE(
        generate_get_tuple_message("", AllFieldsList), generate_send_topic_message_tuple("", AllFieldsList))),


      DefaultValuesResultString = generate_set_default_value("", AllFieldsList),
      file:write(GeneratedFile, ?SET_DEFAULT_VALUES_FUNCTION(DefaultValuesResultString)),

      %parameters_dafault_generate(GeneratedFile, AllFieldsList),

      %file:write(GeneratedFile, ?CONSTRUCTOR_START_MSG_PARSE),

      %getters_setters_generation(GeneratedFile, AllFieldsList), %% Generate getter and setter methods

      %file:write(GeneratedFile, ?GET_OTP_TYPE_MSG), %% Generate Get_Msg interface method

      file:write(GeneratedFile, string:join([?NEW_LINE, "};"], "")),

      file:close(GeneratedFile),
      ?DBG_MODULE_INFO("for_each_line(Device, GeneratedFile, RawFileName, ObjCount, AllFieldsList) -> all files closed...  ~n", [?MODULE]),
      ok;
    Line ->
      ?DBG_INFO("line: ~p~n", [Line]),
      [Type, Name] = re:split(Line,"[ ]",[{return, list}]),
      NewName = Name -- "\n",

      for_each_line(Device, GeneratedFile, RawFileName, ObjCount + 1, [{Type, NewName, ObjCount} | AllFieldsList], IsMessage, IsRequest)
  end,
  ok.


generate_constructor_matchable_return_value(ResultString, []) ->
  ?CONSTRUCTOR_MATCHABLE_FINAL(ResultString);
generate_constructor_matchable_return_value(ResultString, [{Type, Name, _} | FieldsList]) ->
  NewResultString = ?CONSTRUCTOR_MATCHABLE(Type, Name, ResultString),
  case FieldsList of
    [] ->
      NewResultStringComma = NewResultString;
    _ ->
      NewResultStringComma = ?COMMA_DELIMETER(NewResultString)
  end,
  generate_constructor_matchable_return_value(NewResultStringComma, FieldsList).


generate_send_topic_message_tuple(ResultString, []) ->
  ResultString;
generate_send_topic_message_tuple(ResultString, [{Type, Name, _} | FieldsList]) ->
  NewResultString = ?SEND_MESSAGE_TUPLE(Type, Name, ResultString),
  case FieldsList of
    [] ->
      NewResultStringComma = NewResultString;
    _ ->
      NewResultStringComma = ?COMMA_DELIMETER(NewResultString)
  end,
  generate_send_topic_message_tuple(NewResultStringComma, FieldsList).


generate_get_tuple_message(ResultString, []) ->
  ResultString;
generate_get_tuple_message(ResultString, [{Type, Name, _} | FieldsList]) ->
  NewResultString = ?GET_TUPLE_MESSAGE_TYPE(Type, Name, ResultString),
  case FieldsList of
    [] ->
      NewResultStringComma = NewResultString;
    _ ->
      NewResultStringComma = ?COMMA_DELIMETER(NewResultString)
  end,
  generate_get_tuple_message(NewResultStringComma, FieldsList).


generate_set_default_value(ResultString, []) ->
  ResultString;
generate_set_default_value(ResultString, [{Type, Name, _} | FieldsList]) ->
  NewResultString = ?SET_DEFALUT_PARAMETER(ResultString, Name, Type),
  generate_set_default_value(NewResultString, FieldsList).


getters_setters_generation(_, []) ->
  ?DBG_MODULE_INFO("getters_setters_generation(_, []) -> end method ~n", [?MODULE]),
  ok;
getters_setters_generation(GeneratedFile ,[{Type, Name, ObjCount} | FieldsList]) ->
  ?DBG_INFO("generated info: ~p~n", [{Type, Name, ObjCount}]),
  file:write(GeneratedFile, ?GETTER_SETTER_GENERATE(Type, Name, ObjCount)),
  getters_setters_generation(GeneratedFile, FieldsList).

parameters_constructor_generate(_, []) -> ok;
parameters_constructor_generate(GeneratedFile ,[{Type, Name, ObjCount} | FieldsList]) ->
  file:write(GeneratedFile, ?CONSRTUCTOR_WITH_PARAMS_CREATE_PARAMETER(Type, Name, ObjCount)),
  parameters_constructor_generate(GeneratedFile , FieldsList).


parameters_dafault_generate(_, []) -> ok;
parameters_dafault_generate(GeneratedFile ,[{Type, Name, _} | FieldsList]) ->
  file:write(GeneratedFile, ?CREATE_DEFAULT_PARAMETER_VALUE(Type, Name)),
  parameters_dafault_generate(GeneratedFile , FieldsList).
