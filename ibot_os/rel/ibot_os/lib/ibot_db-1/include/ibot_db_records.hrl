%%%-------------------------------------------------------------------
%%% @author alexProjectConfigRecord
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. Mar 2015 2:24 AM
%%%-------------------------------------------------------------------
-record(core_info, {
  projectPath :: string(),
  connector_node :: string(),
  topic_node :: string(),
  service_node :: string(),
  ui_interaction_node :: string(),
  java_node_otp_erlang_lib_path :: string(),
  java_ibot_lib_jar_path :: string(),
  python_setup_lib_system_path :: string()
}).

-record(project_info, {
  projectName :: string(), projectNameAtom :: atom(),
  mainProject = true :: boolean() | undefined,
  mainProjectInfo :: string(),
  distributedProject = false :: boolean() | undefined,
  projectAutoRun = false :: boolean() | undefined,
  childrenProjects = [] :: list(),
  childrenProjectName = [] :: list(),
  projectState = develop :: atom() | release,
  mainProjectNodeName :: atom()
}).

-record(project_children, {
  childrenName :: string(), childrenNameAtom :: atom(),
  distributed_db_start = false :: boolean()
}).

-record(node_pubsub_info, {nodeMBoxName :: atom(), nodeServerName :: atom()}).
-record(topic_info, {id :: atom(), subscribeNodes = [] :: list()}).
