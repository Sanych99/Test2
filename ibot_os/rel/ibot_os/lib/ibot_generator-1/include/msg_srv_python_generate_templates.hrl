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
-define(PYTHON_MSG_FILE_HEADER(MsgName), string:join([
  "from py_interface import erl_term",
  "",
  ?MSG_CLASS_NAME(MsgName),
  "", ""
], ?NEW_LINE)).

%% File end
-define(JAVA_MSG_FILE_END, string:join(["}"], ?NEW_LINE)).

%% Message class name
-define(MSG_CLASS_NAME(MsgName), string:join(["class ", MsgName, "():"], "")).

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
-define(CONSTRUCTOR_HEADER(Name), string:join([?TAB(1), "def __init__(self):"], "")).
%% Resutl OTP object initialization
-define(RESULT_OBJ_DEFINE(ObjCount), "self.resultObject = []").
-define(CONSRTUCTOR(Name, ObjCount), string:join([
  ?CONSTRUCTOR_HEADER(Name),
  ?TAB_STRING([?RESULT_OBJ_DEFINE(ObjCount)], 2)
  %?TAB_STRING(["}"], 1)
], ?NEW_LINE)).

%% Constructor message class
-define(CONSTRUCTOR_HEADER_WITH_PARAMS(Name), string:join([?NEW_LINE, ?NEW_LINE, ?TAB(1), "def __init__(self, msg):"], "")).
-define(CONSRTUCTOR_WITH_PARAMS_CREATE_PARAMETER(Type, Name, ObjectNum), string:join([
  ?CONSRTUCTOR_WITH_PARAMS_INIT_PARAMETER_STRING(Type, Name, ObjectNum)
], ?NEW_LINE)).

-define(CONSRTUCTOR_WITH_PARAMS_INIT_PARAMETER_STRING(Type, Name, ObjectNum),
  string:join([?NEW_LINE, ?TAB(2), "self.", Name, " = ", ?CONVERT_FROM_OTP_TO_PYTHON_METHODS(Type), "(msg[", io_lib:format("~p", [ObjectNum]), "])", ""], "")
).

-define(CONSTRUCTOR_END_WITH_PARAMS(), ?TAB_STRING([?NEW_LINE, ?TAB(1), "}"], 1)).



%% Create OTP message from java types
-define(GET_OTP_TYPE_MSG, string:join([
  "", "",
  ?TAB_STRING(["def getMsg(self):"], 1),
  ?TAB_STRING(["return erl_term.ErlTuple(self.resultObject);"], 2)
  %?TAB_STRING(["}"], 1)
], ?NEW_LINE)).



%% Generate getter method definition
-define(GETTER_DEFINITION(Type, Name), string:join([
  ?TAB_STRING(["@property"], 1),
  ?NEW_LINE,
  ?TAB_STRING(["def ", Name, "(self): return self._", Name], 1),
  ?NEW_LINE
], "")).

%% Generate setter mathod definition
-define(SETTER_DEFINITION(Type, Name, ObjNumber), string:join([
  ?TAB_STRING(["@", Name, ".setter"], 1),
  ?NEW_LINE,
  ?TAB_STRING(["def ", Name, "(self, val):"], 1),
  ?NEW_LINE,
  ?TAB_STRING(["self._", Name, " = val"], 2),
  ?NEW_LINE,
  ?TAB_STRING(["self.resultObject[", integer_to_list(ObjNumber), "] = " , ?OTP_TYPE(Type), "(val)"], 2),
  ?NEW_LINE
], "")).

%% Generate getters and setters
-define(GETTER_SETTER_GENERATE(Type, Name, ObjNumber), string:join([
  "", "",
  ?GETTER_DEFINITION(Type, Name),
  "",
  ?SETTER_DEFINITION(Type, Name, ObjNumber),
  ""
], ?NEW_LINE)).


%% Get OPT type
-define(OTP_TYPE(Type),
  case Type of
    "String" -> "erl_term.ErlString";
    "BigInt" -> "erl_term.ErlInt";
    _ -> "UNDEFINE"
  end
).

%% Get Java type
-define(LANG_TYPE(Type),
  case Type of
    "String" -> "String";
    "BigInt" -> "Integer";
    _ -> "UNDEFINE"
  end
).

-define(CONVERT_FROM_OTP_TO_PYTHON_METHODS(Type),
  case Type of
    "String" -> "str";
    "BigInt" -> "int";
    _ -> "UNDEFINE"
  end
).
