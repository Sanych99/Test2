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
    string currentServerName; /** Current server name machine name */
    node_ptr otpNode; /** Java Otp node */
    string otpNodeName; /** Java Otp node name */
    mailbox_ptr otpMboxAsync; /** Otp node mail box */    
    string otpMboxNameAsync; /** Otp node mail box name */
    mailbox_ptr otpMbox; /** sync mail box */
    string otpMboxName; /** sync mail box name */
    string coreNodeName; /** Server name core@machine_name */
    string publisherCoreNode; /** Core message publisher module */
    string serviceCoreNode; /** Core services module */
    string connectorCodeNode; /** Core node connector module */
    string uiInteractionNode; /** Core user interaction module */
    string loggerInteractionNode; /** Core event logger module */    
    string coreCookie; /** Core node cookies */
    volatile bool coreIsActive; /** ядро запущено */
    bool isMonitor; /** узел находятся под мониторингом*/
    int epmd_port; /** порт для соединения с ядром */
    std::map < std::string, BaseCollectionSubscribe* > subscribeDic; /** список подписанных методов на топики */
    
    NodeClass* childObject; /** ссылка на объек узла */
    
    boost::thread* receiveMBoxMessageThread; /** поток обработка системных событий */
    void receiveMBoxMessageMethod(mailbox_ptr async_mbox); /** метод обработки системных событий */
    template<typename M> void subscribeToTopic(std::string topicName, void (NodeClass::*callbackFunction)(M));
  
    bool ok();
  
    //====== Константы / Constants Start ======

    static const string LOG_TYPE_MESSAGE;
    static const string LOG_TYPE_WARNING;
    static const string LOG_TYPE_ERROR;
    
    //====== Константы / Constants End ======
    
    BotNode();
    BotNode(int argc, char *argv[]);
    ~BotNode();   
};

template<typename NodeClass>
BotNode<NodeClass>::BotNode() :
  otpNode(node::create("testCNode@alex-N550JK", "jv")),
  otpMbox(otpNode->create_mailbox("testCNode_Mbox")), 
  otpMboxAsync(otpNode->create_mailbox("testCNode_AsyncMbox"))
  { 
    otpNode->publish_port(500);
  };
  
  
template<typename NodeClass>
BotNode<NodeClass>::BotNode(int argc, char *argv[]) :
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
  { 
    otpNode = node::create(otpNodeName + "@" + currentServerName, coreCookie);
    otpMbox = otpNode->create_mailbox(otpMboxName);
    otpMboxAsync = otpNode->create_mailbox(otpMboxNameAsync);

    receiveMBoxMessageThread = new boost::thread(&BotNode::receiveMBoxMessageMethod, this, otpMboxAsync);

    otpNode->publish_port(epmd_port);
  };

template<typename NodeClass>
BotNode<NodeClass>::~BotNode() {};
  
  
template<typename NodeClass>
template<typename M>     
void BotNode<NodeClass>::subscribeToTopic(std::string topicName, void (NodeClass::*callbackFunction)(M)) {
  otpMboxAsync->send(publisherCoreNode, coreNodeName, 
    make_e_tuple(atom("reg_subscr"), atom(otpMboxNameAsync), 
    atom(otpNodeName + "@" + currentServerName), atom(topicName)
  ));

  CollectionSubscribe<NodeClass, M>* collection = new CollectionSubscribe<NodeClass, M>(callbackFunction, topicName, childObject);
  //map<std::string, BaseCollectionSubscribe* >::iterator it = subscribeDic.find(topicName);

  BaseCollectionSubscribe* topicSubscribersCollection = collection;
  subscribeDic[topicName] = topicSubscribersCollection;

  /**subscribeDic.at(topicName)->execute();*/
  /**BaseCollectionSubscribe* tryexec = subscribeDic.at(topicName);
  tryexec->execute();*/
};


template<typename NodeClass>
void BotNode<NodeClass>::receiveMBoxMessageMethod(mailbox_ptr async_mbox)
{
  enum ReceivedMessageType { 
    subscribe, 
    call_service_method, 
    call_client_service_callback_method,
    system,
    no_action
  };
  
  ReceivedMessageType msgTypeEnum;
  
  while(coreIsActive) {
    matchable_ptr msg = async_mbox->receive();

    std::cout<<"receive message..."<< "\n\r";
    
    std::string test;
    msg->match(make_e_tuple(e_string(&test), erl::any(), erl::any()));
    
    std::cout<<"action name: " + test<< "\n\r";
    
    if (msg->match(make_e_tuple(e_string("subscribe"), erl::any(), erl::any()))) {
      msgTypeEnum = subscribe;
      std::cout<<"if subscribe"<< "\n\r";
    }
    else {
      msgTypeEnum = no_action;
      std::cout<<"if no_action"<< "\n\r";
    }
    

    switch(msgTypeEnum) {
      case subscribe: {
	std::string topicName;
	matchable_ptr message_elements;
	std::cout<<"enter to subscribe..."<< "\n\r";
	msg->match(make_e_tuple(erl::any(), e_string(&topicName), any(&message_elements)));
	cout<<"1: " + topicName << "\n\r";
	subscribeDic.at(topicName)->execute(message_elements);
      }
	break;

      case no_action: {
	cout<< "no_action" << "\n\r";
      }
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


#endif
