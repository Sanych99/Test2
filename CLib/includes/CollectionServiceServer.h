#ifndef CollectionServiceServer_H
#define CollectionServiceServer_H

#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <iostream>
#include <functional>

#include "tinch_pp/rpc.h"
#include "tinch_pp/erlang_types.h"
#include "tinch_pp/mailbox.h"

using namespace tinch_pp;
using namespace tinch_pp::erl;


class BaseCollectionServiceServer {
public:
  BaseCollectionServiceServer() {};
  
  virtual void execute(mailbox_ptr mbox, std::string service_core_node,  
    std::string core_node_name, std::string response_service_message, std::string service_method_name, 
    std::string client_mail_box_name, std::string client_node_full_name, std::string client_method_name_callback, matchable_ptr request_message_from_client) 
  {  
    /*std::cout<<"BASE CLASS VIRTUAL"<<"\n\r"; */
  };
};


template<typename NodeClass, typename ReqType, typename RespType>
class CollectionServiceServer: public BaseCollectionServiceServer {
protected:
  boost::function<RespType(ReqType)> callback;
  boost::shared_ptr<NodeClass> child_object;
  
public:
  CollectionServiceServer(boost::function<RespType(ReqType)>& callbackFunction, boost::shared_ptr<NodeClass>& child): BaseCollectionServiceServer() {
    callback = callbackFunction;
    child_object = child;
  };
  
  virtual void execute(mailbox_ptr mbox, std::string service_core_node,  
    std::string core_node_name, std::string response_service_message, std::string service_method_name, 
    std::string client_mail_box_name, std::string client_node_full_name, std::string client_method_name_callback, matchable_ptr request_message_from_client) {
      RespType response(callback(ReqType(request_message_from_client)));
      response.send_service_response(mbox, service_core_node,  
	core_node_name, response_service_message, service_method_name, 
	client_mail_box_name, client_node_full_name, client_method_name_callback, request_message_from_client);
    };
};


/*template<typename NodeClass, typename ReqType, typename RespType>
void CollectionServiceServer<NodeClass, ReqType, RespType>::execute(mailbox_ptr mbox, std::string service_core_node,  
  std::string core_node_name, std::string response_service_message, std::string service_method_name, 
  std::string client_mail_box_name, std::string client_node_full_name, std::string client_method_name_callback, matchable_ptr request_message_from_client)
{
  RespType response((childObject->*callback)(ReqType(request_message_from_client)));
  response.send_service_response(mbox, service_core_node,  
    core_node_name, response_service_message, service_method_name, 
    client_mail_box_name, client_node_full_name, client_method_name_callback, request_message_from_client);
}*/




#endif