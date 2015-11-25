#include "IBotMsgInterface.h"

class ServiceTestReq: public IBotMsgInterface {
public:

	std::string strParamReq;

	ServiceTestReq() {
		set_default_values();
	}

	ServiceTestReq(matchable_ptr message_elements) {
		message_elements->match(make_e_tuple(e_string(&strParamReq)));
	}

	virtual void send_mesasge(mailbox_ptr mbox, std::string publisherCoreNode, std::string coreNodeName, 
		std::string currentNode, std::string otpMboxNameAsync, std::string topicName) const {
		std::cout<<"no action"<<"\n\r";
	}

	virtual void send_service_response(mailbox_ptr mbox, std::string service_core_node,
		std::string core_node_name, std::string response_service_message, std::string service_method_name, 
		std::string client_mail_box_name, std::string client_node_full_name, std::string client_method_name_callback, matchable_ptr request_message_from_client) const {
		std::cout<<"no action"<<"\n\r";
	}

	e_tuple<boost::fusion::tuple<e_string> > get_tuple_message() {
		return make_e_tuple(e_string(strParamReq));
	};

	void set_default_values() {
		strParamReq = " ";
	}
};