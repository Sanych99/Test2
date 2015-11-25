%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. Mar 2015 10:20 PM
%%%-------------------------------------------------------------------
-include("../../ibot_core/include/ibot_core_spec_symbols.hrl").
-include("project_dirs.hrl").

-define(DEV_MESSAGE_FOLDER, "msg").

-define(DEV_MSG_PATH_DIR(Path), string:join([Path, ?PATH_DELIMETER_SYMBOL, ?DEV_FOLDER, ?PATH_DELIMETER_SYMBOL, ?DEV_MSG_PATH], "")).
-define(DEV_SRV_PATH_DIR(Path), string:join([Path, ?PATH_DELIMETER_SYMBOL, ?DEV_FOLDER, ?PATH_DELIMETER_SYMBOL, ?DEV_SRV_PATH], "")).

-define(DEV_MSG_JAVA_PATH(Path), string:join([Path, ?PATH_DELIMETER_SYMBOL, ?JAVA_FOLDER], "")).
-define(DEV_SRV_JAVA_PATH(Path), string:join([Path, ?PATH_DELIMETER_SYMBOL, ?JAVA_FOLDER], "")).


-define(DEV_MSG_PYTHON_PATH(Path), string:join([Path, ?PATH_DELIMETER_SYMBOL, ?PYTHON_FOLDER, ?PATH_DELIMETER_SYMBOL, ?PYTHON_MESSAGES_FOLDER], "")).
-define(DEV_SRV_PYTHON_PATH(Path), string:join([Path, ?PATH_DELIMETER_SYMBOL, ?PYTHON_FOLDER, ?PATH_DELIMETER_SYMBOL, ?PYTHON_SERVICES_FOLDER], "")).

-define(DEV_MSG_CPP_PATH(Path), string:join([Path, ?PATH_DELIMETER_SYMBOL, ?CPP_FOLDER], "")).
-define(DEV_SRV_CPP_PATH(Path), string:join([Path, ?PATH_DELIMETER_SYMBOL, ?CPP_FOLDER], "")).


-define(DEV_MSG_JS_PATH(Path), string:join([Path, ?PATH_DELIMETER_SYMBOL, ?JS_FOLDER], "")).
-define(DEV_SRV_JS_PATH(Path), string:join([Path, ?PATH_DELIMETER_SYMBOL, ?JS_FOLDER], "")).

-define(PATH_TO_CREATE_MSG_SRV_JAR,
  case os:type() of
    {unix,linux} ->
      {ok, CurrentDir} = file:get_cwd(),
      string:join([CurrentDir, "lib", "ibot_core-1", "priv", "create_jar.sh"], ?PATH_DELIMETER_SYMBOL);
    _ -> ""
  end
).

-define(PATH_TO_INSTALL_MSG_SRV_PYTHON,
  case os:type() of
    {unix,linux} ->
      {ok, CurrentDirProject} = file:get_cwd(),
      string:join([CurrentDirProject, "lib", "ibot_core-1", "priv", "install_py_msg_srv.sh"], ?PATH_DELIMETER_SYMBOL);
    _ -> ""
  end
).