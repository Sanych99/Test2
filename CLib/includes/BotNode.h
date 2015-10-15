#ifndef BOTNODE_H
#define BOTNODE_H

#include <stdio.h>
#include <stdlib.h>
#include <string>

#include "tinch_pp/node.h"
#include "tinch_pp/rpc.h"
#include "tinch_pp/mailbox.h"
#include "tinch_pp/erlang_types.h"
#include <boost/thread.hpp>
#include <boost/assign/list_of.hpp>
#include <iostream>
#include <stdexcept>
using namespace tinch_pp;
using namespace tinch_pp::erl;
using namespace boost::assign;


using namespace std;

class BotNode {
  private:
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

  public:
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
      otpNodeName(argv[0]), // init node name
      currentServerName(argv[1]), // init current server name
      coreNodeName(argv[2]), // init core node name
      otpMboxNameAsync(string(argv[0]) + "_MBoxAsync"), // init asynchronous mail box name
      otpMboxName(string(argv[0]) + "_MBox"), // init mail box name
      connectorCodeNode(argv[3]),  // init connector node name
      publisherCoreNode(argv[4]), // init publisher node name
      serviceCoreNode(argv[5]), // init service node name
      uiInteractionNode(argv[6]), // init ui interaction node name
      loggerInteractionNode(argv[7]), // init message logger node name
      coreCookie(argv[8]), // init core node cookie
      otpNode(node::create(otpNodeName + "@" + currentServerName, coreCookie)),
      otpMbox(otpNode->create_mailbox(otpMboxName)), 
      otpMboxAsync(otpNode->create_mailbox(otpMboxNameAsync))
      { };

    //virtual void action();
};

#endif
