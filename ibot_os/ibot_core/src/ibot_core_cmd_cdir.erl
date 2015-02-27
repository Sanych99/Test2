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
-include("config_db_keys.hrl").
-include("result_atoms.hrl").

%% @doc Создание директории проекта и необходимых файлов
%% для начала работы

-spec create_project(Path, Folder) -> ok | {error, Reason} when
  Path :: string(), Folder :: string(), Reason :: term().

create_project(Path, Folder) ->
  ?DBG_INFO("Start project create... ~n", []),
  case filelib:ensure_dir(Path) of
    {error, Reason} -> ?DBG_INFO("Directory ~p not exist ~n",
      [Path]), {error, Reason};
    ok ->
      Full_Project_Path = ?MKDIR_PROJECT_FOLDER(Path, Folder), % Полный путь до проекта
      ?DBG_INFO("Full_Project_Path...================... ~p~n", [Full_Project_Path]),
      ibot_core_cmd:exec(atom_to_list(Full_Project_Path)), % Создаем директорию проекта

      ibot_core_config_db:add(?FULL_PROJECT_PATH, Full_Project_Path),

      Dev_Folder = ?MKDIR_PROJECT_SUB_FOLDER(Path, Folder, ibot_core_env:env_dev_folder()), % Пут до директории с откомпилированными библиотеками проекта файлами проекта
      ?DBG_INFO("Dev_Folder ~p~n", [Dev_Folder]),
      ibot_core_cmd:exec(atom_to_list(Dev_Folder)), % Создаем директорию для откопированных / сгенерированных файлов проекта

      ibot_core_config_db:add(?DEV_PROJECT_PATH, Dev_Folder),

      Src_Folder = ?MKDIR_PROJECT_SUB_FOLDER(Path, Folder, ibot_core_env:env_src_folder()), % Пут до директории с исходными файлами проекта
      ?DBG_INFO("Src_Folder ~p~n", [Src_Folder]),
      ibot_core_cmd:exec(atom_to_list(Src_Folder)), % Создаем директорию исходных файлов проекта
      ?DBG_INFO("Project directories created successfull...================... ~n", []),

      ibot_core_config_db:add(?SRC_PROJECT_PATH, Src_Folder),

      ok
  end.


crate_folder_comand([F | List]) ->
  ibot_core_cmd:exec(F), % Execute create folder command
  crate_folder_comand(List), % Create next node folder
  ok.


%% @doc
%% Create prokect node
%% @spec create_node(NodeName, Lang) -> ok | {error, atom()} when NodeName :: string(), Lang :: atom().
%% @end
-spec create_node(NodeName, Lang) -> ok | {error, atom()} when NodeName :: string(), Lang :: atom().
create_node(NodeName, Lang) ->
  case Lang of
    java -> create_java_node(NodeName), % Create java type node folders stucture
      ok;
    _ -> {error, ?WRONG_NODE_LANG_TYPE, Lang} % Wrong node lang type error
  end,
  ok.


%% ============================
%% Create nodes methods for different nodes
%% ============================

%% @doc
%% Create directorise for Java project
create_java_node(NodeName) ->
  case ibot_core_config_db:get(?FULL_PROJECT_PATH) of % Try get full path to project folder
    {?FULL_PROJECT_PATH, Full_Path} ->
      case filelib:ensure_dir(Full_Path) of % Ensure that the folder exisit
        ok ->
          NodeFolder = ?MKDIR_PROJECT_NODE_FOLDER(Full_Path, NodeName), % Construct node folder list
          create_node(NodeFolder), % Create node folders
          ok;
        {error, Reason} -> {error, ?FULL_PATH_PROJECT_NOT_EXISIT, Reason} % If project folder not exeist return error
      end;
    [] -> {error, ?FULL_PATH_PROJECT_UNDEFINE} % If project path not exeist in project db config return error
  end.