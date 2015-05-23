import sys
from BotNode import BotNode

class TestNode(BotNode):

    def __init__(self, args):
        BotNode.__init__(self, args)
        #print "from Test node: " + args[1]

if __name__ == "__main__":
    bot= TestNode(sys.argv)