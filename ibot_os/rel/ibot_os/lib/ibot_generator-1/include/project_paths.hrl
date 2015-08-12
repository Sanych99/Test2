%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. Mar 2015 10:20 PM
%%%-------------------------------------------------------------------
-include("spec_symbols.hrl").
-include("project_dirs.hrl").

-define(DEV_MESSAGE_FOLDER, "msg").

-define(DEV_MSG_PATH_DIR(Path), string:join([Path, ?DELIM_SYMBOL, ?DEV_FOLDER, ?DELIM_SYMBOL, ?DEV_MSG_PATH], "")).
-define(DEV_SRV_PATH_DIR(Path), string:join([Path, ?DELIM_SYMBOL, ?DEV_FOLDER, ?DELIM_SYMBOL, ?DEV_SRV_PATH], "")).

-define(DEV_MSG_JAVA_PATH(Path), string:join([Path, ?DELIM_SYMBOL, ?JAVA_FOLDER], "")).
-define(DEV_SRV_JAVA_PATH(Path), string:join([Path, ?DELIM_SYMBOL, ?JAVA_FOLDER], "")).


-define(DEV_MSG_PYTHON_PATH(Path), string:join([Path, ?DELIM_SYMBOL, ?PYTHON_FOLDER], "")).
-define(DEV_SRV_PYTHON_PATH(Path), string:join([Path, ?DELIM_SYMBOL, ?PYTHON_FOLDER], "")).


-define(DEV_MSG_JS_PATH(Path), string:join([Path, ?DELIM_SYMBOL, ?JS_FOLDER], "")).
-define(DEV_SRV_JS_PATH(Path), string:join([Path, ?DELIM_SYMBOL, ?JS_FOLDER], "")).