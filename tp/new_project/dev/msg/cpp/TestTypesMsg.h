#include "IBotMsgInterface.h"

class TestTypesMsg: public IBotMsgInterface {
public:

	bool boolParam;
	float_ doubleParam;
	boost::int32_t intPara;
	long longParam;
	std::string strParam;

	TestTypesMsg() {
		set_default_values();
	}

	TestTypesMsg(matchable_ptr message_elements) {
		message_elements->match(make_e_tuple(bool(&boolParam), float_(&doubleParam), int_(&intPara), long(&longParam), e_string(&strParam)));
	}

	virtual void send_mesasge(mailbox_ptr mbox, std::string publisherCoreNode, std::string coreNodeName, 
		std::string currentNode, std::string otpMboxNameAsync, std::string topicName) const {
		mbox->send(publisherCoreNode, coreNodeName, 
		make_e_tuple(atom("broadcast"), atom(otpMboxNameAsync), 
		atom(currentNode), atom(topicName), make_e_tuple(bool(boolParam), float_(doubleParam), int_(intPara), long(longParam), e_string(strParam))
	));
	}

	virtual void send_service_response(mailbox_ptr mbox, std::string service_core_node,
		std::string core_node_name, std::string response_service_message, std::string service_method_name, 
		std::string client_mail_box_name, std::string client_node_full_name, std::string client_method_name_callback, matchable_ptr request_message_from_client) const {
		std::cout<<"no action"<<"\n\r";
	}

	e_tuple<boost::fusion::tuple<bool, float_, int_, long, e_string> > get_tuple_message() {
		return make_e_tuple(bool(boolParam), float_(doubleParam), int_(intPara), long(longParam), e_string(strParam));
	};

	void set_default_values() {
		boolParam = true;
		doubleParam = 0;
		intPara = 0;
		longParam = 0;
		strParam = " ";
	}
};