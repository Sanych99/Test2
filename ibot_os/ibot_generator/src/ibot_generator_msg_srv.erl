%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. Mar 2015 10:35 PM
%%%-------------------------------------------------------------------
-module(ibot_generator_msg_srv).

-include("../../ibot_core/include/debug.hrl").
-include("msg_srv_java_generate_templates.hrl").
-include("msg_srv_compile_commands.hrl").
-include("project_paths.hrl").
-include("spec_file_ext.hrl").
-include("../../ibot_db/include/ibot_db_table_names.hrl").
-include("../../ibot_db/include/ibot_db_project_config_param.hrl").


%% API
-export([generate_msg_srv/1, generate_all_msg_srv/0]).

%% @doc
%% Generate message files
%%]
%% @spec generate_msg_srv(ProjectDir)
%% @end

-spec generate_msg_srv(ProjectDir) -> ok when ProjectDir :: string().

generate_msg_srv(ProjectDir) ->
  generate_msg_source_files(filelib:wildcard(string:join([ProjectDir, ?SRC_FOLDER, "*",
    ?MESSAGE_DIR, ?MSG_FILE_EXT], ?DELIM_SYMBOL)), ProjectDir), %% Generate all msg source files

  ibot_generator_func_python:generate_msg_source_files(filelib:wildcard(string:join([ProjectDir, ?SRC_FOLDER, "*",
    ?MESSAGE_DIR, ?MSG_FILE_EXT], ?DELIM_SYMBOL)), ProjectDir),

  ibot_generator_func_js:generate_msg_source_files(filelib:wildcard(string:join([ProjectDir, ?SRC_FOLDER, "*",
    ?MESSAGE_DIR, ?MSG_FILE_EXT], ?DELIM_SYMBOL)), ProjectDir),




  generate_srv_source_files(filelib:wildcard(string:join([ProjectDir, ?SRC_FOLDER, "*",
    ?SERVICE_DIR, ?SRV_FILE_EXT], ?DELIM_SYMBOL)), ProjectDir), %% Generate all srv source files

  ibot_generator_func_python:generate_srv_source_files(filelib:wildcard(string:join([ProjectDir, ?SRC_FOLDER, "*",
    ?SERVICE_DIR, ?SRV_FILE_EXT], ?DELIM_SYMBOL)), ProjectDir), %% Generate all srv source files

  ibot_generator_func_js:generate_srv_source_files(filelib:wildcard(string:join([ProjectDir, ?SRC_FOLDER, "*",
    ?SERVICE_DIR, ?SRV_FILE_EXT], ?DELIM_SYMBOL)), ProjectDir), %% Generate all srv source files
  ok.


generate_all_msg_srv() ->
  case ibot_db_func:get(?TABLE_CONFIG, ?FULL_PROJECT_PATH) of
    [{?FULL_PROJECT_PATH, ProjectPath}] ->
      ?DBG_MODULE_INFO("generate_all_msg_srv() -> start method ~n", [?MODULE]),
      %%generate_msg_source_files(filelib:wildcard(string:join([ProjectPath, ?SRC_FOLDER, "*",
      %%?MESSAGE_DIR, ?MSG_FILE_EXT], ?DELIM_SYMBOL)), ProjectPath); %% Generate all msg and srv source files
      generate_msg_srv(ProjectPath);
    _ ->
      {error, project_full_path_not_found}
  end,
  ?DBG_MODULE_INFO("generate_all_msg_srv() -> end method ~n", [?MODULE]),
  ok.




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

  JavaProjectMsgPath = ?DEV_MSG_JAVA_PATH(ProjectMsgPath), %% Java msg generated files folder

  {ok, GeneratedFile} = file:open(string:join([JavaProjectMsgPath, ?DELIM_SYMBOL, RawFileName, ".java"], ""), [write]), %% Open generated file

  for_each_line_in_msg_file(FileName, GeneratedFile, RawFileName), %% Generate properties code

  generate_msg_source_files(FilesList, ProjectDir), %% Generate next file
  ok;
generate_msg_source_files([], _ProjectDir) ->
  %% Create JAR library for JAVA messages
  ibot_core_func_cmd:run_exec(?JAVA_COMPILE_MSG_SOURCES),
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

  JavaProjectMsgPath = ?DEV_SRV_JAVA_PATH(ProjectMsgPath), %% Java msg generated files folder

  {ok, GeneratedFileReq} = file:open(string:join([JavaProjectMsgPath, ?DELIM_SYMBOL, RawFileName, "Req.java"], ""), [write]), %% Open generated file

  {ok, GeneratedFileResp} = file:open(string:join([JavaProjectMsgPath, ?DELIM_SYMBOL, RawFileName, "Resp.java"], ""), [write]), %% Open generated file

  for_each_line_in_srv_file(FileName, GeneratedFileReq, GeneratedFileResp,RawFileName), %% Generate properties code

  generate_srv_source_files(FilesList, ProjectDir), %% Generate next file
  ok;
generate_srv_source_files([], _ProjectDir) ->
  %% Create JAR library for JAVA messages
  ibot_core_func_cmd:run_exec(?JAVA_COMPILE_SRV_SOURCES),
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
  file:write(GeneratedFile, ?JAVA_MSG_FILE_HEADER(RawFileName)), %% Write header template
  for_each_line(Device, GeneratedFile, RawFileName, 0, []),
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
  file:write(GeneratedFileReq, ?JAVA_MSG_FILE_HEADER(string:join([RawFileName, "Req"], ""))), %% Write header template
  for_each_line(Device, GeneratedFileReq, string:join([RawFileName, "Req"], ""), 0, []),
  ?DBG_MODULE_INFO("for_each_line_in_file(FileName, GeneratedFile, RawFileName) -> -> end method...  ~n", [?MODULE]),

  file:write(GeneratedFileResp, ?JAVA_MSG_FILE_HEADER(string:join([RawFileName, "Resp"], ""))),
  for_each_line(Device, GeneratedFileResp, string:join([RawFileName, "Resp"], ""), 0, []),
  ?DBG_MODULE_INFO("for_each_line_in_file(FileName, GeneratedFile, RawFileName) -> -> end method...  ~n", [?MODULE]),

  file:close(Device),
  ok.


for_each_line(Device, GeneratedFile, RawFileName, ObjCount, AllFieldsList) ->
  case io:get_line(Device, "") of
    EndPath when EndPath == eof;EndPath == "---\n" ->
      file:write(GeneratedFile, ?CONSRTUCTOR(RawFileName, ObjCount)), %% Generate class constructor
      file:write(GeneratedFile, ?GET_OTP_TYPE_MSG), %% Generate Get_Msg interface method

      file:write(GeneratedFile, ?CONSTRUCTOR_HEADER_WITH_PARAMS(RawFileName, ObjCount)),
      parameters_constructor_generate(GeneratedFile, AllFieldsList),
      file:write(GeneratedFile, ?CONSTRUCTOR_END_WITH_PARAMS()),

      file:write(GeneratedFile, ?SET_DEFAULT_VALUE_METHOD_START),
      parameters_dafault_generate(GeneratedFile, AllFieldsList),
      file:write(GeneratedFile, ?SET_DEFAULT_VALUE_METHOD_END),

      getters_setters_generation(GeneratedFile, AllFieldsList), %% Generate getter and setter methods
      file:write(GeneratedFile, ?JAVA_MSG_FILE_END), %% Generate end of file

      file:close(GeneratedFile),
      ?DBG_MODULE_INFO("for_each_line(Device, GeneratedFile, RawFileName, ObjCount, AllFieldsList) -> all files closed...  ~n", [?MODULE]),
      ok;
    Line ->
      ?DBG_INFO("line: ~p~n", [Line]),
      [Type, Name] = re:split(Line,"[ ]",[{return, list}]),
      NewName = Name -- "\n",
      file:write(GeneratedFile, ?PRIVATE_PROPERTIES_OTP_LANG(Type, NewName)),
      for_each_line(Device, GeneratedFile, RawFileName, ObjCount + 1, [{Type, NewName, ObjCount} | AllFieldsList])
  end,
  ok.

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
  file:write(GeneratedFile, ?SET_DEFAULT_VALUE_METHOD_PARAMETER(Type, Name)),
  parameters_dafault_generate(GeneratedFile , FieldsList).