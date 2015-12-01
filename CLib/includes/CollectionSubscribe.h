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
  
  virtual void execute(void) const {  /*std::cout<<"BASE CLASS VIRTUAL"<<"\n\r";*/ };
  virtual void execute(matchable_ptr message_elements) const {  /*std::cout<<"BASE CLASS VIRTUAL"<<"\n\r";*/ };
};

template<typename NodeClass, typename MType>
class CollectionSubscribe: public BaseCollectionSubscribe {
public:
  boost::function<void(MType)> callback;
  MType t();
  boost::shared_ptr<NodeClass> childObject;
  
  CollectionSubscribe(boost::function<void(MType)>& callback_function, std::string topicName, boost::shared_ptr<NodeClass>& child): BaseCollectionSubscribe(topicName) {
    callback = callback_function;
    childObject = child;
  }
  
  virtual void execute(void) const {
    /*std::cout<<"FROM CHILDER CLASS"<<"\n\r";*/
    callback(MType());
  }
  
  virtual void execute(matchable_ptr message_elements) const {
    /*std::cout<<"FROM CHILDER matchable_ptr"<<"\n\r";*/
    callback(MType(message_elements));
  }
};

#endif