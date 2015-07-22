%%%-------------------------------------------------------------------
%%% @author alexProjectConfigRecord
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. Mar 2015 2:24 AM
%%%-------------------------------------------------------------------
-record(core_info, {projectPath :: string()}).

-record(project_info, {
  projectName :: string(), projectNameAtom :: atom(),
  mainProject = true :: boolean() | undefined,
  mainProjectInfo :: string(),
  distributedProject = false :: boolean() | undefined,
  projectAutoRun = false :: boolean() | undefined,
  childrenProjects = [] :: list(),
  childrenProjectName = [] :: list(),
  projectState = in_work :: atom() | release
}).

-record(project_children, {
  childrenName :: string(), childrenNameAtom :: atom(),
  distributed_db_start = false :: boolean()
}).

-record(node_pubsub_info, {nodeMBoxName :: atom(), nodeServerName :: atom()}).
-record(topic_info, {id :: atom(), subscribeNodes = [] :: list()}).
