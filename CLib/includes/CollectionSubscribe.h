#ifndef CollectionSubscribe_H
#define CollectionSubscribe_H

#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <iostream>
#include <functional>

#include "tinch_pp/rpc.h"
#include "tinch_pp/erlang_types.h"

using namespace tinch_pp;

class BaseCollectionSubscribe {
public:
  std::string topicName;
  
  std::string order;
  std::string equality;
  
  BaseCollectionSubscribe(std::string tName) {
    topicName = tName;
  };
  
  BaseCollectionSubscribe(BaseCollectionSubscribe o, BaseCollectionSubscribe e) : order(o.topicName), equality(e.topicName) {}
  
  bool operator<(const BaseCollectionSubscribe &rhs) const {
        return order < rhs.order;
    }
  bool operator==(const BaseCollectionSubscribe &rhs) const {
      return equality == rhs.equality;
  }
  
  virtual void execute(void) const {  std::cout<<"BASE CLASS VIRTUAL"<<"\n\r"; };
  virtual void execute(matchable_ptr message_elements) const {  std::cout<<"BASE CLASS VIRTUAL"<<"\n\r"; };
};

template<typename NodeClass, typename MType>
class CollectionSubscribe: public BaseCollectionSubscribe {
public:
  void (NodeClass::*callback)(MType);
  MType t();
  NodeClass* childObject;
  
  CollectionSubscribe(void (NodeClass::*callbackFunction)(MType), std::string topicName, NodeClass* child): BaseCollectionSubscribe(topicName) {
    callback = callbackFunction;
    childObject = child;
  }
  
  virtual void execute(void) const {
    std::cout<<"FROM CHILDER CLASS"<<"\n\r";
    (childObject->*callback)(MType());
  }
  
  virtual void execute(matchable_ptr message_elements) const {
    std::cout<<"FROM CHILDER matchable_ptr"<<"\n\r";
    (childObject->*callback)(MType(message_elements));
  }
};

#endif