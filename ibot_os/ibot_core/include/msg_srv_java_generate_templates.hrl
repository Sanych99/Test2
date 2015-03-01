%%%-------------------------------------------------------------------
%%% @author alex
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. Mar 2015 2:09 AM
%%%-------------------------------------------------------------------
-define(NEW_LINE, "\n").
-define(JAVA_MSG_FILE_HEADER(MsgName), string:join([
  "import com.ericsson.otp.erlang.*;",
  "",
  ?MSG_CLASS_NAME(MsgName),
  "",
  "private OtpErlangObject[] resultObject;",
  "", ""
], ?NEW_LINE)).

-define(JAVA_MSG_FILE_END, string:join(["","}"], ?NEW_LINE)).

-define(MSG_CLASS_NAME(MsgName), string:join(["public class ", MsgName, " implements IBotMsgInterface {"], "")).


-define(PRIVATE_PROPERTIES_OTP_LANG(Type, Name),
  string:join([
    ?PRIVATE_OTP_PROPERTY(Type, Name),
    ?PRIVATE_LANG_PROPERTY(Type, Name),
    "", ""
  ], ?NEW_LINE)

  %[{NextType, NextName} | NextTypeNameTupleList] = TypeNameTupleList,
  %case TypeNameTupleList of
  %  [{NextType, NextName} | NextTypeNameTupleList] -> string:join([
  %    ?PRIVATE_OTP_PROPERTY(NextType, NextName),
  %    ?PRIVATE_LANG_PROPERTY(NextType, NextName)
  %  ], ?NEW_LINE);
  %  _ -> ""
  %end
).

-define(PRIVATE_OTP_PROPERTY(Type, Name), string:join(["private", ?OTP_TYPE(Type), Name], " ")).
-define(PRIVATE_LANG_PROPERTY(Type, Name), string:join(["private", ?LANG_TYPE(Type), Name], " ")).

-define(OTP_TYPE(Type),
  case Type of
    "String" -> "OtpErlangString";
    "BigInt" -> "OtpErlangLong";
    _ -> "UNDEFINE"
  end
).
-define(LANG_TYPE(Type),
  case Type of
    "String" -> "String";
    "BigInt" -> "BigInteger";
    _ -> "UNDEFINE"
  end
).
