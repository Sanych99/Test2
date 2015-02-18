%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. Февр. 2015 1:50
%%%-------------------------------------------------------------------
-module(ibot_core_env).
-include("env_params.hrl").
-export([env_dev_folder/0, env_dev_folder/1]).
-export([env_src_folder/0, env_src_folder/1]).

%% @doc Директория откомпилированных / сгенерированных файлов проекта
env_dev_folder() ->
  ?DEV_FOLDER.

%% @doc Полный путь до директории с откомпилированными / сгенерированными файлами проекта
env_dev_folder(Path) ->
  Path ++ ?DEV_FOLDER.

%% @doc Путь до исходных файлов проекта
env_src_folder() ->
  ?SRC_FOLDER.

%% @doc Полный путь до исходный файлов проекта
env_src_folder(Path) ->
  Path ++ ?SRC_FOLDER.