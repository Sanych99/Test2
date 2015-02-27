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
-define(MKDIR_PROJECT_NODE_FOLDER(Path, Prohect_Folder, Folder), list_to_atom("mkdir \"" ++ Path ++ "/" ++ Folder ++ "\"")).

-define(JAVA_SRC, "src").
-define(JAVA_NODE_FOLDERS(Path, NodeName),
  [list_to_atom("mkdir \"" ++ Path ++ "/" ++ NodeName ++ "\""),
    list_to_atom("mkdir \"" ++ Path ++ "/" ++ Folder ++ "/" ++ ?JAVA_SRC ++ "\"")]).