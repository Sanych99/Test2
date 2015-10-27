// A simple program that computes the square root of a number

#include "BotNode.h"
#include "IBotMsgInterface.h"

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>

using namespace std;

using namespace BotNodeNameSpace;

class TesMsg: public IBotMsgInterface {
public:
  std::string text;
  
  TesMsg(matchable_ptr message_elements) {   
    message_elements->match(make_e_tuple(e_string(&text)));
    cout<<"TesMsg text: " + text<<"\n\r";
  }
  
  TesMsg() {
    text = "empty";
    cout<<"TesMsg"<<"\n\r";
  }
  
  TesMsg(string msg) {
    text = msg;
    cout<<"Clone " + msg<<"\n\r";
  }
  
  
  virtual void send_mesasge(mailbox_ptr mbox, std::string publisherCoreNode, std::string coreNodeName, 
		    std::string currentNode, std::string otpMboxNameAsync, std::string topicName) const {
    mbox->send(publisherCoreNode, coreNodeName, 
    make_e_tuple(atom("broadcast"), atom(otpMboxNameAsync), 
    atom(currentNode), atom(topicName), make_e_tuple(e_string("from test message atom!"))
  ));
  }
  
  
  virtual void send_service_response(mailbox_ptr mbox, std::string service_core_node,  
    std::string core_node_name, std::string response_service_message, std::string service_method_name, 
    std::string client_mail_box_name, std::string client_node_full_name, std::string client_method_name_callback, matchable_ptr request_message_from_client) const {
      
    e_tuple<boost::fusion::tuple<atom> > test_tuple = make_e_tuple(atom("test atom from new tuple!"));
      
    mbox->send(service_core_node, core_node_name, make_e_tuple(atom(response_service_message), e_string(service_method_name), atom(client_mail_box_name), 
	      atom(client_node_full_name), e_string(client_method_name_callback), test_tuple, 
	      make_e_tuple(e_string("from test message atom SERVICE!"))));
  }
  
  
  /*virtual void send_service_response(mailbox_ptr mbox, std::string service_core_node, 
				     std::string core_node_name, std::string response_service_message, std::string service_method_name, 
				     std::string client_mail_box_name, std::string client_node_full_name, std::string client_method_name_callback, 
				     matchable_ptr request_message_from_client) {
    
    mbox->send(service_core_node, core_node_name, make_e_tuple(atom(response_service_message), e_string(service_method_name), atom(client_mail_box_name), 
	      atom(client_node_full_name), e_string(client_method_name_callback), make_e_tuple(atom("nado postavit request")), 
	      make_e_tuple(e_string("from test message atom SERVICE!"))));
  }*/
};

class TestClass: public BotNode<TestClass> {
  public:
    
    TestClass(int argc, char* argv[]): BotNode(argc, argv) {
    };
    
    ~TestClass() {};
    
    void cm(TesMsg msg) { cout<<"CM1: " + msg.text<<"\n\r"; };
    void cm2(TesMsg msg) { cout<<"CM2: " + msg.text<<"\n\r"; };
    
    void go() {
     subscribe_to_topic<TesMsg>("testTopic", &TestClass::cm);
     subscribe_to_topic<TesMsg>("testTopic", &TestClass::cm2);
     
     TesMsg* t = new TesMsg();
     
     publish_message("testTopic", t);
     
     delete t;
    }
};


int main(int argc, char* argv[]) {
  TestClass ts(argc, argv);
  ts.child_object = &ts;
  ts.go();
  ts.receive_mbox_message_thread->start_thread();
  ts.receive_mbox_message_thread->join();
}