#ifndef CollectionServiceClient_H
#define CollectionServiceClient_H

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


class BaseCollectionServiceClient {
public:
  BaseCollectionServiceClient() {};
  
  virtual void execute(matchable_ptr request_message, matchable_ptr response_message) 
  {  
    /*std::cout<<"BASE CLASS VIRTUAL"<<"\n\r"; */
  };
};

template<typename NodeClass, typename ReqType, typename RespType>
class CollectionServiceClient: public BaseCollectionServiceClient {
public:
  //void (NodeClass::*callback)(ReqType, RespType);
  boost::function<void(ReqType, RespType)> callback;
  boost::shared_ptr<NodeClass> child_object;
  
  //CollectionServiceClient(void (NodeClass::*callbackFunction)(ReqType, RespType), NodeClass* child) {
  CollectionServiceClient(boost::function<void(ReqType, RespType)>& callbackFunction, boost::shared_ptr<NodeClass>& child) {
    callback = callbackFunction;
    child_object = child;
  };
  
  virtual void execute(matchable_ptr request_message, matchable_ptr response_message) 
  {  
    /*std::cout<<"SERVICE CLIENT CHILD CLASS VIRTUAL"<<"\n\r"; */
    //(child_object->*callback)(ReqType(request_message), RespType(response_message));
    callback(ReqType(request_message), RespType(response_message));
  };
};





#endif