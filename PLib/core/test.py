import sys
import pyerl
from BotNode import BotNode
from py_interface import erl_eventhandler, erl_common
import time

class TestNode(BotNode):

    def __init__(self, args):
        argstest = ["BLA_BLA_BLA789", "alex-K55A", "core@alex-K55A", "ibot_nodes_srv_connector", "ibot_nodes_srv_topic", "ibot_nodes_srv_service", "jv"]
        BotNode.__init__(self, argstest)
        #print "from Test node: " + args[1]

    def StartNode(self):
        evhand = erl_eventhandler.GetEventHandler()

        # Schedule to run the RPC after we've started looping
        evhand.AddTimerEvent(0.1, erl_common.Callback(self.Action()))

        print "Looping..."
        evhand.Loop()
        sys.exit(0)

    def Action(self):
        i=1000
        #while(i>=0):
        #    i -= 1
        #    time.sleep(1)
        #    self.publishMessage()
            #print "Action Method" + str(self.otpNode._isServerPublished)
        #self.publishMessage()

        #i=100000
        #while(i>=0):
        #    i -= 1
        #    print "Action Method"

        self.publishMessage()
        self.publishMessage()
        #while True: print "123"
        print "Action Method"
        print "Looping..."
        #evhand = erl_eventhandler.GetEventHandler()
        #evhand.Loop()

def testMethod():
    print "This is test method..."

if __name__ == "__main__":
    bot= TestNode(sys.argv)
    bot.setMethod(testMethod)
    bot.execMethod()
    bot.StartNode()

