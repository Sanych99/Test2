#ifndef BOTNODE_H
#define BOTNODE_H

#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <iostream>
#include <stdexcept>
#include <functional>
#include <exception>
#include <typeinfo>

#include <boost/thread.hpp>
#include <boost/assign/list_of.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/make_shared.hpp>
#include <boost/fusion/include/adapt_struct.hpp>
#include <boost/phoenix.hpp>

#include "tinch_pp/node.h"
#include "tinch_pp/rpc.h"
#include "tinch_pp/mailbox.h"
#include "tinch_pp/erlang_types.h"



#include "IBotMsgInterface.h"
#include "CollectionSubscribe.h"

using namespace tinch_pp;
using namespace tinch_pp::erl;
using namespace boost::assign;

template<class NodeClass>
class BotNode: boost::noncopyable {
  
};


#endif