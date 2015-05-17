%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. Mar 2015 2:24 AM
%%%-------------------------------------------------------------------
-record(core_info, {projectPath :: string()}).

-record(project_info, {
  projectName :: string(), projectNameAtom :: atom(),
  mainProject :: boolean(),
  childrenProjects :: list()
}).

-record(project_chldren, {
  childrenName :: string(), childrenNameAtom :: atom()
}).

-record(node_pubsub_info, {nodeMBoxName :: atom(), nodeServerName :: atom()}).
-record(topic_info, {id :: atom(), subscribeNodes = [] :: list()}).
