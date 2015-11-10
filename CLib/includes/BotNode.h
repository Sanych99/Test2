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
#include "CollectionServiceServer.h"
#include "CollectionServiceClient.h"

using namespace tinch_pp;
using namespace tinch_pp::erl;
using namespace boost::assign;


using namespace std;

namespace BotNodeNameSpace {

  template<class NodeClass>
  class BotNode: boost::noncopyable {
    
  private:
    void log_message(std::string message_type, std::string message_text);
    
    public:
      //e_tuple logSenderName;
      string current_server_name; /** Current server name machine name */
      node_ptr otp_node; /** Java Otp node */
      string otp_node_name; /** Java Otp node name */
      mailbox_ptr otp_mbox_async; /** Otp node mail box */    
      string otp_mbox_name_async; /** Otp node mail box name */
      mailbox_ptr otp_mbox; /** sync mail box */
      string otp_mbox_name; /** sync mail box name */
      string core_node_name; /** Server name core@machine_name */
      string publisher_core_node; /** Core message publisher module */
      string service_core_node; /** Core services module */
      string connector_code_node; /** Core node connector module */
      string ui_interaction_node; /** Core user interaction module */
      string logger_interaction_node; /** Core event logger module */    
      string core_cookie; /** Core node cookies */
      volatile bool core_is_active; /** ядро запущено */
      bool is_monitor; /** узел находятся под мониторингом*/
      int epmd_port; /** порт для соединения с ядром */
      std::map < std::string, BaseCollectionSubscribe* > subscribe_dic; /** список подписанных методов на топики */
      std::map < std::string, BaseCollectionServiceServer* > async_service_server_dic;
      std::map < std::string, BaseCollectionServiceClient* > async_service_client_dic;
      
      NodeClass* child_object; /** ссылка на объек узла */
      
      boost::thread* receive_mbox_message_thread; /** поток обработка системных событий */
      void receive_mbox_message_method(mailbox_ptr async_mbox); /** метод обработки системных событий */
      template<typename M> void subscribe_to_topic(std::string topic_name, void (NodeClass::*callback_function)(M));
      template<typename M> void publish_message(std::string topic_name, boost::scoped_ptr<M>& msg);
      
      template<typename ReqType, typename RespType> 
      void register_service_server(std::string service_name, RespType (NodeClass::*callback)(ReqType));
      template<typename ReqType, typename RespType> 
      void register_service_client(std::string service_name, void (NodeClass::*callback)(ReqType, RespType));
      
      template<typename ReqType>
      void async_service_request(std::string service_name, ReqType req);
    
      void monitor_start();
      void monitor_stop();
      
      void start_project_node(std::string node_name);
      void stop_project_node(std::string node_name);
      
      void log_message(std::string message_text);
      void log_warning(std::string message_text);
      void log_error(std::string message_text);
      
      bool ok();
      
      void start_node(NodeClass* ts);
    
      //====== Константы / Constants Start ======

      static const string LOG_TYPE_MESSAGE;
      static const string LOG_TYPE_WARNING;
      static const string LOG_TYPE_ERROR;
      
      //====== Константы / Constants End ======
      
      BotNode(int argc, char *argv[]);
      ~BotNode();   
  };

  
  /*message log type*/
  template<class NodeClass> const std::string BotNode<NodeClass>::LOG_TYPE_MESSAGE("Message");
  /*warning log type*/
  template<class NodeClass> const std::string BotNode<NodeClass>::LOG_TYPE_WARNING("Warning");
  /*error log type*/
  template<class NodeClass> const std::string BotNode<NodeClass>::LOG_TYPE_ERROR("Error");


  template<typename NodeClass>
  BotNode<NodeClass>::BotNode(int argc, char *argv[]) :
    otp_node_name(std::string(argv[1])), // init node name
    current_server_name(std::string(argv[2])), // init current server name
    core_node_name(std::string(argv[3])), // init core node name
    otp_mbox_name_async(std::string(argv[1]) + "_MBoxAsync"), // init asynchronous mail box name
    otp_mbox_name(std::string(argv[1]) + "_MBox"), // init mail box name
    connector_code_node(std::string(argv[4])),  // init connector node name
    publisher_core_node(std::string(argv[5])), // init publisher node name
    service_core_node(std::string(argv[6])), // init service node name
    ui_interaction_node(std::string(argv[7])), // init ui interaction node name
    logger_interaction_node(std::string(argv[8])), // init message logger node name
    core_cookie(std::string(argv[9])), // init core node cookie
    core_is_active(true), //ядро запущено
    is_monitor(false), //при создании ябра мониторинг за узлом равен false
    epmd_port(std::atoi(argv[10]))
    { 
      otp_node = node::create(otp_node_name + "@" + current_server_name, core_cookie);
      otp_mbox = otp_node->create_mailbox(otp_mbox_name);
      otp_mbox_async = otp_node->create_mailbox(otp_mbox_name_async);

      receive_mbox_message_thread = new boost::thread(&BotNode::receive_mbox_message_method, this, otp_mbox_async);

      otp_node->publish_port(epmd_port);
      
      /*start node log message*/
      log_message("run cpp node with name: " + otp_node_name);
    };

  template<typename NodeClass>
  BotNode<NodeClass>::~BotNode() {
    /*stop node log message*/
    log_message("desctructor node with name: " + otp_node_name);
  };
  
  
  template<typename NodeClass>
  void BotNode<NodeClass>::start_node(NodeClass* ts)
  {
    child_object = ts;
    receive_mbox_message_thread->start_thread();
    child_object->action();
    receive_mbox_message_thread->join();
  }

    
    
  /**
  * Подписка на пубикацию сообщений 
  */
  template<typename NodeClass>
  template<typename M>     
  void BotNode<NodeClass>::subscribe_to_topic(std::string topic_name, void (NodeClass::*callback_function)(M)) {
    otp_mbox_async->send(publisher_core_node, core_node_name, 
      make_e_tuple(atom("reg_subscr"), atom(otp_mbox_name_async), 
      atom(otp_node_name + "@" + current_server_name), atom(topic_name)
    ));

    subscribe_dic[topic_name] = new CollectionSubscribe<NodeClass, M>(callback_function, topic_name, child_object);
    
    /*subscribe to topic log message*/
    log_message("node with name: " + otp_node_name + " subscribe to topic with name: " + topic_name);
    
    //CollectionSubscribe<NodeClass, M>* collection = new CollectionSubscribe<NodeClass, M>(callbackFunction, topicName, childObject);
    /*map<std::string, BaseCollectionSubscribe* >::iterator it = subscribeDic.find(topicName);*/

    //BaseCollectionSubscribe* topicSubscribersCollection = collection;
    //subscribeDic[topicName] = an isMonitortopicSubscribersCollection;

    /**subscribeDic.at(topicName)->execute();*/
    /**BaseCollectionSubscribe* tryexec = subscribeDic.at(topicName);
    tryexec->execute();*/
  };


  /**
  * Публикация сообщения в топика
  */
  template<typename NodeClass>
  template<typename M>
  void BotNode<NodeClass>::publish_message(std::string topic_name, boost::scoped_ptr<M>& msg)
  {
    msg->send_mesasge(otp_mbox_async, publisher_core_node, core_node_name, 
		      otp_node_name + "@" + current_server_name, otp_mbox_name_async, topic_name);
    
    /*publish message to topic log message*/
    log_message("node with name: " + otp_node_name + " publish to topic with name: " + topic_name);
    /*
    otpMboxAsync->send(publisherCoreNode, coreNodeName, 
      make_e_tuple(atom("broadcast"), atom(otpMboxNameAsync), 
      atom(otpNodeName + "@" + currentServerName), atom(topicName)
    ));*/
  }



  /**
  * Обработка сообщений ядра
  */
  template<typename NodeClass>
  void BotNode<NodeClass>::receive_mbox_message_method(mailbox_ptr async_mbox)
  {
    enum ReceivedMessageType { 
      subscribe, 
      call_service_method, 
      call_client_service_callback_method,
      system_exit,
      no_action
    };
    
    ReceivedMessageType msgTypeEnum;
    
    while(core_is_active) {
      matchable_ptr msg = async_mbox->receive();
      
      std::string test;
      msg->match(make_e_tuple(atom(&test), erl::any(), erl::any()));
      
      if (msg->match(make_e_tuple(atom("subscribe"), erl::any(), erl::any()))) {
	msgTypeEnum = subscribe;
	/*get subscribe system message log message*/
	log_message("node with name: " + otp_node_name + " recieved subscribe system message");
      }
      else if(msg->match(make_e_tuple(atom("call_service_method"), erl::any(), erl::any(), erl::any(), erl::any(), erl::any()))) {
	msgTypeEnum = call_service_method;
	/*get call_service_method system message log message*/
	log_message("node with name: " + otp_node_name + " recieved call_service_method system message");
      }
      else if(msg->match(make_e_tuple(atom("call_client_service_callback_method"), erl::any(), erl::any(), erl::any(), erl::any()))) {
	msgTypeEnum = call_client_service_callback_method;
	/*get call_client_service_callback_method system message log message*/
	log_message("node with name: " + otp_node_name + " recieved call_client_service_callback_method system message");
      }
      else if(msg->match(make_e_tuple(atom("system"), atom("exit")))) {
	msgTypeEnum = system_exit;
	/*get system message log message*/
	log_message("node with name: " + otp_node_name + " recieved system message");
      }
      else {
	msgTypeEnum = no_action;
	/*get no_action message log message*/
	log_message("node with name: " + otp_node_name + " recieved no_action message");
      }
      

      switch(msgTypeEnum) {
	//получение сообения от ядра на подписку
	case subscribe: {
	  std::string topicName; //наименование топика
	  matchable_ptr message_elements; //элементы сообщения
	  msg->match(make_e_tuple(erl::any(), atom(&topicName), any(&message_elements))); //выбираем наименование топика и элементы сообщения
	  //вызываем метод подписанный на сообщения
	  subscribe_dic.at(topicName)->execute(message_elements);
	  /*subscribe topic message log message*/
	  log_message("node with name: " + otp_node_name + " execute method for subscribed topic: " + topicName);
	}
	  break;

	case no_action: {
	  /*no action method*/
	}
	  break;

	case call_service_method: {
	  std::string service_method_name;
	  std::string client_mail_box_name;
	  std::string client_node_full_name;
	  std::string client_method_name_callback;
	  matchable_ptr request_message_from_client;
	  
	  msg->match(make_e_tuple(any(), e_string(&service_method_name), atom(&client_mail_box_name), 
				  atom(&client_node_full_name), e_string(&client_method_name_callback), 
				  any(&request_message_from_client)));
	  
	  /*
	  make_e_tuple(atom("response_service_message"), e_string(service_method_name), atom(client_mail_box_name), 
	      atom(client_node_full_name), e_string(client_method_name_callback), any(request_message_from_client), */
	  
	  async_service_server_dic.at(service_method_name)->execute(async_mbox, service_core_node, core_node_name, 
	    "response_service_message", service_method_name, client_mail_box_name, client_node_full_name, client_method_name_callback, 
	    request_message_from_client);
	  
	  /*call_service_method log message*/
	  log_message("node with name: " + otp_node_name + " execute server service method: " + service_method_name);
	}
	break;

	case call_client_service_callback_method: {
	  std::string invoked_service_method_name;
	  std::string client_method_name;
	  matchable_ptr request_message;
	  matchable_ptr response_message;
	  
	  msg->match(make_e_tuple(any(), e_string(&invoked_service_method_name), e_string(&client_method_name), 
				  any(&request_message), any(&response_message)));
	  
	  async_service_client_dic.at(invoked_service_method_name)->execute(request_message, response_message);
	  
	  /*call_client_service_callback_method log message*/
	  log_message("node with name: " + otp_node_name + " execute client service method: " + client_method_name + " from server service method: " + invoked_service_method_name);
	}
	break;

	case system_exit: {
	  monitor_stop();
	  core_is_active = false;
	  /*exit from node log message*/
	  log_message("node with name: " + otp_node_name + " exit message recieved");
	}
	  break;
      }
    }
  };






  template<class NodeClass>
  bool BotNode<NodeClass>::ok()
  {
    return core_is_active;
  }

  /**
  * Запуск монитора
  */
  template<typename NodeClass>
  void BotNode<NodeClass>::monitor_start()
  {
    if (!is_monitor) {
      otp_mbox_async->send(connector_code_node, core_node_name, 
	make_e_tuple(atom("start_monitor"), e_string("otpNodeName"), 
	  atom(otp_node_name), atom(current_server_name), atom(otp_node_name + "@" + current_server_name))
	);
      
      is_monitor = true;
      
      /*start monitor log message*/
      log_message("node with name: " + otp_node_name + " start monitor");
    }
  }


  /**
  * Остановка монитора
  */
  template<typename NodeClass>
  void BotNode<NodeClass>::monitor_stop()
  {
    if (is_monitor) {
      otp_mbox_async->send(connector_code_node, core_node_name, 
	make_e_tuple(atom("stop_monitor"), e_string(otp_node_name))
      );
    }
    
    is_monitor = false;
    
    /*stop monitor log message*/
    log_message("node with name: " + otp_node_name + " stop monitor");
  }


  /**
  * Запуск узла
  */
  template<typename NodeClass>
  void BotNode<NodeClass>::start_project_node(string node_name)
  {
    otp_mbox_async->send(connector_code_node, core_node_name,
      make_e_tuple(atom("start_node_from_node"), e_string(node_name))
    );
    
    /*start project node log message*/
    log_message("node with name: " + otp_node_name + " start project node with name: " + node_name);
  }


  /**
  * Остановка узла
  */
  template<typename NodeClass>
  void BotNode<NodeClass>::stop_project_node(string node_name)
  {
    otp_mbox_async->send(connector_code_node, core_node_name,
      make_e_tuple(atom("stop_node_from_node"), e_string(node_name))
    );
    
    /*stop project node log message*/
    log_message("node with name: " + otp_node_name + " stop project node with name: " + node_name);
  }
  
  
  
  template<typename NodeClass>
  void BotNode<NodeClass>::log_message(string message_type, string message_text)
  {
    otp_mbox_async->send(logger_interaction_node, core_node_name, make_e_tuple(atom("node_logger_message"), 
      e_string(message_type), e_string(message_text), make_e_tuple(e_string(otp_node_name), e_string(core_node_name))
    ));
  }
  
  
  template<typename NodeClass>
  void BotNode<NodeClass>::log_message(string message_text)
  {
    log_message(LOG_TYPE_MESSAGE, message_text);
  }
  
  template<typename NodeClass>
  void BotNode<NodeClass>::log_warning(string message_text)
  {
    log_message(LOG_TYPE_WARNING, message_text);
  }
  
  template<typename NodeClass>
  void BotNode<NodeClass>::log_error(string message_text)
  {
    log_message(LOG_TYPE_ERROR, message_text);
  }
  
  
  
  template<typename NodeClass>
  template<typename ReqType, typename RespType>
  void BotNode<NodeClass>::register_service_server(string service_name, RespType (NodeClass::*callback)(ReqType))
  {
    async_service_server_dic[service_name] = new CollectionServiceServer<NodeClass, ReqType, RespType>(callback, child_object);
    
    otp_mbox_async->send(service_core_node, core_node_name, 
			 make_e_tuple(atom("reg_async_server_service_callback"), atom(otp_mbox_name_async), 
			 atom(otp_node_name + "@" + current_server_name), e_string(service_name))
    );
    
    /*registered server service log message*/
    log_message("node with name: " + otp_node_name + " registered server service with name: " + service_name);
  }
  
  
  template<typename NodeClass>
  template<typename ReqType, typename RespType>
  void BotNode<NodeClass>::register_service_client(string service_name, void (NodeClass::*callback)(ReqType, RespType))
  {
    async_service_client_dic[service_name] = new CollectionServiceClient<NodeClass, ReqType, RespType>(callback, child_object);
    
    otp_mbox_async->send(service_core_node, core_node_name, 
			 make_e_tuple(atom("reg_async_client_service_callback"), atom(otp_mbox_name_async), 
			 atom(otp_node_name + "@" + current_server_name), atom(service_name))
    );
    
    /*registered client service log message*/
    log_message("node with name: " + otp_node_name + " registered client service with name: " + service_name);
  }
  
 
  template<typename NodeClass>
  template<typename ReqType>
  void BotNode<NodeClass>::async_service_request(string service_name, ReqType req)
  {
    otp_mbox_async->send(service_core_node, core_node_name, 
			 make_e_tuple(atom("request_service_message"), atom(otp_mbox_name_async), 
			 atom(otp_node_name + "@" + current_server_name), e_string("cpp_client_empty_by_default"), e_string(service_name), req.get_tuple_message())
    );
    
    /*async service request log message*/
    log_message("node with name: " + otp_node_name + " async service request with name: " + service_name);
  }


}



#endif
