%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015
%%% @doc
%%%
%%% @end
%%%-------------------------------------------------------------------
-include("env_params.hrl").
-include("ibot_core_spec_symbols.hrl").


-define(MKDIR_PROJECT_FOLDER(Path, Folder), list_to_atom(string:join(["mkdir \"" , Path, ?PATH_DELIMETER_SYMBOL,Folder, "\""], ""))).
-define(MKDIR_PROJECT_SUB_FOLDER(Path, Prohect_Folder, Folder),
  list_to_atom(string:join(["mkdir \"", Path, ?PATH_DELIMETER_SYMBOL, Prohect_Folder, ?PATH_DELIMETER_SYMBOL, Folder, "\""], ""))).
-define(MKDIR_PROJECT_NODE_FOLDER(Path, Folder), list_to_atom(string:join(["mkdir \"", Path, ?PATH_DELIMETER_SYMBOL, Folder], ""))).
-define(MKDIR_PROJECT_CREATE_FOLDER(Path, Folder), list_to_atom(string:join(["mkdir \"", Path, ?PATH_DELIMETER_SYMBOL, Folder], ""))).

-define(DEV_FOLDER_LIST(PathFolder, ProjectFolder, DevFolder), [
  list_to_atom(string:join(["mkdir \"", PathFolder, ?PATH_DELIMETER_SYMBOL, ProjectFolder, ?PATH_DELIMETER_SYMBOL, DevFolder, ?PATH_DELIMETER_SYMBOL, ?DEV_FOLDER_MESSAGES,"\""], "")),
  list_to_atom(string:join(["mkdir \"", PathFolder, ?PATH_DELIMETER_SYMBOL, ProjectFolder, ?PATH_DELIMETER_SYMBOL, DevFolder, ?PATH_DELIMETER_SYMBOL, ?DEV_FOLDER_MESSAGES, ?PATH_DELIMETER_SYMBOL, ?JAVA_FOLDER,"\""], "")),
  list_to_atom(string:join(["mkdir \"", PathFolder, ?PATH_DELIMETER_SYMBOL, ProjectFolder, ?PATH_DELIMETER_SYMBOL, DevFolder, ?PATH_DELIMETER_SYMBOL, ?DEV_FOLDER_SERVICES,"\""], "")),
  list_to_atom(string:join(["mkdir \"", PathFolder, ?PATH_DELIMETER_SYMBOL, ProjectFolder, ?PATH_DELIMETER_SYMBOL, DevFolder, ?PATH_DELIMETER_SYMBOL, ?DEV_FOLDER_SERVICES, ?PATH_DELIMETER_SYMBOL, ?JAVA_FOLDER,"\""], ""))
]).

-define(JAVA_SRC, "src"). %% Java node source file directory name
-define(JAVA_NODE_FOLDERS(Path, NodeName), %% Java node directory names list
  [list_to_atom(string:join(["mkdir \"", Path, ?PATH_DELIMETER_SYMBOL, ?PROJECT_SRC, ?PATH_DELIMETER_SYMBOL, NodeName, "\""], "")),
    list_to_atom(string:join(["mkdir \"", Path, ?PATH_DELIMETER_SYMBOL, ?PROJECT_SRC, ?PATH_DELIMETER_SYMBOL, NodeName, ?PATH_DELIMETER_SYMBOL, ?JAVA_SRC, "\""], "")),
    list_to_atom(string:join(["mkdir \"", Path, ?PATH_DELIMETER_SYMBOL, ?PROJECT_SRC, ?PATH_DELIMETER_SYMBOL, NodeName, ?PATH_DELIMETER_SYMBOL, ?MESSAGE_DIR, "\""], "")),
    list_to_atom(string:join(["mkdir \"", Path, ?PATH_DELIMETER_SYMBOL, ?PROJECT_SRC, ?PATH_DELIMETER_SYMBOL, NodeName, ?PATH_DELIMETER_SYMBOL, ?SERVICE_DIR, "\""], ""))]).