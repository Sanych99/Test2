#ifndef BOTNODE_H
#define BOTNODE_H

#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <iostream>
#include <stdexcept>
#include <functional>

#include "tinch_pp/node.h"
#include "tinch_pp/rpc.h"
#include "tinch_pp/mailbox.h"
#include "tinch_pp/erlang_types.h"

#include <boost/thread.hpp>
#include <boost/assign/list_of.hpp>

#include "IBotMsgInterface.h"
#include "CollectionSubscribe.h"

using namespace tinch_pp;
using namespace tinch_pp::erl;
using namespace boost::assign;


using namespace std;

template<class NodeClass>
class BotNode {
  
  public:
    //e_tuple logSenderName;

    /** Current server name machine name */
    string currentServerName;

    /** Java Otp node */
    node_ptr otpNode;

    /** Java Otp node name */
    string otpNodeName;

    /** Otp node mail box */
    mailbox_ptr otpMboxAsync;

    /** Otp node mail box name */
    string otpMboxNameAsync;

    mailbox_ptr otpMbox;

    string otpMboxName;

    /** Server name core@machine_name */
    string coreNodeName;

    /** Core message publisher module */
    string publisherCoreNode;

    string serviceCoreNode;

    string connectorCodeNode;

    string uiInteractionNode;

    string loggerInteractionNode;

    /** Core node cookies */
    string coreCookie;
    
    /** ядро запущено */
    bool coreIsActive;
    /** узел находятся под мониторингом*/
    bool isMonitor;
    
    int epmd_port;

    std::map < std::string, std::set<BaseCollectionSubscribe> > subscribeDic;

    boost::thread receiveMBoxMessageThread;
    
    void receiveMBoxMessageMethod(mailbox_ptr async_mbox);
    
    
    
  
    //====== Константы / Constants Start ======

    static const string LOG_TYPE_MESSAGE;
    static const string LOG_TYPE_WARNING;
    static const string LOG_TYPE_ERROR;
    

    //====== Константы / Constants End ======

    BotNode() :
      otpNode(node::create("testCNode@alex-N550JK", "jv")),
      otpMbox(otpNode->create_mailbox("testCNode_Mbox")), 
      otpMboxAsync(otpNode->create_mailbox("testCNode_AsyncMbox"))
      { 
	otpNode->publish_port(500);
      };
    
    BotNode(int argc, char *argv[]) :
      otpNodeName(string(argv[1])), // init node name
      currentServerName(string(argv[2])), // init current server name
      coreNodeName(string(argv[3])), // init core node name
      otpMboxNameAsync(string(argv[1]) + "_MBoxAsync"), // init asynchronous mail box name
      otpMboxName(string(argv[1]) + "_MBox"), // init mail box name
      connectorCodeNode(string(argv[4])),  // init connector node name
      publisherCoreNode(string(argv[5])), // init publisher node name
      serviceCoreNode(string(argv[6])), // init service node name
      uiInteractionNode(string(argv[7])), // init ui interaction node name
      loggerInteractionNode(string(argv[8])), // init message logger node name
      coreCookie(string(argv[9])), // init core node cookie
      coreIsActive(true), //ядро запущено
      isMonitor(false), //при создании ябра мониторинг за узлом равен false
      epmd_port(500)
      { 
	otpNode = node::create(otpNodeName + "@" + currentServerName, coreCookie);
	otpMbox = otpNode->create_mailbox(otpMboxName);
	otpMboxAsync = otpNode->create_mailbox(otpMboxNameAsync);
	
	cout<<"BotNode constructor"<<"\n\r";
	
	cout<<"otpNodeName(argv[0]) " + string(argv[1])<<"\n\r";
	cout<<"currentServerName(argv[1]) " + string(argv[2])<<"\n\r";
	cout<<"coreNodeName(argv[2])" + string(argv[3])<<"\n\r"; 	
	cout<<"otpMboxNameAsync(string(argv[0])+ _MBoxAsync)" + string(argv[1])+ "_MBoxAsync"<<"\n\r";
	cout<<"otpMboxName(string(argv[0]) + _MBox)" + string(argv[1]) + "_MBox"<<"\n\r";
	cout<<"TestClass constructor"<<"\n\r";
	cout<<"TestClass constructor"<<"\n\r";
	cout<<"TestClass constructor"<<"\n\r";
	cout<<"TestClass constructor"<<"\n\r";
	cout<<"TestClass constructor"<<"\n\r";
	cout<<"TestClass constructor"<<"\n\r";
	cout<<"TestClass constructor"<<"\n\r";
	cout<<"TestClass constructor"<<"\n\r";
	cout<<"TestClass constructor"<<"\n\r";
	cout<<"TestClass constructor"<<"\n\r";
	cout<<"TestClass constructor"<<"\n\r";
	
	otpNode->publish_port(epmd_port);
      };
      
      bool ok();

    //virtual void action();
      
      template<typename M>     
      void subscribeToTopic(std::string topicName, void (NodeClass::*callbackFunction)(M)) {
	otpMboxAsync->send(publisherCoreNode, coreNodeName, 
	  make_e_tuple(atom("reg_subscr"), atom(otpMboxNameAsync), 
	  atom(otpNodeName + "@" + currentServerName), atom(topicName)
	));

	/*CollectionSubscribe<M> collection = new CollectionSubscribe<M>(callbackFunction);
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
	}*/
      };
};

#endif
