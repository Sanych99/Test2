%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015
%%% @doc
%%%
%%% @end
%%% Created : 19. Февр. 2015 19:20
%%%-------------------------------------------------------------------
-module(ibot_core_func_cmd_cdir).
-export([create_project/2, create_node/2, copy_dir/2, move_dir/2, remove_dir/1, create_dir/1, del_dir/1]).

-include("debug.hrl").
-include("project_create_commands.hrl").
-include("ibot_core_reserve_atoms.hrl").
-include("../../ibot_db/include/ibot_db_project_config_param.hrl").
-include("../../ibot_db/include/ibot_db_table_names.hrl").

%% @doc Создание директории проекта и необходимых файлов
%% для начала работы
%% @spec create_project(Path, Folder) -> ok | {error, Reason} when
%% Path :: string(), Folder :: string(), Reason :: term().
%% @end

-spec create_project(Path, Folder) -> ok | {error, Reason} when
  Path :: string(), Folder :: string(), Reason :: term().

create_project(Path, Folder) ->
  ?DBG_INFO("start project create... ~n", []),
  case filelib:ensure_dir(Path) of
    {error, Reason} -> ?DBG_INFO("Directory ~p not exist ~n",
      [Path]), {error, Reason};
    ok ->
      Full_Project_Path = ?MKDIR_PROJECT_FOLDER(Path, Folder), % Полный путь до проекта
      ?DBG_INFO("full_project_path...================... ~p~n", [Full_Project_Path]),
      ibot_core_func_cmd:run_exec(atom_to_list(Full_Project_Path)), % Создаем директорию проекта

      Dev_Folder = ?MKDIR_PROJECT_SUB_FOLDER(Path, Folder, ibot_core_env:env_dev_folder()), % Пут до директории с откомпилированными библиотеками проекта файлами проекта
      ?DBG_INFO("dev_folder ~p~n", [Dev_Folder]),
      ibot_core_func_cmd:run_exec(atom_to_list(Dev_Folder)), % Создаем директорию для откопированных / сгенерированных файлов проекта

      Dev_Folder_SubDirs = ?DEV_FOLDER_LIST(Path, Folder, ibot_core_env:env_dev_folder()), %% Dev folder subdirectories
      create_folder_comand(Dev_Folder_SubDirs), %% Create Dev folder subdirectories

      Src_Folder = ?MKDIR_PROJECT_SUB_FOLDER(Path, Folder, ibot_core_env:env_src_folder()), % Пут до директории с исходными файлами проекта
      ?DBG_INFO("src_folder ~p~n", [Src_Folder]),
      ibot_core_func_cmd:run_exec(atom_to_list(Src_Folder)), % Создаем директорию исходных файлов проекта
      ?DBG_INFO("project directories created successfull...================... ~n", []),



      ok
  end.




%% @doc
%% Create node directories
%% @spec create_folder_comand([F | List]) -> ok when F :: string(), List :: list().
%% @end

-spec create_folder_comand([F | List]) -> ok when F :: atom(), List :: list().

create_folder_comand([]) ->
  ok;
create_folder_comand([F | List]) ->
  ibot_core_func_cmd:exec(F), % Execute create folder command
  create_folder_comand(List), % Create next node folder
  ok.



%% @doc
%% Create prokect node
%% @spec create_node(NodeName, Lang) -> ok | {error, atom()} when NodeName :: string(), Lang :: atom().
%% @end

-spec create_node(NodeName, Lang) -> ok | {error, atom()} when NodeName :: string(), Lang :: atom().

create_node(NodeName, Lang) ->
  ?DBG_INFO("func create_node node, NodeName parameter: ~p ...........~n", [NodeName]),
  case Lang of
    java ->
      ?DBG_INFO("func create_node node, run func create_java_node(~p): ...........~n", [NodeName]),
      create_java_node(NodeName), % Create java type node folders stucture
      ok;
    _ -> {error, ?WRONG_NODE_LANG_TYPE, Lang} % Wrong node lang type error
  end.


%% ============================
%% Create nodes methods for different nodes
%% ============================

%% @doc
%% Create directorise for Java project
create_java_node(NodeName) ->
  ?DBG_INFO("func create_java_node: ...........~n", []),
  case ets:info(ibot_config) of
    undefine -> ?DBG_INFO("cnfig table not exist: ...........~n", []);
    Res -> ?DBG_INFO("config table exist: ~p ...........~n", [Res])
  end,

  case ibot_db_func:get(?TABLE_CONFIG, ?FULL_PROJECT_PATH) of % Try get full path to project folder
    [{?FULL_PROJECT_PATH, Full_Path}] ->
      ?DBG_INFO("full_project_path: ~p...........~n", [Full_Path]),
      case filelib:ensure_dir(Full_Path) of % Ensure that the folder exisit
        ok ->
          NodeFolder = ?JAVA_NODE_FOLDERS(Full_Path, NodeName), % Construct node folder list
          ?DBG_INFO("java_node_folders: ~p...........~n", [NodeFolder]),
          create_folder_comand(NodeFolder), % Create node folders
          ok;
        {error, Reason} -> {error, ?FULL_PATH_PROJECT_NOT_EXISIT, Reason} % If project folder not exeist return error
      end;
    [] -> ?DBG_INFO("full_path_project_undefine: ...........~n", []),
      {error, ?FULL_PATH_PROJECT_UNDEFINE} % If project path not exeist in project db config return error
  end.


remove_dir(DirPath) ->
  case filelib:ensure_dir(DirPath) of
    true ->
      file:del_dir(DirPath);
    _ -> ok
  end.


del_dir(Dir) ->
  lists:foreach(fun(D) ->
    ok = file:del_dir(D)
  end, del_all_files([Dir], [])).

del_all_files([], EmptyDirs) ->
  EmptyDirs;
del_all_files([Dir | T], EmptyDirs) ->
  {ok, FilesInDir} = file:list_dir(Dir),
  {Files, Dirs} = lists:foldl(fun(F, {Fs, Ds}) ->
    Path = Dir ++ "/" ++ F,
    case filelib:is_dir(Path) of
      true ->
        {Fs, [Path | Ds]};
      false ->
        {[Path | Fs], Ds}
    end
  end, {[],[]}, FilesInDir),
  lists:foreach(fun(F) ->
    ok = file:delete(F)
  end, Files),
  del_all_files(T ++ Dirs, [Dir | EmptyDirs]).


create_dir(DirPath) ->
  filelib:ensure_dir(DirPath).

move_dir(Source, Destination)->
  %% For Windows
  %%Command = "MOVE \"" ++ Source ++ "\" \"" ++ Destination ++ "\"",
  %% For Unix/Linux
  Command = "mv " ++ Source ++ " " ++ Destination,
  ?DBG_MODULE_INFO("move_dir(Source, Destination)-> ~p~n", [?MODULE, Command]),
  spawn(os,cmd,[Command]).

copy_dir(Source, Destination)->
  %% For Windows
  %%Command = "XCOPY \"" ++ Source ++ "\" \"" ++ Destination ++ "\"",
  %% For Unix/Linux
  %Command = "cp -a " ++ Source ++ " " ++ Destination,
  %?DBG_MODULE_INFO("copy_dir(Source, Destination)-> ~p~n", [?MODULE, Command]),
  %spawn(os,cmd,[Command]).
  case file:list_dir(Source) of
    {ok, FileList} ->
      ?DMI("copy_dir", [FileList]),
      copy_file_from_to_dir(Source, Destination, FileList);
    {error, Reason} -> ok
  end.%%filelib:wildcard(string:join([Source, "*"], ?DELIM_PATH_SYMBOL)),


copy_file_from_to_dir(Source, Destination, []) ->
    ok;
copy_file_from_to_dir(Source, Destination, [FileName | FileList]) ->
  SourceFile = string:join([Source, FileName], ?PATH_DELIMETER_SYMBOL),
  DestinationFile = string:join([Destination, FileName], ?PATH_DELIMETER_SYMBOL),
  ?DMI("copy_file_from_to_dir -> source | destination", [SourceFile, DestinationFile]),
  file:copy(SourceFile, DestinationFile),
  copy_file_from_to_dir(Source, Destination, FileList).