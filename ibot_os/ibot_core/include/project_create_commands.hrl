%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015
%%% @doc
%%%
%%% @end
%%%-------------------------------------------------------------------
-author("alex").
-define(MKDIR_PROJECT_FOLDER(Path, Folder), list_to_atom("mkdir \"" ++ Path ++ "/" ++ Folder ++ "\"")).
-define(MKDIR_PROJECT_SUB_FOLDER(Path, Prohect_Folder, Folder), list_to_atom("mkdir \"" ++ Path ++ "/" ++ Prohect_Folder ++ "/" ++ Folder ++ "\"")).
-define(MKDIR_PROJECT_NODE_FOLDER(Path, Folder), list_to_atom("mkdir \"" ++ Path ++ "/" ++ Folder ++ "\"")).

-define(PROJECT_SRC, "src").

-define(MESSAGE_DIR, "msg"). %% Node messages directory name
-define(SERVICE_DIR, "srv"). %% Node services directory name

-define(JAVA_SRC, "src"). %% Java node source file directory name
-define(JAVA_NODE_FOLDERS(Path, NodeName), %% Java node directory names list
  [list_to_atom("mkdir \"" ++ Path ++ "/" ++ ?PROJECT_SRC ++ "/" ++ NodeName ++ "\""),
    list_to_atom("mkdir \"" ++ Path ++ "/" ++ ?PROJECT_SRC ++ "/" ++ NodeName ++ "/" ++ ?JAVA_SRC ++ "\""),
    list_to_atom("mkdir \"" ++ Path ++ "/" ++ ?PROJECT_SRC ++ "/" ++ NodeName ++ "/" ++ ?MESSAGE_DIR ++ "\""),
    list_to_atom("mkdir \"" ++ Path ++ "/" ++ ?PROJECT_SRC ++ "/" ++ NodeName ++ "/" ++ ?SERVICE_DIR ++ "\"")]).