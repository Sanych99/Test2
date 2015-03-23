%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015
%%% @doc
%%%
%%% @end
%%% Created : 19. Февр. 2015 19:20
%%%-------------------------------------------------------------------
-module(ibot_core_cmd_cdir).
-export([create_project/2, create_node/2]).

-include("debug.hrl").
-include("project_create_commands.hrl").
-include("result_atoms.hrl").
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
      ibot_core_cmd:run_exec(atom_to_list(Full_Project_Path)), % Создаем директорию проекта

      Dev_Folder = ?MKDIR_PROJECT_SUB_FOLDER(Path, Folder, ibot_core_env:env_dev_folder()), % Пут до директории с откомпилированными библиотеками проекта файлами проекта
      ?DBG_INFO("dev_folder ~p~n", [Dev_Folder]),
      ibot_core_cmd:run_exec(atom_to_list(Dev_Folder)), % Создаем директорию для откопированных / сгенерированных файлов проекта

      Dev_Folder_SubDirs = ?DEV_FOLDER_LIST(Path, Folder, ibot_core_env:env_dev_folder()), %% Dev folder subdirectories
      create_folder_comand(Dev_Folder_SubDirs), %% Create Dev folder subdirectories

      Src_Folder = ?MKDIR_PROJECT_SUB_FOLDER(Path, Folder, ibot_core_env:env_src_folder()), % Пут до директории с исходными файлами проекта
      ?DBG_INFO("src_folder ~p~n", [Src_Folder]),
      ibot_core_cmd:run_exec(atom_to_list(Src_Folder)), % Создаем директорию исходных файлов проекта
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
  ibot_core_cmd:exec(F), % Execute create folder command
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