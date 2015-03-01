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
  for_each_line(Device, GeneratedFile, RawFileName),
  ok.


for_each_line(Device, GeneratedFile, RawFileName) ->
  case io:get_line(Device, "") of
    eof ->
      file:write(GeneratedFile, ?JAVA_MSG_FILE_END),
      file:close(Device),
      file:close(GeneratedFile),
      ok;
    Line ->
      ?DBG_INFO("line: ~p~n", [Line]),
      [Type, Name] = re:split(Line,"[ ]",[{return, list}]),
      file:write(GeneratedFile, ?PRIVATE_PROPERTIES_OTP_LANG(Type, Name)),
      for_each_line(Device, GeneratedFile, RawFileName)
  end,
  ok.