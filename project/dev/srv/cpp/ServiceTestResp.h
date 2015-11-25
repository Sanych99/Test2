#include "IBotMsgInterface.h"

class ServiceTestResp: public IBotMsgInterface {
public:

	std::string strParamResp;

	ServiceTestResp() {
		set_default_values();
	}

	ServiceTestResp(matchable_ptr message_elements) {
		message_elements->match(make_e_tuple(e_string(&strParamResp)));
	}

	virtual void send_mesasge(mailbox_ptr mbox, std::string publisherCoreNode, std::string coreNodeName, 
		std::string currentNode, std::string otpMboxNameAsync, std::string topicName) const {
		std::cout<<"no action"<<"\n\r";
	}

	virtual void send_service_response(mailbox_ptr mbox, std::string service_core_node, 
		std::string core_node_name, std::string response_service_message, std::string service_method_name, 
		std::string client_mail_box_name, std::string client_node_full_name, std::string client_method_name_callback, matchable_ptr request_message_from_client) const {
		ServiceTestReq req(request_message_from_client);
		mbox->send(service_core_node, core_node_name, make_e_tuple(atom(response_service_message), e_string(service_method_name), atom(client_mail_box_name),
			atom(client_node_full_name), e_string(client_method_name_callback), req.get_tuple_message() ,
			make_e_tuple(e_string(strParamResp))
		));
	}

	e_tuple<boost::fusion::tuple<e_string> > get_tuple_message() {
		return make_e_tuple(e_string(strParamResp));
	};

	void set_default_values() {
		strParamResp = " ";
	}
};