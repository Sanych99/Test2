from abc import abstractmethod
import types

from py_interface import erl_node
from py_interface import erl_opts
from py_interface import erl_term

from CollectionSubscribe import CollectionSubscribe
from CollectionServiceServer import CollectionServiceServer

import time


# BotNode class for create iBotOS node on python language
class BotNode:
    # class constructor
    def __init__(self, args):  # class constructor

        self.otpNodeName = args[0]  # init node name
        self.currentServerName = args[1]  # init current server name
        self.coreNodeName = args[2]  # init core node name
        self.otpMboxNameAsync = args[0] + "_MBoxAsync"  # init asynchronous mail box name
        self.otpMboxName = args[0] + "_MBox"  # init mail box name
        self.connectorCodeNode = args[3]
        self.publisherCoreNode = args[4]  # init publisher node name
        self.serviceCoreNode = args[5]  # init service node name
        self.coreCookie = args[6]  # init core node cookie

        self.otpNode = self.createNode()  # create node
        self.otpNode.Publish()

        self.otpMboxAsync = self.createMbox(self.otpMboxNameAsync)  # create async system mail box
        self.otpMbox = self.createMbox(self.otpMboxName)  # create synchronous mail box

        self.subscribeDic = {}  # subscribe callback methods collection
        self.asyncServiceClientDic = {}  # async client services collection
        self.asyncServiceServerDic = {}  # aync server services collection
        self.coreIsActive = True  # operation in action
        ##self.coreIsActiveLocker = object # operation in action locker

        # System message recieve functions
        self.resieveSystemMessageFunctions = {
            "start": self.runNodeActionMethod  # Run Action method
        }

        print "BotNode constructor is complete..."

    @abstractmethod
    def Action(self):
        """
        override Action method
        """

    # === create node elements methods start ===

    # create node method
    def createNode(self):
        return erl_node.ErlNode(self.otpNodeName, erl_opts.ErlNodeOpts(cookie="jv"))

    # create mail box
    def createMbox(self, otpMboxName):
        mbox = self.otpNode.CreateMBox(self.receiveMBoxMessage)
        mbox.RegisterName(otpMboxName)
        return mbox

    # === create node elements methods end ===

    #def publishMessage(self):
    #    print "Send..."
    #    self.otpMbox.Send(("ibot_nodes_srv_topic", "core@alex-K55A"),
    #                      ("broadcast",
    #                       "MBoxName",
    #                       "NodeServerName",
    #                       "TopicName",
    #                       "Message"))
    #    print "Send2..."

    #def setMethod(self, method):
    #    self.em = method

    #def execMethod(self):
    #    self.em()

    # ====== System message operations Start ======

    # Get system message from core
    def receiveMBoxMessage(self, msg):
        print "Incoming msg=%s" % `msg`
        if type(msg) == types.TupleType:
            msgType = str(msg[0])
            if msgType in self.resieveSystemMessageFunctions:
                self.resieveSystemMessageFunctions[msgType]()
            else:
                print "Message %s type not found ...", msgType

    # Start node Action method
    def runNodeActionMethod(self):
        self.Action()

    # ====== System message operations End ======

    # ====== Publish/Subscribe to topic method Start ======
    # Subscribe node to topic
    def subscribeToTopic(self, topicName, callbackMethod, callbackMethodMessageType):
        # create registration subscriber method info
        obj0 = erl_term.ErlAtom("reg_subscr")
        obj1 = erl_term.ErlAtom(self.otpMboxNameAsync)
        obj2 = erl_term.ErlAtom(self.otpNodeName + "@" + self.currentServerName)
        obj3 = erl_term.ErlAtom(topicName)

        # send subscribe registration info to core
        self.otpMboxAsync.Send((self.publisherCoreNode, self.coreNodeName),
                               (obj0, obj1, obj2, obj3))

        # add subscribe method info to local dictionary
        self.subscribeDic[topicName] = CollectionSubscribe(callbackMethod, callbackMethodMessageType)

    # Publish message to subscribe nodes
    def publishMessage(self, topicName, msg):
        obj0 = erl_term.ErlAtom("broadcast")
        obj1 = erl_term.ErlAtom(self.otpMboxNameAsync)
        obj2 = erl_term.ErlAtom(self.otpNodeName + "@" + self.currentServerName)
        obj3 = erl_term.ErlAtom(topicName)
        obj4 = msg.getMsg()
        self.otpMboxAsync.Send((self.publisherCoreNode, self.coreNodeName),
                               (obj0, obj1, obj2, obj3, obj4))

    # ====== Publish/Subscribe to topic method End ======

    # ====== Services methods Start ======
    # Registration service server
    def registerServiceServer(self, serviceMethod, serviceMethodName, requestType, responseType):
        obj0 = erl_term.ErlAtom("reg_async_server_service_callback")
        obj1 = erl_term.ErlAtom(self.otpMboxNameAsync)
        obj2 = erl_term.ErlAtom(self.otpNodeName + "@" + self.currentServerName)
        obj3 = erl_term.ErlString(serviceMethodName)
        self.otpMboxAsync.Send((self.serviceCoreNode, self.coreNodeName),
                               (obj0, obj1, obj2, obj3))

        if serviceMethod is not None:
            serviceServer = CollectionServiceServer(serviceMethodName, requestType, responseType, serviceMethod)
            self.asyncServiceServerDic[serviceMethodName] = serviceServer

    # ====== Services methods Start ======
