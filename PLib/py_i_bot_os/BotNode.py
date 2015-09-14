import sys

from abc import abstractmethod
import types

from py_interface import erl_node
from py_interface import erl_opts
from py_interface import erl_term

from CollectionSubscribe import CollectionSubscribe
from CollectionServiceServer import CollectionServiceServer
from CollectionServiceClient import CollectionServiceClient


# BotNode class for create iBotOS node on python language
class BotNode:
    # class constructor
    def __init__(self, args):  # class constructor

        self.otpNodeName = args[0]  # init node name
        self.currentServerName = args[1]  # init current server name
        self.coreNodeName = args[2]  # init core node name
        self.otpMboxNameAsync = args[0] + "_MBoxAsync"  # init asynchronous mail box name
        self.otpMboxName = args[0] + "_MBox"  # init mail box name
        self.connectorCodeNode = args[3]  # init connector node name
        self.publisherCoreNode = args[4]  # init publisher node name
        self.serviceCoreNode = args[5]  # init service node name
        self.uiInteractionNode = args[6] # init ui interaction node name
        self.coreCookie = args[7]  # init core node cookie

        self.otpNode = self.create_node()  # create node
        self.otpNode.Publish()

        self.otpMboxAsync = self.create_m_box(self.otpMboxNameAsync)  # create async system mail box
        self.otpMbox = self.create_m_box(self.otpMboxName)  # create synchronous mail box

        self.subscribeDic = {}  # subscribe callback methods collection
        self.asyncServiceClientDic = {}  # async client services collection
        self.asyncServiceServerDic = {}  # aync server services collection
        self.coreIsActive = True  # operation in action
        # self.coreIsActiveLocker = object # operation in action locker

        self.isMonitor = False

        # System message receive functions
        self.receiveSystemMessageFunctions = {
            "start": self.run_node_action_method,  # Run Action method
            "subscribe": self.subscribe_message_receive,  # Invoke subscribe callback method
            "call_service_method": self.call_service_method,  # Invoke service method
            "call_client_service_callback_method": self.call_client_service_callback_method,
            "system": self.system_message_request,
        }

        print "BotNode constructor is complete..."

    @abstractmethod
    def action(self):
        """
        override Action method
        """

    # === create node elements methods start ===

    # create node method
    def create_node(self):
        return erl_node.ErlNode(self.otpNodeName, erl_opts.ErlNodeOpts(cookie="jv"))

    # create mail box
    def create_m_box(self, otp_m_box_name):
        m_box = self.otpNode.CreateMBox(self.receive_m_box_message)
        m_box.RegisterName(otp_m_box_name)
        return m_box

    def get_me_start_signal(self):
        obj0 = erl_term.ErlAtom("get_me_start_signal")
        obj1 = erl_term.ErlAtom(self.otpMboxName)
        obj2 = erl_term.ErlAtom(self.otpNodeName + "@" + self.currentServerName)

        self.otpMboxAsync.Send((self.connectorCodeNode, self.coreNodeName),
                               (obj0, obj1, obj2))
        print "send message"

    # === create node elements methods end ===

    # def publishMessage(self):
    # print "Send..."
    # self.otpMbox.Send(("ibot_nodes_srv_topic", "core@alex-K55A"),
    # ("broadcast",
    # "MBoxName",
    # "NodeServerName",
    # "TopicName",
    # "Message"))
    #    print "Send2..."

    # def setMethod(self, method):
    #    self.em = method

    # def execMethod(self):
    #    self.em()

    # ====== System message operations Start ======

    # Get system message from core
    def receive_m_box_message(self, msg):
        print "Incoming msg=%s" % repr(msg)
        if isinstance(msg, types.TupleType):
            msg_type = str(msg[0])
            if msg_type in self.receiveSystemMessageFunctions:
                self.receiveSystemMessageFunctions[msg_type](msg)
            else:
                print "Message %s type not found ...", msg_type

    # Start node Action method
    def run_node_action_method(self, msg):
        self.action()

    # Invoke subscribe callback method
    def subscribe_message_receive(self, msg):
        topic_name = str(msg[1])  # get topic name
        subscribe_message = msg[2]  # get topic message

        call_back = self.subscribeDic[topic_name]

        if call_back is not None:
            call_back_method_args = call_back.getMethodMessageType()(subscribe_message)
            call_back.getMethodCallBack()(call_back_method_args)

    # Invoke service method
    def call_service_method(self, msg):
        service_method_name = str(msg[1])
        client_mail_box_name = msg[2]  # ErlAtom
        client_node_full_name = msg[3]  # ErlAtom
        client_method_name_callback = msg[4]  # ErlString
        request_message_from_client = msg[5]  # ErlTuple

        service_method = self.asyncServiceServerDic[service_method_name]

        if service_method is not None:
            request = service_method.getServiceRequest()(request_message_from_client)
            response = service_method.getServiceCallback()(request)

            obj0 = erl_term.ErlAtom("response_service_message")
            obj1 = msg[1]
            obj2 = client_mail_box_name
            obj3 = client_node_full_name
            obj4 = client_method_name_callback
            obj5 = request_message_from_client
            obj6 = response.getMsg()

            self.otpMboxAsync.Send((self.serviceCoreNode, self.coreNodeName),
                                   (obj0, obj1, obj2, obj3, obj4, obj5, obj6))

    def call_client_service_callback_method(self, msg):
        invoked_service_methodName = str(msg[1])
        client_method_name = str(msg[2])
        request_message = msg[3]
        response_message = msg[4]

        client_method = self.asyncServiceClientDic[client_method_name]

        if client_method is not None:
            request = client_method.getServiceRequest()(request_message)
            response = client_method.getServiceResponse()(response_message)

            client_method.getClientMethodCallbackName()(request, response)

    def system_message_request(self, msg):
        system_action = str(msg[1])  # String

        if system_action == "exit":
            self.coreIsActive = False
            self.monitor_stop()
            sys.exit(0)

        elif system_action == "monitor":
            monitor_action = str(msg[2])

            if monitor_action == "monitorIsStart":
                self.isMonitor = True
            else:
                self.isMonitor = False

    # ====== System message operations End ======

    # ====== Publish/Subscribe to topic method Start ======
    # Subscribe node to topic
    def subscribe_to_topic(self, topic_name, callback_method, callback_method_message_type):
        # create registration subscriber method info
        obj0 = erl_term.ErlAtom("reg_subscr")
        obj1 = erl_term.ErlAtom(self.otpMboxNameAsync)
        obj2 = erl_term.ErlAtom(self.otpNodeName + "@" + self.currentServerName)
        obj3 = erl_term.ErlAtom(topic_name)

        # send subscribe registration info to core
        self.otpMboxAsync.Send((self.publisherCoreNode, self.coreNodeName),
                               (obj0, obj1, obj2, obj3))

        # add subscribe method info to local dictionary
        self.subscribeDic[topic_name] = CollectionSubscribe(callback_method, callback_method_message_type)

    # Publish message to subscribe nodes
    def publish_message(self, topic_name, msg):
        obj0 = erl_term.ErlAtom("broadcast")
        obj1 = erl_term.ErlAtom(self.otpMboxNameAsync)
        obj2 = erl_term.ErlAtom(self.otpNodeName + "@" + self.currentServerName)
        obj3 = erl_term.ErlAtom(topic_name)
        obj4 = msg.getMsg()
        self.otpMboxAsync.Send((self.publisherCoreNode, self.coreNodeName),
                               (obj0, obj1, obj2, obj3, obj4))

    # Send message to UI
    def send_message_to_ui(self, msg):
        obj0 = erl_term.ErlAtom("send_data_to_ui")
        obj1 = erl_term.ErlAtom(self.otpNodeName)
        obj2 = msg.getMsg()
        self.otpMboxAsync.Send((self.uiInteractionNode, self.coreNodeName),
                               (obj0, obj1, obj2))

    # ====== Publish/Subscribe to topic method End ======

    # ====== Other node in project Start ======

    def start_project_node(self, node_name):
        obj0 = erl_term.ErlAtom("start_node_from_node")
        obj1 = erl_term.ErlAtom(node_name)
        self.otpMboxAsync.Send((self.connectorCodeNode, self.coreNodeName),
                               (obj0, obj1))

    def stop_project_node(self, node_name):
        obj0 = erl_term.ErlAtom("stop_node_from_node")
        obj1 = erl_term.ErlAtom(node_name)
        self.otpMboxAsync.Send((self.connectorCodeNode, self.coreNodeName),
                               (obj0, obj1))

    # ====== Other node in project End ======


    # ====== Services methods Start ======
    def register_service_client(self, server_service_method_name,
                                client_service_method_name, client_service_method,
                                service_request, service_response):

        obj0 = erl_term.ErlAtom("reg_async_client_service_callback")
        obj1 = erl_term.ErlAtom(self.otpMboxNameAsync)
        obj2 = erl_term.ErlAtom(self.otpNodeName + "@" + self.currentServerName)
        obj3 = erl_term.ErlAtom(server_service_method_name)

        self.otpMboxAsync.Send((self.serviceCoreNode, self.coreNodeName),
                               (obj0, obj1, obj2, obj3))

        if client_service_method is not None:
            service_client = CollectionServiceClient(server_service_method_name, client_service_method_name,
                                                     service_request, service_response, client_service_method)

            self.asyncServiceClientDic[server_service_method_name] = service_client


    # Registration service server
    def register_service_server(self, service_method, service_method_name, request_type, response_type):
        obj0 = erl_term.ErlAtom("reg_async_server_service_callback")
        obj1 = erl_term.ErlAtom(self.otpMboxNameAsync)
        obj2 = erl_term.ErlAtom(self.otpNodeName + "@" + self.currentServerName)
        obj3 = erl_term.ErlString(service_method_name)
        self.otpMboxAsync.Send((self.serviceCoreNode, self.coreNodeName),
                               (obj0, obj1, obj2, obj3))

        if service_method is not None:
            service_server = CollectionServiceServer(service_method_name, request_type, response_type, service_method)
            self.asyncServiceServerDic[service_method_name] = service_server

    # Asynchronous service call
    def async_service_request(self, service_method_name, req):
        if service_method_name in self.asyncServiceClientDic:
            service_client = self.asyncServiceClientDic[service_method_name]

            obj0 = erl_term.ErlAtom("request_service_message")
            obj1 = erl_term.ErlAtom(self.otpMboxNameAsync)
            obj2 = erl_term.ErlAtom(self.otpNodeName + "@" + self.currentServerName)
            obj3 = erl_term.ErlString(service_client.getClientMethodCallbackName())
            obj4 = erl_term.ErlString(service_method_name)
            obj5 = req.getMsg()

            self.otpMboxAsync.Send((self.serviceCoreNode, self.coreNodeName),
                                   (obj0, obj1, obj2, obj3, obj4, obj5))
        else:
            print "def asyncServiceRequest(self, serviceMethodName, req): client service not found..."

    # ====== Services methods Start ======

    # ====== Monitor methods Start ======
    # Start node monitor
    def monitor_start(self):
        if not self.isMonitor:
            obj0 = erl_term.ErlAtom("start_monitor")
            obj1 = erl_term.ErlString(self.otpNodeName)
            obj2 = erl_term.ErlAtom(self.otpNodeName)
            obj3 = erl_term.ErlAtom(self.currentServerName)
            obj4 = erl_term.ErlAtom(self.otpNodeName + "@" + self.currentServerName)

            self.otpMboxAsync.Send((self.connectorCodeNode, self.coreNodeName),
                                   (obj0, obj1, obj2, obj3, obj4))

            self.isMonitor = True

    # Stop node monitor
    def monitor_stop(self):
        if self.isMonitor:
            obj0 = erl_term.ErlAtom("stop_monitor")
            obj1 = erl_term.ErlString(self.otpNodeName)

            self.otpMboxAsync.Send((self.connectorCodeNode, self.coreNodeName), (obj0, obj1))

        self.isMonitor = False

        # ====== Monitor methods End ======