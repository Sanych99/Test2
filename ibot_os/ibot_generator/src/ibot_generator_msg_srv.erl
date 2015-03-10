%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. Mar 2015 10:35 PM
%%%-------------------------------------------------------------------
-module(ibot_generator_msg_srv).

-include("config_db_keys.hrl").
-include("debug.hrl").
-include("msg_srv_java_generate_templates.hrl").
-include("msg_srv_compile_commands.hrl").
-include("project_paths.hrl").
-include("spec_file_ext.hrl").


%% API
-export([generate_msg_srv/1]).

%% @doc
%% Generate message files
%%
%% @spec generate_msg_srv(ProjectDir) w
%% @end

-spec generate_msg_srv(ProjectDir) -> ok when ProjectDir :: string().

generate_msg_srv(ProjectDir) ->
  generate_msg_srv_source_files(filelib:wildcard(string:join([ProjectDir, ?SRC_FOLDER, "*",
    ?MESSAGE_DIR, ?MSG_FILE_EXT], ?DELIM_SYMBOL)), ProjectDir), %% Generate all msg and srv source files
  ok.




%% @doc
%% Generate message source files for language
%%
%% @spec
%% @end

-spec generate_msg_srv_source_files([FileName | FilesList], ProjectDir) -> ok when FileName ::string(),
  FilesList :: string(), ProjectDir :: string().

generate_msg_srv_source_files([FileName | FilesList], ProjectDir) ->
  ?DBG_INFO("files for generate: ~p~n", [[FileName | FilesList]]),

  RawFileName = filename:basename(FileName, ".msg"), %% File name without path and extension

  ProjectMsgPath = ?DEV_MSG_PATH(ProjectDir), %% Project path

  JavaProjectMsgPath = ?DEV_MSG_JAVA_PATH(ProjectMsgPath), %% Java msg generated files folder

  {ok, GeneratedFile} = file:open(string:join([JavaProjectMsgPath, ?DELIM_SYMBOL, RawFileName, ".java"], ""), [write]), %% Open generated file

  for_each_line_in_file(FileName, GeneratedFile,RawFileName), %% Generate properties code

  generate_msg_srv_source_files(FilesList, ProjectDir), %% Generate next file
  ok;
generate_msg_srv_source_files([], _ProjectDir) ->
  %% Create JAR library for JAVA messages
  ibot_core_cmd:run_exec(?JAVA_COMPILE_MSG_SRV_SOURCES),
  ok.




%% @doc
%% Read lines from message files
%%
%% @spec
%% @end

-spec for_each_line_in_file(FileName, GeneratedFile, RawFileName) -> ok when FileName :: string(), GeneratedFile :: term(),
  RawFileName :: string().

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
  ?DBG_INFO("generated info: ~p~n", [{Type, Name, ObjCount}]),
  file:write(GeneratedFile, ?GETTER_SETTER_GENERATE(Type, Name, ObjCount)),
  getters_setters_generation(GeneratedFile, FieldsList).