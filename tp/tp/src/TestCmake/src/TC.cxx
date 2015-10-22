// A simple program that computes the square root of a number
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <iostream>
#include <string>
#include <unistd.h>
#include "BotNode.h"

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

class TesMsg: public IBotMsgInterface {
public:
  TesMsg() {
    cout<<"Hello from TesMsg"<<"\n\r";
  }
  
  TesMsg(string msg) {
    cout<<"Clone " + msg<<"\n\r";
  }
};

class TestClass: public BotNode<TestClass> {
  public:
    
    void print() {
      cout << "TestClass" << "\n\r";
      //action();
    }
    
    TestClass* thisParam;
    
    TestClass(): BotNode() {};
    
    TestClass(int argc, char* argv[]): BotNode(argc, argv) {
      
      cout<<"otpNodeName(argv[0]) " + string(argv[1])<<"\n\r";
	cout<<"currentServerName(argv[1]) " + string(argv[2])<<"\n\r";
	cout<<"coreNodeName(argv[2]) " + string(argv[3])<<"\n\r"; 	
	cout<<"otpMboxNameAsync(string(argv[0])+ _MBoxAsync) " + string(argv[1])+ "_MBoxAsync"<<"\n\r";
	cout<<"otpMboxName(string(argv[0]) + _MBox) " + string(argv[1]) + "_MBox"<<"\n\r";
	cout<<"connectorCodeNode(string(argv[4])) " + string(argv[4])<<"\n\r";
	cout<<"publisherCoreNode(string(argv[5])) " + string(argv[5])<<"\n\r";
	cout<<"serviceCoreNode(string(argv[6])) " + string(argv[6])<<"\n\r";
	cout<<"uiInteractionNode(string(argv[7])) " + string(argv[7])<<"\n\r";
	cout<<"loggerInteractionNode(string(argv[8])) " + string(argv[8])<<"\n\r";
	cout<<"coreCookie(string(argv[9])) " + string(argv[9])<<"\n\r";
	cout<<"TestClass constructor"<<"\n\r";
	cout<<"TestClass constructor"<<"\n\r";
	cout<<"TestClass constructor"<<"\n\r";
	cout<<"TestClass constructor"<<"\n\r";
	cout<<"TestClass constructor"<<"\n\r";
     
 /*
      connectorCodeNode(string(argv[4])),  // init connector node name
      publisherCoreNode(string(argv[5])), // init publisher node name
      serviceCoreNode(string(argv[6])), // init service node name
      uiInteractionNode(string(argv[7])), // init ui interaction node name
      loggerInteractionNode(string(argv[8])), // init message logger node name
      coreCookie(string(argv[9])), // init core node cookie
      otpNode(node::create(otpNodeName + "@" + currentServerName, coreCookie)),
      otpMbox(otpNode->create_mailbox(otpMboxName)), 
      otpMboxAsync(otpNode->create_mailbox(otpMboxNameAsync)),
      coreIsActive(true), //ядро запущено
      isMonitor(false), //при создании ябра мониторинг за узлом равен false
      epmd_port(500)
      */
    };
    
    ~TestClass() {};
    
    void cm(TesMsg msg) { cout<<"CM1"<<"\n\r"; };
    void cm2(TesMsg msg) { cout<<"CM2"<<"\n\r"; };
    
    void pr() { cout<<"aaasdasdasd"<<"\n\r"; }
    
    void te (void (TestClass::*callbackFunction)())
    {
      //*callbackFunction();
    }
    
    
    void print ( int x ) {
      cout << x << endl;
    }
    
    void func ( void (TestClass::*f)(int) ) {
      for ( int ctr = 0 ; ctr < 5 ; ctr++ ) {
	(thisParam->*f)(ctr);
      }
    }
    
    void go() {
      //subscribeToTopic<TesMsg>(TesMsg);
     subscribeToTopic<TesMsg>("testTopic", &TestClass::cm);
     subscribeToTopic<TesMsg>("testTopic", &TestClass::cm2);
     //te(&TestClass::pr);
      func(&TestClass::print);
    }
    
    
    
  /*virtual void action() {
    cout << "action mathod..." << "\n\r";
  }*/
};



void func ( void (*f)(int) ) {
  for ( int ctr = 0 ; ctr < 5 ; ctr++ ) {
    (*f)(ctr);
  }
}

void print ( int x ) {
  cout << x << endl;
}

void bw() {
  int i = 1000000;
  while(i>0) {
    print(i);
    i--;
    usleep(2000);
  }
}

int main(int argc, char* argv[]) {
  TestClass ts(argc, argv);
  ts.thisParam = &ts;
  ts.go();
  bw();
  ts.td->start_thread();
  ts.td->join();
  //ts = new TestClass(argc, argv);
  //ts->go();
  //ts = new TestClass();
  //ts->print();
  //ts.print();
  int i = 0;
  /*while(i<10000000) 
  {
    ts->print();
  }*/
  
  func(print);
  
  //boost::thread td(&ts.receiveMBoxMessageMethod, ts, ts.otpMboxAsync);
  
}