%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015
%%% @doc
%%% Определения для работы с информацией об узлах
%%% @end
%%% Created : 22. Февр. 2015 18:34
%%%-------------------------------------------------------------------

%% @doc Атом для запроса информации об узле
-define(GET_NODE_INFO, get_node_info).
%% @doc Атом ответа на запрос для получения информации об узле
-define(RESPONSE, response).
%% @doc Атом указывающий на то, что информация об узле отсутсвует
-define(NO_NODE_INFO, no_node_info).

%% @doc
%% needMonitor - необходимость подключения монитора
%% restartNumber - максимальное количество рестартов для узла
%% currentRestartNumber - текущее чилсо рестартов узла
-record(node_monitor_settings, {needMonitor :: boolean(), restartNumber :: integer(), currentRestartNumber :: integer()}).

%% @doc
%% nodeName - Наименование узла
%% nodeSystemMailBox - Системный почтовый ящик узла
%% nodeServer - Имя сервера на котором запущен узел
%% nodeNameServer - Соедененное значения имени узла и сервера
%% nodeLang - Язык программирования на котором написан узел
%% nodeExecutable - исполняемы файл для запуска узла (java, python, gcc)
-record(node_info, {
  atomNodeName :: atom(), nodeName :: string(),
  nodeSystemMailBox :: string(), atomNodeSystemMailBox :: atom(),
  nodeServer :: string(), atomNodeServer :: atom(),
  nodeNameServer :: string(), atomNodeNameServer :: atom(),
  nodeLang :: string(), atomNodeLang :: atom(),
  nodeExecutable :: string(),
  nodePreArguments :: list(),
  nodePostArguments :: list(),
  monitorSettings :: #node_monitor_settings{},
  messageFile :: list(),
  serviceFile :: list(),
  projectType = native :: native | maven,
  mainClassName :: string()
}).
