from abc import abstractmethod

from py_interface import erl_node
from py_interface import erl_opts


# BotNode class for create iBotOS node on python language
class BotNode:

    # class constructor
    def __init__(self, args):  # class constructor

        self.otpNodeName = args[0]                      # init node name
        self.currentServerName = args[1]                # init current server name
        self.coreNodeName = args[2]                     # init core node name
        self.otpMboxNameAsync = args[0] + "_MBoxAsync"  # init asynchronous mail box name
        self.otpMboxName = args[0] + "_MBox"            # init mail box name
        self.publisherCoreNode = args[3]                # init publisher node name
        self.serviceCoreNode = args[4]                  # init service node name
        self.coreCookie = args[5]                       # init core node cookie

        self.otpNode = self.createNode() # create node
        self.otpNode.Publish()
        self.otpMboxAsync = self.createMbox(self.otpMboxNameAsync) # create async system mail box
        self.otpMbox = self.createMbox(self.otpMboxName) # create synchronous mail box

        self.subscribeDic = {} # subscribe callback methods collection
        self.asyncServiceClientDic = {} # async client services collection
        self.asyncServiceServerDic = {} # aync server services collection
        self.coreIsActive = True # operation in action
        ##self.coreIsActiveLocker = object # operation in action locker
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
        mbox = self.otpNode.CreateMBox()
        mbox.RegisterName(otpMboxName)
        return mbox

    # === create node elements methods end ===

    def publishMessage(self):
        print "Send..."
        self.otpMbox.Send(("ibot_nodes_srv_topic", "core@alex-K55A"),
                          ("broadcast",
                           "MBoxName",
                           "NodeServerName",
                           "TopicName",
                           "Message"))
        print "Send2..."

    def setMethod(self, method):
        self.em = method

    def execMethod(self):
        self.em()