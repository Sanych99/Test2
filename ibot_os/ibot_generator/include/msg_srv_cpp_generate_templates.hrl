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
-define(CPP_MSG_FILE_HEADER(MsgName), string:join([
  "#include \"IBotMsgInterface.h\"",
  "",
  ?MSG_CLASS_NAME(MsgName)
  %, "", ""
], ?NEW_LINE)).

%% File end
%-define(JAVA_MSG_FILE_END, string:join(["}"], ?NEW_LINE)).

%% Message class name
-define(MSG_CLASS_NAME(MsgName),
  string:join(["class ", MsgName, ": public IBotMsgInterface {",
  ?NEW_LINE,
  "public:",
  ?NEW_LINE], "")).

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
-define(CONSTRUCTOR_HEADER(Name), string:join([?TAB(1), Name, "() {"], "")).
%% Resutl OTP object initialization
%-define(RESULT_OBJ_DEFINE(ObjCount), string:join(["self.resultObject = [None] * ", io_lib:format("~p", [ObjCount])], "")).
-define(CONSRTUCTOR(Name, ObjCount),
  string:join(["", "",
    ?CONSTRUCTOR_HEADER(Name),
    ?TAB_STRING(["set_default_values();"], 2),
    ?TAB_STRING(["}"], 1)], ?NEW_LINE)).

%% Constructor message class
-define(CONSTRUCTOR_HEADER_WITH_PARAMS(Name, ObjCount, ResultString), string:join([
  ?NEW_LINE,
  ?NEW_LINE,
  ?TAB(1), Name, "(matchable_ptr message_elements) {",
  ?NEW_LINE,
  ?TAB(2), ResultString,
  ?NEW_LINE,
  ?TAB(1), "}"], "")).
-define(CONSRTUCTOR_WITH_PARAMS_CREATE_PARAMETER(Type, Name, ObjectNum), string:join([
  ?CONSRTUCTOR_WITH_PARAMS_INIT_PARAMETER_STRING(Type, Name, ObjectNum)
], ?NEW_LINE)).


-define(CONSTRUCTOR_MATCHABLE(Type, Name, ResultString), string:join([ResultString, ?OTP_TYPE(Type), "(&", Name, ")"], "")).

-define(COMMA_DELIMETER(ResultString), string:join([ResultString, ", "], "")).

-define(CONSTRUCTOR_MATCHABLE_FINAL(ResultString),
  string:join(["message_elements->match(make_e_tuple(", ResultString, "));"], "")).

%-define(CONSTRUCTOR_START_MSG_PARSE, string:join([?NEW_LINE, ?NEW_LINE, ?TAB(2), "if (msg is not None):"], "")).

-define(CREATE_DEFAULT_PARAMETER_VALUE(Type, Name),
  string:join([?NEW_LINE, ?TAB(2), ?LANG_TYPE(Type), " ", Name, ";", ""], "")
).

-define(CONSRTUCTOR_WITH_PARAMS_INIT_PARAMETER_STRING(Type, Name, ObjectNum),
  string:join([?NEW_LINE, ?TAB(1), ?LANG_TYPE(Type), " ", Name, ";", ""], "")
).


-define(SEND_MESSAGE_TUPLE(Type, Name, ResultString), string:join([ResultString, ?OTP_TYPE(Type), "(", Name, ")"], "")).

-define(SEND_MESSAGE_FUNCTION(SendMessageTuple),
  string:join([
    ?NEW_LINE, ?NEW_LINE, ?TAB(1),
    "virtual void send_mesasge(mailbox_ptr mbox, std::string publisherCoreNode, std::string coreNodeName, ",
    ?NEW_LINE, ?TAB(2),
    "std::string currentNode, std::string otpMboxNameAsync, std::string topicName) const {",
    ?NEW_LINE, ?TAB(2),
    "mbox->send(publisherCoreNode, coreNodeName, ",
    ?NEW_LINE, ?TAB(2),
    "make_e_tuple(atom(\"broadcast\"), atom(otpMboxNameAsync), ",
    ?NEW_LINE, ?TAB(2),
    "atom(currentNode), atom(topicName), make_e_tuple(", SendMessageTuple, ")",
    ?NEW_LINE, ?TAB(1),
    "));",
    ?NEW_LINE, ?TAB(1),
    "}"], "")).


-define(SEND_MESSAGE_FOR_SERVICE_FUNCTION,
  string:join([
    ?NEW_LINE, ?NEW_LINE, ?TAB(1),
    "virtual void send_mesasge(mailbox_ptr mbox, std::string publisherCoreNode, std::string coreNodeName, ",
    ?NEW_LINE, ?TAB(2),
    "std::string currentNode, std::string otpMboxNameAsync, std::string topicName) const {",
    ?NEW_LINE, ?TAB(2),
    "std::cout<<\"no action\"<<\"\\n\\r\";",
    ?NEW_LINE, ?TAB(1),
    "}"], "")).


-define(SEND_SERVICE_RESPONSE_FOR_MESSAGES_FUNCTION,
  string:join([
    ?NEW_LINE, ?NEW_LINE, ?TAB(1),
    "virtual void send_service_response(mailbox_ptr mbox, std::string service_core_node,",
    ?NEW_LINE, ?TAB(2),
    "std::string core_node_name, std::string response_service_message, std::string service_method_name, ",
    ?NEW_LINE, ?TAB(2),
    "std::string client_mail_box_name, std::string client_node_full_name, std::string client_method_name_callback, matchable_ptr request_message_from_client) const {",
    ?NEW_LINE, ?TAB(2),
    "std::cout<<\"no action\"<<\"\\n\\r\";",
    ?NEW_LINE, ?TAB(1),
    "}"
  ], "")
).



-define(SEND_SERVICE_RESPONSE_FOR_RESP_FUNCTION(Name, ResultString),
  string:join([
    ?NEW_LINE, ?NEW_LINE, ?TAB(1),
    "virtual void send_service_response(mailbox_ptr mbox, std::string service_core_node, ",
    ?NEW_LINE, ?TAB(2),
    "std::string core_node_name, std::string response_service_message, std::string service_method_name, ",
    ?NEW_LINE, ?TAB(2),
    "std::string client_mail_box_name, std::string client_node_full_name, std::string client_method_name_callback, matchable_ptr request_message_from_client) const {",
    ?NEW_LINE, ?TAB(2),
    string:join([re:replace(Name, "Resp", "", [{return, list}]), "Req req(request_message_from_client);"], ""),
    ?NEW_LINE, ?TAB(2),
    "mbox->send(service_core_node, core_node_name, make_e_tuple(atom(response_service_message), e_string(service_method_name), atom(client_mail_box_name),",
    ?NEW_LINE, ?TAB(3),
    "atom(client_node_full_name), e_string(client_method_name_callback), req.get_tuple_message() ,",
    ?NEW_LINE, ?TAB(3),
    "make_e_tuple(", ResultString, ")",
    ?NEW_LINE, ?TAB(2),
    "));",
    ?NEW_LINE, ?TAB(1),
    "}"
  ], "")
).


-define(GET_TUPLE_MESSAGE_TYPE(Type, Name, ResultString), string:join([ResultString, ?OTP_TYPE(Type)], "")).

-define(GET_TUPLE_MESSAGE(TupleTypesList, ReturnList),
  string:join([
    ?NEW_LINE, ?NEW_LINE, ?TAB(1),
    "e_tuple<boost::fusion::tuple<", TupleTypesList,"> > get_tuple_message() {",
    ?NEW_LINE, ?TAB(2),
    "return make_e_tuple(", ReturnList,");",
    ?NEW_LINE, ?TAB(1),
    "};"
  ], "")
).


-define(SET_DEFALUT_PARAMETER(ResultString, Name, Type),
  string:join([
    ResultString,
    ?NEW_LINE, ?TAB(2),
    Name, " = ", ?DEFAULT_VALUE(Type), ";"
  ], "")
).

-define(SET_DEFAULT_VALUES_FUNCTION(ParameterList),
  string:join([
    ?NEW_LINE, ?NEW_LINE, ?TAB(1),
    "void set_default_values() {",
    ParameterList,
    ?NEW_LINE, ?TAB(1),
    "}"
  ], "")
).

%-define(CONSTRUCTOR_END_WITH_PARAMS(), ?TAB_STRING([?NEW_LINE, ?TAB(1), "}"], 1)).



%% Create OTP message from java types
-define(GET_OTP_TYPE_MSG, string:join([
  "", "",
  ?TAB_STRING(["def getMsg(self):"], 1),
  ?TAB_STRING(["return erl_term.ErlTuple(self.resultObject)"], 2)
  %?TAB_STRING(["}"], 1)
], ?NEW_LINE)).



%% Generate getter method definition
-define(GETTER_DEFINITION(Type, Name), string:join([
  %?TAB_STRING(["@property"], 1),
  %?NEW_LINE,
  ?TAB_STRING(["def get_", Name, "(self): return self._", Name], 1),
  ?NEW_LINE
], "")).

%% Generate setter mathod definition
-define(SETTER_DEFINITION(Type, Name, ObjNumber), string:join([
  %?TAB_STRING(["@", Name, ".setter"], 1),
  %?NEW_LINE,
  ?TAB_STRING(["def set_", Name, "(self, val):"], 1),
  ?NEW_LINE,
  ?TAB_STRING(["self._", Name, " = val"], 2),
  ?NEW_LINE,
  ?TAB_STRING(["self.resultObject[", integer_to_list(ObjNumber), "] = " , io_lib:format(?OTP_TYPE(Type), [val])], 2),
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
    "String" -> "e_string";
    "Long" -> "long";
    "Int" -> "int_";
    "Double" -> "float_";
    "Boolean" -> "bool";
    _ -> "UNDEFINE"
  end
).

%% Get Java type
-define(LANG_TYPE(Type),
  case Type of
    "String" -> "std::string";
    "Long" -> "long";
    "Int" -> "boost::int32_t";
    "Double" -> "float_";
    "Boolean" -> "bool";
    _ -> "UNDEFINE"
  end
).

-define(CONVERT_FROM_OTP_TO_CPP_METHODS(Type),
  case Type of
    "String" -> "str";
    "Long" -> "long";
    "Int" -> "int";
    "Double" -> "float";
    "Boolean" -> "bool";
    _ -> "UNDEFINE"
  end
).

-define(DEFAULT_VALUE(Type),
  case Type of
    "String" -> "\" \"";
    "Long" -> "0";
    "Int" -> "0";
    "Double" -> "0";
    "Boolean" -> "true";
    _ -> "UNDEFINE"
  end
).
