import sys
from BotNode import BotNode
from TestMsg import TestMsg
from py_interface import erl_eventhandler, erl_common
import time
#erlang:send({'BLA_BLA_BLA_CLIENT_MBox', 'BLA_BLA_BLA_CLIENT@alex-K55A'},{"start"}).
class TestNode(BotNode):

    def __init__(self, args):
        argstest = ["BLA_BLA_BLA_CLIENT1", "alex-K55A", "core@alex-K55A", "ibot_nodes_srv_connector", "ibot_nodes_srv_topic", "ibot_nodes_srv_service", "jv"]
        BotNode.__init__(self, argstest)
        #print "from Test node: " + args[1]

    def StartNode(self):
        #time.sleep(5)
        evhand = erl_eventhandler.GetEventHandler()

        self.otpMbox.Send(("ibot_nodes_srv_connector", "core@alex-K55A"),
                          ("broadcast",
                           "MBoxName",
                           "NodeServerName"))

        # Schedule to run the RPC after we've started looping
        #evhand.AddTimerEvent(5000, erl_common.Callback(self.Action()))

        print "Looping..."
        evhand.Loop()

    def action(self):
        #i=1000
        #while(i>=0):
        #    i -= 1
        #    time.sleep(5)
        #    self.publishMessage()
            #print "Action Method" + str(self.otpNode._isServerPublished)
        #self.publishMessage()

        #i=100000
        #while(i>=0):
        #    i -= 1
        #    print "Action Method"

        #self.publishMessage()

        #self.subscribeToTopic("testTopic", self.StartNode)

        #self.publishMessage()
        #while True: print "123"
        print "Action Method"
        #time.sleep(5)
        #self.publishMessage()
        self.otpMbox.Send(("ibot_nodes_srv_topic", "core@alex-K55A"),
                          ("broadcast",
                           "MBoxName",
                           "NodeServerName",
                           "TopicName",
                           "Message"))
        print "Looping...2"

        self.subscribe_to_topic("testTopic", self.cbmMethod, TestMsg)
        print "subscribe to topic"
        #evhand = erl_eventhandler.GetEventHandler()
        #evhand.Loop()

    def cbmMethod(self, msg):
        print "receive message  from new msg: ", msg.strParam

def testMethod():
    print "This is test method..."

if __name__ == "__main__":
    bot= TestNode(sys.argv)
    #bot.setMethod(testMethod)
    #bot.execMethod()
    bot.StartNode()
    #t1 = threading.Thread(target=bot.StartNode)
    #t1.start()
    #bot.Action()

