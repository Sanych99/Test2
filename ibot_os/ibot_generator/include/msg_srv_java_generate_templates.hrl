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

%% Tab
-define(TAB(Number), string:copies("\t", Number)).

%%Tab with text
-define(TAB_STRING(TextList, Number), string:join([?TAB(Number), TextList], "")).

%% Java import block
-define(JAVA_MSG_FILE_HEADER(MsgName), string:join([
  "package dev.msg.java;",
  "",
  "import com.ericsson.otp.erlang.*;",
  "import langlib.java.*;",
  "",
  ?MSG_CLASS_NAME(MsgName),
  "",
  ?TAB_STRING(["private OtpErlangObject[] resultObject;"], 1),
  "", ""
], ?NEW_LINE)).

%% File end
-define(JAVA_MSG_FILE_END, string:join(["}"], ?NEW_LINE)).

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
-define(PRIVATE_OTP_PROPERTY(Type, Name), ?TAB_STRING([string:join(["private", ?OTP_TYPE(Type), string:join([Name, "Otp;"], "")], " ")], 1)).
%% Create properties Java
-define(PRIVATE_LANG_PROPERTY(Type, Name), ?TAB_STRING([string:join(["private", ?LANG_TYPE(Type), string:join([Name, ";"], "")], " ")], 1)).

%% Constructor message class
-define(CONSTRUCTOR_HEADER(Name), string:join([?TAB(1), "public ", Name, "() throws Exception {"], "")).
%% Resutl OTP object initialization
-define(RESULT_OBJ_DEFINE(ObjCount), string:join(["resultObject = new OtpErlangObject[", io_lib:format("~p", [ObjCount]), "];"], "")).
-define(CONSRTUCTOR(Name, ObjCount), string:join([
  ?CONSTRUCTOR_HEADER(Name),
  ?TAB_STRING([?RESULT_OBJ_DEFINE(ObjCount)], 2),
  ?TAB_STRING("this.set_defaultValues();", 2),
  ?TAB_STRING(["}"], 1)
], ?NEW_LINE)).

%% Constructor message class
-define(CONSTRUCTOR_HEADER_WITH_PARAMS(Name, ObjCount),
  string:join(
    [?NEW_LINE,
      ?NEW_LINE,
      ?TAB(1), "public ", Name, "(OtpErlangTuple msg) throws Exception {",
    ?NEW_LINE,
      ?TAB(2), ?RESULT_OBJ_DEFINE(ObjCount),
    ?NEW_LINE,
    ?TAB(2), "this.set_defaultValues();"], "")).
-define(CONSRTUCTOR_WITH_PARAMS_CREATE_PARAMETER(Type, Name, ObjectNum), string:join([
  ?CONSRTUCTOR_WITH_PARAMS_INIT_PARAMETER_STRING(Type, Name, ObjectNum)
], ?NEW_LINE)).

-define(CONSRTUCTOR_WITH_PARAMS_INIT_PARAMETER_STRING(Type, Name, ObjectNum),
  string:join([?NEW_LINE, ?TAB(2), "this.set_", Name, "(((", ?OTP_CONSTRUCTOR_PARAMETER_CAST_TYPE(Type), ")msg.elementAt(", io_lib:format("~p", [ObjectNum]), ")).", ?CONVERT_FROM_OTP_TO_JAVA_METHODS(Type), ");"], "")
).

-define(CONSTRUCTOR_END_WITH_PARAMS(), ?TAB_STRING([?NEW_LINE, ?TAB(1), "}"], 1)).



%% Create OTP message from java types
-define(GET_OTP_TYPE_MSG, string:join([
  "", "",
  ?TAB_STRING(["public OtpErlangTuple get_Msg() throws Exception {"], 1),
  ?TAB_STRING(["return new OtpErlangTuple(this.resultObject);"], 2),
  ?TAB_STRING(["}"], 1)
], ?NEW_LINE)).



%% Generate getter method definition
-define(GETTER_DEFINITION(Type, Name), string:join([
  ?TAB_STRING(["public ", ?LANG_TYPE(Type), " get_", Name, "() {"], 1),
  ?NEW_LINE,
  ?TAB_STRING(["return ", Name, ";"], 2),
  ?NEW_LINE,
  ?TAB_STRING(["}"], 1)
], "")).

%% Generate setter mathod definition
-define(SETTER_DEFINITION(Type, Name, ObjNumber), string:join([
  ?TAB_STRING(["public void set_", Name, "(", ?LANG_TYPE(Type), " ", Name, ")", " {"], 1),
  ?NEW_LINE,
  ?TAB_STRING(["this.", Name, " = ", Name,";"], 2),
  ?NEW_LINE,
  ?TAB_STRING(["this.resultObject[", integer_to_list(ObjNumber), "] = new ", ?OTP_TYPE(Type), "(", Name,")", ";"], 2),
  ?NEW_LINE,
  ?TAB_STRING(["}"], 1)
], "")).

%% Generate getters and setters
-define(GETTER_SETTER_GENERATE(Type, Name, ObjNumber), string:join([
  "", "",
  ?GETTER_DEFINITION(Type, Name),
  "",
  ?SETTER_DEFINITION(Type, Name, ObjNumber),
  ""
], ?NEW_LINE)).


-define(SET_DEFAULT_VALUE_METHOD_START,
  string:join([
    ?NEW_LINE,
    ?NEW_LINE,
    ?TAB_STRING(["private void set_defaultValues() {"], 1),
    ?NEW_LINE
  ], "")
).

-define(SET_DEFAULT_VALUE_METHOD_PARAMETER(Type, Name),
  string:join([
    ?TAB_STRING(["this.set_", Name, "(", io_lib:format(?DEFAULT_VALUE_CAST_TYPE(Type), [?DEFAULT_VALUE(Type)]), ");"], 2) ,
    ?NEW_LINE
  ], "")
).

-define(SET_DEFAULT_VALUE_METHOD_END,
  string:join([
    ?TAB_STRING(["}"], 1)
  ], "")
).

%% @doc
%% Тип параметра для ядра
%% @end
-define(OTP_TYPE(Type),
  case Type of
    "String" -> "OtpErlangString";
    "Long" -> "OtpErlangLong";
    "Int" -> "OtpErlangInt";
    "Double" -> "OtpErlangDouble";
    "Boolean" -> "OtpErlangBoolean";
    _ -> "UNDEFINE"
  end
).

%% @doc
%% Тип параметра при заполнении через конструктор
%% @end
-define(OTP_CONSTRUCTOR_PARAMETER_CAST_TYPE(Type),
  case Type of
    "String" -> "OtpErlangString";
    "Long" -> "OtpErlangLong";
    "Int" -> "OtpErlangLong";
    "Double" -> "OtpErlangDouble";
    "Boolean" -> "OtpErlangAtom";
    _ -> "UNDEFINE"
  end
).

%% @doc
%% Тип параметра для Java
%% @end
-define(LANG_TYPE(Type),
  case Type of
    "String" -> "String";
    "Long" -> "Long";
    "Int" -> "int";
    "Double" -> "double";
    "Boolean" -> "boolean";
    _ -> "UNDEFINE"
  end
).

%% @doc
%% Представить дапаметр при создании через контруктор как...
%% @end
-define(CONVERT_FROM_OTP_TO_JAVA_METHODS(Type),
  case Type of
    "String" -> "stringValue()";
    "Long" -> "longValue()";
    "Int" -> "intValue()";
    "Double" -> "doubleValue()";
    "Boolean" -> "booleanValue()";
    _ -> "UNDEFINE"
  end
).

-define(DEFAULT_VALUE(Type),
  case Type of
    "String" -> " ";
    "Long" -> 0;
    "Int" -> 0;
    "Double" -> 0;
    "Boolean" -> true;
    _ -> "UNDEFINE"
  end
).

-define(DEFAULT_VALUE_CAST_TYPE(Type),
  case Type of
    "String" -> "new String(~p)";
    "Long" -> "new Long(~p)";
    "Int" -> "(int)~p";
    "Double" -> "(double)~p";
    "Boolean" -> "(boolean)~p";
    _ -> "UNDEFINE"
  end
).
