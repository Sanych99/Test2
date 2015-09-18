%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright iBot Robotics
%%% @doc
%%% Методы управления данными конфигураций
%%% @end
%%% Created : 25. Mar 2015 8:14 PM
%%%-------------------------------------------------------------------
-module(ibot_db_func_config).

-include("../../ibot_core/include/debug.hrl").
-include("ibot_db_reserve_atoms.hrl").
-include("ibot_db_table_names.hrl").
-include("ibot_db_project_config_param.hrl").
-include("../../ibot_core/include/ibot_core_reserve_atoms.hrl").
-include("../../ibot_nodes/include/ibot_nodes_registration_info.hrl").
-include("ibot_db_modules.hrl").
-include("ibot_db_table_commands.hrl").
-include("ibot_db_records.hrl").

%% API
-export([
  get_full_project_path/0, %% получить полный путь до проекта
  set_full_project_path/1, %% добавить полный пусть до проекта
  set_node_info/1, %% добавить информацию о узле
  get_node_info/1, %% получить информацию о узле
  get_all_registered_nodes/0 %% все зарегистрированные узлы в строковом формате
]).
-export([
  add_node_name_to_config/1, %% добавить имя узла в конфиг
  get_nodes_name_from_config/0 %% получить писок имен узлов из конфига
]).
-export([
  add_core_config_info/1, %% добавить конфиг информацию о ядре
  get_core_config_info/0  %% получить конфиг информацию о ядре
]).
-export([
  generate_nodes_info_to_list/2 %% информация о зарегистрированных узлах с строковом формате
]).


%%% ====== full project path mathods start ======

%% @doc
%% Выбор полного пути до проекта / Get project path from config db
%% @spec get_full_project_path() -> [{?FULL_PROJECT_PATH, string()}] | ?FULL_PROJECT_PATH_NOT_FOUND | ?ACTION_ERROR.
%% @end
-spec get_full_project_path() -> [{?FULL_PROJECT_PATH, string()}] | ?FULL_PROJECT_PATH_NOT_FOUND | ?ACTION_ERROR.

get_full_project_path() ->
  case gen_server:call(?IBOT_DB_SRV, {?GET_RECORD, ?TABLE_CONFIG, ?FULL_PROJECT_PATH}) of
    {ok, Full_Project_Path} ->
      ?DMI("get_full_project_path", Full_Project_Path),
      Full_Project_Path; %% передаем полный путь
    [] -> ?FULL_PROJECT_PATH_NOT_FOUND %% полный путь не найден
  end.


%% @doc
%% Сохраняем полный путь до проекта / Set project path from config db
%% @spec set_full_project_path(ProjectPath) -> ok when ProjectPath :: string().
%% @end
-spec set_full_project_path(ProjectPath) -> ok when ProjectPath :: string().

set_full_project_path(ProjectPath) ->
  ?DMI("set_full_project_path", ProjectPath),
  gen_server:call(?IBOT_DB_SRV, {?ADD_RECORD, ?TABLE_CONFIG, ?FULL_PROJECT_PATH, ProjectPath}),
  ok.

%%% ====== full project path mathods end ======


%% @doc
%% Добавить имя узла в конфиг / Add node name to config
%% @end
add_node_name_to_config(NodeName) ->
  case gen_server:call(?IBOT_DB_SRV, {?GET_RECORD, ?TABLE_CONFIG, ?PROJECT_NODES_LIST}) of
    {ok, ConfigNodeNamesList} ->
      %% если запись в бд существует дополняем списко
      gen_server:call(?IBOT_DB_SRV, {?ADD_RECORD, ?TABLE_CONFIG, ?PROJECT_NODES_LIST, lists:append(ConfigNodeNamesList, [NodeName])});

    Vals ->
      ?DMI("add_node_name_to_config", Vals),
      %% если запись отсутствует, добавляем новую
      gen_server:call(?IBOT_DB_SRV, {?ADD_RECORD, ?TABLE_CONFIG, ?PROJECT_NODES_LIST, [NodeName]})
  end,
  ok.

%% @doc
%% Выбор списка узлов проекта
%% @end
get_nodes_name_from_config() ->
  case ibot_db_srv:get_record(?TABLE_CONFIG, ?PROJECT_NODES_LIST) of
    {ok, NodesNameList} ->
      ?DMI("get_node_name_from_config", NodesNameList),
      NodesNameList;
    _ ->
      ?DMI("get_node_name_from_config", error),
      error
  end.



%% @doc
%% Добавить информацию об узле проекта / Add project node information
%% @end
set_node_info(NodeInfoRecord) ->
  ?DMI("set_node_info", NodeInfoRecord),
  ibot_db_func:add_to_mnesia(NodeInfoRecord),
  ok.


%% @doc
%% Добавить информацию об узле проекта / Add project node information
%% @end
get_node_info(AtomNodeName) ->
  NodeInfo = ibot_db_func:get_from_mnesia(node_info, AtomNodeName),
  ?DMI("get_node_info", NodeInfo),
  NodeInfo.


%% @doc
%% Все зарегестрированные узлы проекта в формате строки / All registered nodes as string
%% @end
get_all_registered_nodes() ->
  case ibot_db_func_config:get_nodes_name_from_config() of
    error -> [];
    NodeNameList ->
      ibot_db_func_config:generate_nodes_info_to_list(NodeNameList, "")
  end.

%% @doc
%% Создание строки с наименованиями узлов / Create node names string
%% @end
generate_nodes_info_to_list([], NodeInfoList) ->
  NodeInfoList;
generate_nodes_info_to_list([NodeName | NodeNameList], NodeInfoList) ->
  case ibot_db_func_config:get_node_info(list_to_atom(NodeName)) of
    not_found -> NewNodeInfoList = NodeInfoList;
    Item ->
      NewNodeInfoList = string:join([NodeInfoList,
        string:join([Item#node_info.nodeName, Item#node_info.nodeLang], "#")], "&")
  end,
  generate_nodes_info_to_list(NodeNameList, NewNodeInfoList).



%% ====== Core Config Information Start ======

%% @doc
%% Добавить конфигурационную информацию ядра / Add core configuration info
%% @end
add_core_config_info(CoreConfigInfo) ->
  ?DMI("add_core_config_info", CoreConfigInfo),
  ibot_db_srv:add_record(?TABLE_CONFIG, core_info, CoreConfigInfo),
  ok.

%% @doc
%% Выбрать конфигурационную информацию ядра / Get core configuration info
%% @end
get_core_config_info() ->
  case ibot_db_srv:get_record(?TABLE_CONFIG, core_info) of
    record_not_found ->
      ?DMI("get_core_config_info", record_not_found),
      []; %% запись не найдена
    {ok, CoreConfigInfo} ->
      ?DMI("get_core_config_info", CoreConfigInfo),
      CoreConfigInfo %% конфигурационная информация ядра
  end.

%% ====== Core Config Information End ======