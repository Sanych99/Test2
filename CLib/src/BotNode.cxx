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

/*message log type*/
template<class NodeClass> const std::string BotNode<NodeClass>::LOG_TYPE_MESSAGE("Message");
/*warning log type*/
template<class NodeClass> const std::string BotNode<NodeClass>::LOG_TYPE_WARNING("Warning");
/*error log type*/
template<class NodeClass> const std::string BotNode<NodeClass>::LOG_TYPE_ERROR("Error");

template<class NodeClass>
bool BotNode<NodeClass>::ok()
{
  return coreIsActive;
}



/*template<class NodeClass>
template<typename M>
void BotNode<NodeClass>:: subscribeToTopic(std::string topicName, void (NodeClass::*callbackFunction)(M))
{
  otpMboxAsync->send(publisherCoreNode, coreNodeName, 
		     make_e_tuple(atom("reg_subscr"), atom(otpMboxNameAsync), 
		      atom(otpNodeName + "@" + currentServerName), atom(topicName)
		     ));
  
  CollectionSubscribe<M> collection = new CollectionSubscribe<M>(*callbackFunction);
    map<std::string, set<BaseCollectionSubscribe> >::iterator it = subscribeDic.find(topicName);
    if(it != subscribeDic.end()) {
      //element found;
      set<BaseCollectionSubscribe> topicSubscribersCollection = it->second;
      topicSubscribersCollection.insert(collection);
      subscribeDic[topicName] = topicSubscribersCollection;
    }
    else {
      set<BaseCollectionSubscribe> topicSubscribersCollection;
      topicSubscribersCollection.insert(collection);
      subscribeDic[topicName] = topicSubscribersCollection;
    }
}*/
