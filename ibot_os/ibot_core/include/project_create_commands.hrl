%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015
%%% @doc
%%%
%%% @end
%%%-------------------------------------------------------------------
-include("env_params.hrl").

-define(MKDIR_PROJECT_FOLDER(Path, Folder), list_to_atom("mkdir \"" ++ Path ++ ?DELIM_PATH_SYMBOL ++ Folder ++ "\"")).
-define(MKDIR_PROJECT_SUB_FOLDER(Path, Prohect_Folder, Folder), list_to_atom("mkdir \"" ++ Path ++ ?DELIM_PATH_SYMBOL ++ Prohect_Folder ++ ?DELIM_PATH_SYMBOL ++ Folder ++ "\"")).
-define(MKDIR_PROJECT_NODE_FOLDER(Path, Folder), list_to_atom("mkdir \"" ++ Path ++ ?DELIM_PATH_SYMBOL ++ Folder ++ "\"")).

-define(JAVA_SRC, "src"). %% Java node source file directory name
-define(JAVA_NODE_FOLDERS(Path, NodeName), %% Java node directory names list
  [list_to_atom("mkdir \"" ++ Path ++ ?DELIM_PATH_SYMBOL ++ ?PROJECT_SRC ++ ?DELIM_PATH_SYMBOL ++ NodeName ++ "\""),
    list_to_atom("mkdir \"" ++ Path ++ ?DELIM_PATH_SYMBOL ++ ?PROJECT_SRC ++ ?DELIM_PATH_SYMBOL ++ NodeName ++ ?DELIM_PATH_SYMBOL ++ ?JAVA_SRC ++ "\""),
    list_to_atom("mkdir \"" ++ Path ++ ?DELIM_PATH_SYMBOL ++ ?PROJECT_SRC ++ ?DELIM_PATH_SYMBOL ++ NodeName ++ ?DELIM_PATH_SYMBOL ++ ?MESSAGE_DIR ++ "\""),
    list_to_atom("mkdir \"" ++ Path ++ ?DELIM_PATH_SYMBOL ++ ?PROJECT_SRC ++ ?DELIM_PATH_SYMBOL ++ NodeName ++ ?DELIM_PATH_SYMBOL ++ ?SERVICE_DIR ++ "\"")]).