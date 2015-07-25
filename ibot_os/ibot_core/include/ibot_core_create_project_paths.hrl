%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. Mar 2015 12:29 AM
%%%-------------------------------------------------------------------
-include("env_params.hrl").
-include("ibot_core_reserve_atoms.hrl").
-include("ibot_core_reserve_file_name.hrl").
-include("../../ibot_db/include/ibot_db_reserve_atoms.hrl").
-include("../../ibot_nodes/include/ibot_nodes_registration_info.hrl").
-include("ibot_core_project_statuses.hrl").

%% @doc
%%
%% Create path to node config file
%% @end
-define(PATH_TO_NODE(NodeName, ProjectStatus), case ibot_db_func_config:get_full_project_path() of
                                           ?ACTION_ERROR -> ?ACTION_ERROR;
                                           ?FULL_PROJECT_PATH_NOT_FOUND -> ?FULL_PROJECT_PATH_NOT_FOUND;
                                           ProjectPath ->
                                             case ProjectStatus of
                                               ?DEVELOP ->
                                                 %% path for read node config file on DEVELOP project statues
                                                 string:join([ProjectPath, ?PROJECT_SRC, NodeName, ?NODE_CONFIG_FILE], ?DELIM_PATH_SYMBOL);
                                               ?RELEASE ->
                                                 %% path for read node config file on RELEASE project statues
                                                 string:join([ProjectPath, ?DEV_FOLDER, ?NODES_FOLDER, NodeName, ?NODE_CONFIG_FILE], ?DELIM_PATH_SYMBOL)
                                             end
                                         end).
