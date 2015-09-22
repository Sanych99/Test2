import sys
from py_i_bot_os.BotNode import BotNode
from TestMsg import TestMsg
from py_interface import erl_eventhandler, erl_common
import time
#erlang:send({'BLA_BLA_BLA_CLIENT_MBox', 'BLA_BLA_BLA_CLIENT@alex-N550JK'},{"start"}).
class TestPythonFromIdea(BotNode):

    def __init__(self, args):
        argstest = ["BLA_BLA_BLA_CLIENT", "alex-N550JK", "core1@alex-N550JK", "ibot_nodes_srv_connector", "ibot_nodes_srv_topic", "ibot_nodes_srv_service", "jv"]
        BotNode.__init__(self, args[1:])
        #BotNode.__init__(self, argstest)
        print "from Test node: " + self.otpNodeName

    def StartNode(self):
        #time.sleep(5)
        evhand = erl_eventhandler.GetEventHandler()

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
        #self.otpMbox.Send(("ibot_nodes_srv_topic", "core@alex-K55A"),
        #                  ("broadcast",
        #                   "MBoxName",
        #                   "NodeServerName",
        #                   "TopicName",
        #                   "Message"))
        #print "Looping...2"
        self.monitor_start();
        self.subscribe_to_topic("testTopic", self.cbmMethod, TestMsg)
        print "subscribe to topic"
        #evhand = erl_eventhandler.GetEventHandler()
        #evhand.Loop()

    def cbmMethod(self, msg):
        print "receive message  from new msg: ", msg.get_strParam()
        print "receive message  from new msg LONG value: ", msg.get_longParam()
        print "receive message  from new msg Bool value: ", msg.get_boolParam()
        print "receive message  from new msg FLOAT value: ", msg.get_floatParam()
        tm = TestMsg()
        tm.set_strParam(msg.get_strParam())
        tm.set_longParam(long(15))
        tm.set_floatParam(float(2.55))
        tm.set_boolParam(bool(False))
        self.publish_message("test_topic_from_py", tm)

def testMethod():
    print "This is test method..."

if __name__ == "__main__":
    bot= TestPythonFromIdea(sys.argv)
    #print "args: ", sys.argv[1:]
    #bot.setMethod(testMethod)
    #bot.execMethod()
    bot.StartNode()
    #t1 = threading.Thread(target=bot.StartNode)
    #t1.start()
    #bot.Action()
