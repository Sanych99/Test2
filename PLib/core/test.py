import sys
from BotNode import BotNode

class TestNode(BotNode):

    def __init__(self, args):
        argstest = ["BLA_BLA_BLA23", "alex-K55A", "core@alex-K55A", "ibot_nodes_srv_connector", "ibot_nodes_srv_topic", "ibot_nodes_srv_service", "jv"]
        BotNode.__init__(self, argstest)
        #print "from Test node: " + args[1]

    def Action(self):
        i=1
        while(i>=0):
            i -= 1
            print "Action Method"
        self.publishMessage()
        print "Action Method"

def testMethod():
    print "This is test method..."

if __name__ == "__main__":
    bot= TestNode(sys.argv)
    bot.setMethod(testMethod)
    bot.execMethod()
    bot.Action()