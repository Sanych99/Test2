%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. Jun 2015 1:02 AM
%%%-------------------------------------------------------------------
-module(ibot_generator_func_js).

-include("../../ibot_core/include/debug.hrl").
-include("project_paths.hrl").
-include("msg_srv_js_generate_templates.hrl").

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

  JsProjectMsgPath = ?DEV_MSG_JS_PATH(ProjectMsgPath), %% Java msg generated files folder

  {ok, GeneratedFile} = file:open(string:join([JsProjectMsgPath, ?DELIM_SYMBOL, RawFileName, ".js"], ""), [write]), %% Open generated file

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

  JsProjectMsgPath = ?DEV_SRV_JS_PATH(ProjectMsgPath), %% Java msg generated files folder

  {ok, GeneratedFileReq} = file:open(string:join([JsProjectMsgPath, ?DELIM_SYMBOL, RawFileName, "Req.js"], ""), [write]), %% Open generated file

  {ok, GeneratedFileResp} = file:open(string:join([JsProjectMsgPath, ?DELIM_SYMBOL, RawFileName, "Resp.js"], ""), [write]), %% Open generated file

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
  file:write(GeneratedFile, ?JS_MSG_FILE_HEADER(RawFileName)), %% Write header template
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
  file:write(GeneratedFileReq, ?JS_MSG_FILE_HEADER(string:join([RawFileName, "Req"], ""))), %% Write header template
  for_each_line(Device, GeneratedFileReq, string:join([RawFileName, "Req"], ""), 0, []),
  ?DBG_MODULE_INFO("for_each_line_in_file(FileName, GeneratedFile, RawFileName) -> -> end method...  ~n", [?MODULE]),

  file:write(GeneratedFileResp, ?JS_MSG_FILE_HEADER(string:join([RawFileName, "Resp"], ""))),
  for_each_line(Device, GeneratedFileResp, string:join([RawFileName, "Resp"], ""), 0, []),
  ?DBG_MODULE_INFO("for_each_line_in_file(FileName, GeneratedFile, RawFileName) -> -> end method...  ~n", [?MODULE]),

  file:close(Device),
  ok.


for_each_line(Device, GeneratedFile, RawFileName, ObjCount, AllFieldsList) ->
  case io:get_line(Device, "") of
    EndPath when EndPath == eof;EndPath == "---\n" ->
      %file:write(GeneratedFile, ?CONSRTUCTOR(RawFileName, ObjCount)), %% Generate class constructor

      getters_setters_generation(GeneratedFile, AllFieldsList), %% Generate getter and setter methods

      file:write(GeneratedFile, ?CONSTRUCTOR_HEADER_WITH_PARAMS(RawFileName, ObjCount)),

      parameters_constructor_generate(GeneratedFile, AllFieldsList),
      file:write(GeneratedFile, ?END_BLOCK(1)),

      file:write(GeneratedFile, ?GET_OTP_TYPE_MSG), %% Generate Get_Msg interface method

      file:write(GeneratedFile, ?END_BLOCK(0)),


      %file:write(GeneratedFile, ?JAVA_MSG_FILE_END), %% Generate end of file



      file:close(GeneratedFile),
      ?DBG_MODULE_INFO("for_each_line(Device, GeneratedFile, RawFileName, ObjCount, AllFieldsList) -> all files closed...  ~n", [?MODULE]),
      ok;
    Line ->
      ?DBG_INFO("line: ~p~n", [Line]),
      [Type, Name] = re:split(Line,"[ ]",[{return, list}]),
      NewName = Name -- "\n",
      %file:write(GeneratedFile, ?PRIVATE_PROPERTIES_OTP_LANG(Type, NewName)),
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

parameters_constructor_generate(_, []) ->
  ok;
parameters_constructor_generate(GeneratedFile ,[{Type, Name, ObjCount} | FieldsList]) ->
  file:write(GeneratedFile, ?CONSRTUCTOR_WITH_PARAMS_CREATE_PARAMETER(Type, Name, ObjCount)),
  parameters_constructor_generate(GeneratedFile , FieldsList).
