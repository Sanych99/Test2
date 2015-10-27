#ifndef IBotMsgInterface_H
#define IBotMsgInterface_H

#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <iostream>

#include "tinch_pp/node.h"
#include "tinch_pp/rpc.h"
#include "tinch_pp/erlang_types.h"
#include "tinch_pp/mailbox.h"

using namespace tinch_pp;
using namespace tinch_pp::erl;

using namespace tinch_pp;

/**Базовый класс сообщения*/
class IBotMsgInterface {
public:
  virtual void send_mesasge(mailbox_ptr mbox, std::string publisherCoreNode, std::string coreNodeName, 
     std::string currentNode, std::string otpMboxNameAsync, std::string topicName) const = 0;
     
  virtual void send_service_response(mailbox_ptr mbox, std::string service_core_node,  
    std::string core_node_name, std::string response_service_message, std::string service_method_name, 
    std::string client_mail_box_name, std::string client_node_full_name, std::string client_method_name_callback, matchable_ptr request_message_from_client) const = 0;
     
  /*virtual void send_service_response(mailbox_ptr mbox, std::string service_core_node,  
    std::string core_node_name, std::string response_service_message, std::string service_method_name, 
    std::string client_mail_box_name, std::string client_node_full_name, std::string client_method_name_callback, matchable_ptr request_message_from_client) const = 0;*/
    
};

#endif