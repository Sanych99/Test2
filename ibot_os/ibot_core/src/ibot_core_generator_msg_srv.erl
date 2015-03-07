%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. Mar 2015 10:35 PM
%%%-------------------------------------------------------------------
-module(ibot_core_generator_msg_srv).

-include("env_params.hrl").
-include("spec_file_ext.hrl").
-include("msg_srv_java_generate_templates.hrl").
-include("debug.hrl").

%% API
-export([generate_msg_srv/1]).

generate_msg_srv(ProjectDir) ->
  generate_msg_srv_source_files(filelib:wildcard(string:join([ProjectDir, ?SRC_FOLDER, "*",
    ?MESSAGE_DIR, ?MSG_FILE_EXT], ?DELIM_PATH_SYMBOL))), %% Generate all msg and srv source files
  ok.


generate_msg_srv_source_files([FileName | FilesList]) ->
  ?DBG_INFO("files for generate: ~p~n", [[FileName | FilesList]]),

  RawFileName = filename:basename(FileName, ".msg"), %% File name without path and extension
  {ok, GeneratedFile} = file:open("/home/alex/ErlangTest/test_project/src/test_node/msg/"
  ++ RawFileName ++ ".java", [write]), %% Open generated file


  for_each_line_in_file(FileName, GeneratedFile,RawFileName), %% Generate properties code

  generate_msg_srv_source_files(FilesList), %% Generate next file
  ok;
generate_msg_srv_source_files([]) ->
  ok.


for_each_line_in_file(FileName, GeneratedFile, RawFileName) ->
  {ok, Device} = file:open(FileName, [read]),
  file:write(GeneratedFile, ?JAVA_MSG_FILE_HEADER(RawFileName)), %% Write header template
  for_each_line(Device, GeneratedFile, RawFileName, 0, []),
  ok.


for_each_line(Device, GeneratedFile, RawFileName, ObjCount, AllFieldsList) ->
  case io:get_line(Device, "") of
    eof ->
      file:write(GeneratedFile, ?CONSRTUCTOR(RawFileName, ObjCount)), %% Generate class constructor
      file:write(GeneratedFile, ?GET_OTP_TYPE_MSG), %% Generate Get_Msg interface method
      getters_setters_generation(GeneratedFile, AllFieldsList), %% Generate getter and setter methods
      file:write(GeneratedFile, ?JAVA_MSG_FILE_END), %% Generate end of file

      file:close(Device),
      file:close(GeneratedFile),
      ok;
    Line ->
      ?DBG_INFO("line: ~p~n", [Line]),
      [Type, Name] = re:split(Line,"[ ]",[{return, list}]),
      NewName = Name -- "\n",
      file:write(GeneratedFile, ?PRIVATE_PROPERTIES_OTP_LANG(Type, NewName)),
      for_each_line(Device, GeneratedFile, RawFileName, ObjCount + 1, [{Type, NewName, ObjCount} | AllFieldsList])
  end,
  ok.

getters_setters_generation(_, []) -> ok;
getters_setters_generation(GeneratedFile ,[{Type, Name, ObjCount} | FieldsList]) ->
  ?DBG_INFO("gemerated info: ~p~n", [{Type, Name, ObjCount}]),
  file:write(GeneratedFile, ?GETTER_SETTER_GENERATE(Type, Name, ObjCount)),
  getters_setters_generation(GeneratedFile, FieldsList).