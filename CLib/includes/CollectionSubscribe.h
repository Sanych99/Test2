#ifndef CollectionSubscribe_H
#define CollectionSubscribe_H

#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <functional>

#include "IBotMsgInterface.h"

class BaseCollectionSubscribe {
public:
  BaseCollectionSubscribe() {};
};

template<typename MType>
class CollectionSubscribe: public BaseCollectionSubscribe {
public:
  void (*callback)(MType);
  MType t;
  
  CollectionSubscribe(void (*callbackFunction)(MType)) {
    callback = callbackFunction;
  }
};

#endif