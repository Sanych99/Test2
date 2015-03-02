%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. Mar 2015 2:09 AM
%%%-------------------------------------------------------------------

%% New line char
-define(NEW_LINE, "\n").

%% Java import block
-define(JAVA_MSG_FILE_HEADER(MsgName), string:join([
  "import com.ericsson.otp.erlang.*;",
  "",
  ?MSG_CLASS_NAME(MsgName),
  "",
  "private OtpErlangObject[] resultObject;",
  "", ""
], ?NEW_LINE)).

%% File end
-define(JAVA_MSG_FILE_END, string:join(["","}"], ?NEW_LINE)).

%% Message class name
-define(MSG_CLASS_NAME(MsgName), string:join(["public class ", MsgName, " implements IBotMsgInterface {"], "")).

%% Generate OTP and Java properties
-define(PRIVATE_PROPERTIES_OTP_LANG(Type, Name),
  string:join([
    ?PRIVATE_OTP_PROPERTY(Type, Name),
    ?PRIVATE_LANG_PROPERTY(Type, Name),
    "", ""
  ], ?NEW_LINE)
).

%% Crate properties OTP
-define(PRIVATE_OTP_PROPERTY(Type, Name), string:join(["private", ?OTP_TYPE(Type), string:join([Name, ";"], "")], " ")).
%% Create properties Java
-define(PRIVATE_LANG_PROPERTY(Type, Name), string:join(["private", ?LANG_TYPE(Type), string:join([Name, ";"], "")], " ")).

%% Constructor message class
-define(CONSTRUCTOR_HEADER(Name), string:join(["public ", Name, "() throws Exception {"], "")).
%% Resutl OTP object initialization
-define(RESULT_OBJ_DEFINE(ObjCount), string:join(["resultObject = new OtpErlangObject[", io_lib:format("~p", [ObjCount]), "];"], "")).
-define(CONSRTUCTOR(Name, ObjCount), string:join([
  ?CONSTRUCTOR_HEADER(Name),
  "",
  ?RESULT_OBJ_DEFINE(ObjCount),
  "",
  "}"
], ?NEW_LINE)).


%% Get OPT type
-define(OTP_TYPE(Type),
  case Type of
    "String" -> "OtpErlangString";
    "BigInt" -> "OtpErlangLong";
    _ -> "UNDEFINE"
  end
).

%% Get Java type
-define(LANG_TYPE(Type),
  case Type of
    "String" -> "String";
    "BigInt" -> "BigInteger";
    _ -> "UNDEFINE"
  end
).
