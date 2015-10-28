// A simple program that computes the square root of a number
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <iostream>
#include <stdexcept>

#include <sys/types.h>
#include <sys/socket.h>

#include <netinet/in.h>
#include <arpa/inet.h>

#include "BotNode.h"
#include "IBotMsgInterface.h"
#include "CollectionSubscribe.h"

#include "tinch_pp/node.h"
#include "tinch_pp/rpc.h"
#include "tinch_pp/mailbox.h"
#include "tinch_pp/erlang_types.h"

#include <boost/thread.hpp>
#include <boost/assign/list_of.hpp>
#include <boost/fusion/tuple/tuple.hpp>

using namespace tinch_pp;
using namespace tinch_pp::erl;

using namespace boost::assign;

using namespace std;

namespace BotNodeNameSpace {
  
  /*message log type*/
  template<class NodeClass> const std::string BotNode<NodeClass>::LOG_TYPE_MESSAGE("Message");
  /*warning log type*/
  template<class NodeClass> const std::string BotNode<NodeClass>::LOG_TYPE_WARNING("Warning");
  /*error log type*/
  template<class NodeClass> const std::string BotNode<NodeClass>::LOG_TYPE_ERROR("Error");
}