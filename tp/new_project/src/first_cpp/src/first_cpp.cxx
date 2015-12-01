// A simple program that computes the square root of a number

#include "BotNode.h"
#include "IBotMsgInterface.h"

#include "TestMsgCpp.h"
//#include "TestMsg.h"
#include "ServiceTestReq.h"
#include "ServiceTestResp.h"

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
  double dval;
  std::string bval_str;
  bool bval;
  
  TesMsg(matchable_ptr message_elements) {   
    message_elements->match(make_e_tuple(e_string(&text), float_(&dval), atom(&bval_str)));
    bval = boost::lexical_cast<bool>(bval_str);
    cout<<"TesMsg text: " + text + " double: " + boost::lexical_cast<std::string>(dval) + " bool: " + bval_str<<"\n\r";
    if(bval) {
      cout<<"This is true"<<"\n\r";
    }
    else {
      cout<<"This is false"<<"\n\r";
    }
  }
  
  TesMsg() {
    text = "empty string!";
    dval = 7.1;
    bval = true;
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
    atom(currentNode), atom(topicName), make_e_tuple(e_string("from test message atom!"), float_(dval), atom(boost::lexical_cast<std::string>(bval)))
  ));
  }
  
  
  virtual void send_service_response(mailbox_ptr mbox, std::string service_core_node,  
    std::string core_node_name, std::string response_service_message, std::string service_method_name, 
    std::string client_mail_box_name, std::string client_node_full_name, std::string client_method_name_callback, matchable_ptr request_message_from_client) const {
      
    e_tuple<boost::fusion::tuple<atom> > test_tuple = make_e_tuple(atom("test atom from new tuple!"));
      
    mbox->send(service_core_node, core_node_name, make_e_tuple(atom(response_service_message), e_string(service_method_name), atom(client_mail_box_name), 
	      atom(client_node_full_name), e_string(client_method_name_callback), test_tuple, 
	      make_e_tuple(e_string("from test message atom SERVICE!"))
							      ));
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
    void cm2(TesMsg msg) { 
      
      log_message("CM2 " + msg.text);
      cout<<"CM2: " + msg.text<<"\n\r"; 
      
    };
    
    ServiceTestResp service_method(ServiceTestReq req) { 
      std::cout<<"get request from client: " + req.strParamReq<<"\n\r";
      ServiceTestResp resp;
      resp.strParamResp = "This is responce from service cpp";
      return resp;
    };
    
    void client_method(ServiceTestReq req, ServiceTestResp resp) {
      std::cout<<"get serponse from service req: " + req.strParamReq<<"\n\r";
      std::cout<<"get serponse from service resp: " + resp.strParamResp<<"\n\r";
    }
    
    
    void go() {
     subscribe_to_topic<TesMsg>("testTopic", boost::bind( &TestClass::cm, this, _1 ));
     subscribe_to_topic<TesMsg>("testTopic", boost::bind( &TestClass::cm2, this, _1 ));
     
     register_service_server<ServiceTestReq, ServiceTestResp>("new_cpp_service", boost::bind( &TestClass::service_method, this, _1 ));
     register_service_client<ServiceTestReq, ServiceTestResp>("new_cpp_service", boost::bind( &TestClass::client_method, this, _1, _2 ));
     
     
     
     boost::scoped_ptr<TesMsg> t(new TesMsg());
     //TesMsg* t = new TesMsg();
     
     publish_message<TesMsg>("testTopic", t);
     
     boost::scoped_ptr<TestMsgCpp> tUI(new TestMsgCpp());
     tUI->strParam = "Message from cpp...";
     tUI->longParam = 777;
     send_message_to_ui<TestMsgCpp>(tUI, "TestMsg");
     
     boost::scoped_ptr<TestMsgCpp> cpp(new TestMsgCpp());
     cpp->longParam = 255;
     cpp->strParam = "hello from my test message!";
     
     publish_message<TestMsgCpp>("test2", cpp);
     
     
     
     ServiceTestReq req_service;
     req_service.strParamReq = "String from cpp client!";
     async_service_request<ServiceTestReq>("new_cpp_service", req_service);
     
     //delete t;
    }
    
    void action() {
      go();
    }
};


int main(int argc, char* argv[]) {
  TestClass ts(argc, argv);
  //ts.child_object = &ts;
  ts.start_node(&ts);
}