%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. Февр. 2015 19:20
%%%-------------------------------------------------------------------
-module(ibot_core_cmd_cdir).
-export([create_project/2]).

-include("debug.hrl").
-include("project_create_commands.hrl").

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

      Dev_Folder = ?MKDIR_PROJECT_SUB_FOLDER(Path, Folder, ibot_core_env:env_dev_folder()), % Пут до директории с откомпилированными библиотеками проекта файлами проекта
      ?DBG_INFO("Dev_Folder ~p~n", [Dev_Folder]),
      ibot_core_cmd:exec(atom_to_list(Dev_Folder)), % Создаем директорию для откопированных / сгенерированных файлов проекта

      Src_Folder = ?MKDIR_PROJECT_SUB_FOLDER(Path, Folder, ibot_core_env:env_src_folder()), % Пут до директории с исходными файлами проекта
      ?DBG_INFO("Src_Folder ~p~n", [Src_Folder]),
      ibot_core_cmd:exec(atom_to_list(Src_Folder)), % Создаем директорию исходных файлов проекта
      ?DBG_INFO("Project directories created successfull...================... ~n", []),

      ok
  end.
