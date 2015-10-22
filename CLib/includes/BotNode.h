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
class BotNode: boost::noncopyable {
  
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

    std::map < std::string, BaseCollectionSubscribe* > subscribeDic;

    boost::thread receiveMBoxMessageThread;
    
    //void receiveMBoxMessageMethod(mailbox_ptr async_mbox);
    
    NodeClass* childObject;
    
    
    
    
    
    void receiveMBoxMessageMethod(mailbox_ptr async_mbox)
{
  enum ReceivedMessageType { 
    subscribe, 
    call_service_method, 
    call_client_service_callback_method,
    system
  };
  
  ReceivedMessageType msgTypeEnum;
  
  while(coreIsActive) {
        matchable_ptr msg = async_mbox->receive();
	
	std::cout<<"receive message..."<< "\n\r";
	
	std::string msgType;
	msg->match(make_e_tuple(e_string(&msgType), erl::any()));
	
	std::cout<<"message type: " + msgType<< "\n\r";
	
	if(msgType == "subscribe")
	  msgTypeEnum = subscribe;
	else if(msgType == "call_service_method")
	  msgTypeEnum = call_service_method;
	else if(msgType == "call_client_service_callback_method")
	  msgTypeEnum = call_client_service_callback_method;
	else if(msgType == "system")
	  msgTypeEnum = system;
	  
	
	
	
	switch(msgTypeEnum) {
	  case subscribe:
	    std::string topicName;
	    //e_tuple<TestMsg> subscribeMessage;
	    
	    std::cout<<"enter to subscribe..."<< "\n\r";
	    
	    //typedef boost::fusion::tuple<e_string, e_string> call_type;
	    //call_type* subscribeMessage = new call_type();
	    
	    matchable_ptr reply_part;
	    
	    msg->match(make_e_tuple(e_string(&msgType), e_string(&topicName), any(&reply_part)));
	    cout<<"1: " + topicName << "\n\r";
	    //cout<<"2: " + string(std::get<1>(subscribeMessage)) << "\n\r";
	    break;
	    
	  /*case call_service_method:
	    break;
	    
	  case call_client_service_callback_method:
	    break;*/
	    
	  //case system:
	  //  coreIsActive = false;
	  //  break;
	}
  }
};
    



 template<typename M>     
      void subscribeToTopic(std::string topicName, void (NodeClass::*callbackFunction)(M)) {
	otpMboxAsync->send(publisherCoreNode, coreNodeName, 
	  make_e_tuple(atom("reg_subscr"), atom(otpMboxNameAsync), 
	  atom(otpNodeName + "@" + currentServerName), atom(topicName)
	));

	//try {
	
	  CollectionSubscribe<NodeClass, M>* collection = new CollectionSubscribe<NodeClass, M>(callbackFunction, topicName, childObject);
	  //CollectionSubscribe<NodeClass, M> collection(callbackFunction, topicName);
	  map<std::string, BaseCollectionSubscribe* >::iterator it = subscribeDic.find(topicName);
	  
	  /*if(it == subscribeDic.end()) {
	    //element found;
	    set<BaseCollectionSubscribe*> topicSubscribersCollection = it->second;
	    topicSubscribersCollection.insert(collection);
	    subscribeDic[topicName] = topicSubscribersCollection;
	  }
	  else {*/
	    BaseCollectionSubscribe* topicSubscribersCollection = collection;
	    subscribeDic[topicName] = topicSubscribersCollection;
	  /*}*/
	  
	  
	  std::map<std::string, BaseCollectionSubscribe* >::iterator it2 = subscribeDic.find(topicName);
	  BaseCollectionSubscribe* topicSubscribersCollection2 = it2->second;
	  
	  BaseCollectionSubscribe* tryexec = subscribeDic.at(topicName);
	  tryexec->execute();
	  
	  subscribeDic.at(topicName)->execute();
	  
	  //for (std::set<BaseCollectionSubscribe>::iterator it3=topicSubscribersCollection2.begin(); it3!=topicSubscribersCollection2.end(); ++it3) {
	    topicSubscribersCollection2->execute();
	    std::cout<<"Go find..."<<"\n\r";
	  //}
	  
	//catch (exception& e)
	//{
	//  cout << "EX: " + string(e.what()) << '\n';
	//}
      };
      
      
    
    
  
    //====== Константы / Constants Start ======

    static const string LOG_TYPE_MESSAGE;
    static const string LOG_TYPE_WARNING;
    static const string LOG_TYPE_ERROR;
    

    //====== Константы / Constants End ======
    
    boost::thread msg_receiver;
    
    ~BotNode() {
      //msg_receiver.detach();
      //msg_receiver.join();
    }

    BotNode() :
      otpNode(node::create("testCNode@alex-N550JK", "jv")),
      otpMbox(otpNode->create_mailbox("testCNode_Mbox")), 
      otpMboxAsync(otpNode->create_mailbox("testCNode_AsyncMbox"))
      { 
	otpNode->publish_port(500);
      };
          boost::thread* td;
    BotNode(int argc, char *argv[]) :
      otpNodeName(std::string(argv[1])), // init node name
      currentServerName(std::string(argv[2])), // init current server name
      coreNodeName(std::string(argv[3])), // init core node name
      otpMboxNameAsync(std::string(argv[1]) + "_MBoxAsync"), // init asynchronous mail box name
      otpMboxName(std::string(argv[1]) + "_MBox"), // init mail box name
      connectorCodeNode(std::string(argv[4])),  // init connector node name
      publisherCoreNode(std::string(argv[5])), // init publisher node name
      serviceCoreNode(std::string(argv[6])), // init service node name
      uiInteractionNode(std::string(argv[7])), // init ui interaction node name
      loggerInteractionNode(std::string(argv[8])), // init message logger node name
      coreCookie(std::string(argv[9])), // init core node cookie
      coreIsActive(true), //ядро запущено
      isMonitor(false), //при создании ябра мониторинг за узлом равен false
      epmd_port(500)
      //msg_receiver(&BotNode::receiveMBoxMessageMethod, this, otpMboxAsync)
      { 
	otpNode = node::create(otpNodeName + "@" + currentServerName, coreCookie);
	otpMbox = otpNode->create_mailbox(otpMboxName);
	otpMboxAsync = otpNode->create_mailbox(otpMboxNameAsync);
	//boost::thread td(&BotNode::receiveMBoxMessageMethod, this, otpMboxAsync);
	td = new boost::thread(&BotNode::receiveMBoxMessageMethod, this, otpMboxAsync);
	//msg_receiver(&BotNode::receiveMBoxMessageMethod, this, otpMboxAsync);
	
	
	
	std::cout<<"BotNode constructor"<<"\n\r";
	
	std::cout<<"otpNodeName(argv[0]) " + std::string(argv[1])<<"\n\r";
	std::cout<<"currentServerName(argv[1]) " + std::string(argv[2])<<"\n\r";
	std::cout<<"coreNodeName(argv[2])" + std::string(argv[3])<<"\n\r"; 	
	std::cout<<"otpMboxNameAsync(string(argv[0])+ _MBoxAsync)" + std::string(argv[1])+ "_MBoxAsync"<<"\n\r";
	std::cout<<"otpMboxName(string(argv[0]) + _MBox)" + std::string(argv[1]) + "_MBox"<<"\n\r";
	std::cout<<"TestClass constructor"<<"\n\r";
	std::cout<<"TestClass constructor"<<"\n\r";
	std::cout<<"TestClass constructor"<<"\n\r";
	std::cout<<"TestClass constructor"<<"\n\r";
	std::cout<<"TestClass constructor"<<"\n\r";
	std::cout<<"TestClass constructor"<<"\n\r";
	std::cout<<"TestClass constructor"<<"\n\r";
	std::cout<<"TestClass constructor"<<"\n\r";
	std::cout<<"TestClass constructor"<<"\n\r";
	std::cout<<"TestClass constructor"<<"\n\r";
	std::cout<<"TestClass constructor"<<"\n\r";
	
	otpNode->publish_port(epmd_port);
	//td.join();
      };
      
      bool ok();

    //virtual void action();
      
     


};





#endif
