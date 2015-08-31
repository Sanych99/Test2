%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. Mar 2015 1:42 AM
%%%-------------------------------------------------------------------
-define(JAVA_COMPILE_SRV_SOURCES,
  list_to_atom("javac -classpath \"/usr/lib/erlang/lib/jinterface-1.5.12/priv/OtpErlang.jar:/home/alex/iBotOS/iBotOS/JLib/lib/Node.jar\" /home/alex/iBotOS/iBotOS/tp/tp/dev/srv/java/*.java")).

-define(JAVA_COMPILE_MSG_SOURCES,
  list_to_atom("javac -classpath \"/usr/lib/erlang/lib/jinterface-1.5.12/priv/OtpErlang.jar:/home/alex/iBotOS/iBotOS/JLib/lib/Node.jar\" /home/alex/iBotOS/iBotOS/tp/tp/dev/msg/java/*.java")).

-define(JAVA_MSG_SRV_CREATE_JAR,
  list_to_atom("")).
