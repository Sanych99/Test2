#include "IBotMsgInterface.h"

class TestTypesMessage: public IBotMsgInterface {
public:

	std::string strParam;
	boost::int32_t longParam;
	boost::int32_t intPara;
	double doubleParam;
	bool boolParam; std::string boolParam_str;

	TestTypesMessage() {
		set_default_values();
	}

	TestTypesMessage(matchable_ptr message_elements) {
		message_elements->match(make_e_tuple(e_string(&strParam), int_(&longParam), int_(&intPara), float_(&doubleParam), atom(&boolParam_str)));
		boolParam = boost::lexical_cast<bool>(boolParam_str);
	}

	virtual void send_mesasge(mailbox_ptr mbox, std::string publisherCoreNode, std::string coreNodeName, 
		std::string currentNode, std::string otpMboxNameAsync, std::string topicName) const {
		mbox->send(publisherCoreNode, coreNodeName, 
		make_e_tuple(atom("broadcast"), atom(otpMboxNameAsync), 
		atom(currentNode), atom(topicName), make_e_tuple(e_string(strParam), int_(longParam), int_(intPara), float_(doubleParam), atom(boost::lexical_cast<std::string>(boolParam)))
	));
	}

	virtual void send_service_response(mailbox_ptr mbox, std::string service_core_node,
		std::string core_node_name, std::string response_service_message, std::string service_method_name, 
		std::string client_mail_box_name, std::string client_node_full_name, std::string client_method_name_callback, matchable_ptr request_message_from_client) const {
		std::cout<<"no action"<<"\n\r";
	}

	e_tuple<boost::fusion::tuple<e_string, int_, int_, float_, atom> > get_tuple_message() {
		return make_e_tuple(e_string(strParam), int_(longParam), int_(intPara), float_(doubleParam), atom(boost::lexical_cast<std::string>(boolParam)));
	};

	void set_default_values() {
		strParam = " ";
		longParam = 0;
		intPara = 0;
		doubleParam = 0.0;
		boolParam = true; boolParam_str = "true";
	}
};