%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. Oct 2015 4:03 AM
%%%-------------------------------------------------------------------
-author("alex").


-define(PATH_TO_CREATE_MSG_SRV_JAR,
  case os:type() of
    {unix,linux} ->
      {ok, CurrentDir} = file:get_cwd(),
      string:join([CurrentDir, "lib", "ibot_core-1", "priv", "create_jar.sh"], ?PATH_DELIMETER_SYMBOL);
    _ -> ""
  end
).

-define(PATH_TO_INSTALL_MSG_SRV_PYTHON,
  case os:type() of
    {unix,linux} ->
      {ok, CurrentDirProject} = file:get_cwd(),
      string:join([CurrentDirProject, "lib", "ibot_core-1", "priv", "install_py_msg_srv.sh"], ?PATH_DELIMETER_SYMBOL);
    _ -> ""
  end
).