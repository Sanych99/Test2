import sys
from py_i_bot_os.BotNode import BotNode
from TestMsg import TestMsg
from py_interface import erl_eventhandler, erl_common
from TestTypesMsg import TestTypesMsg


class TestPythonFromIdea(BotNode):
    def __init__(self, args):
        BotNode.__init__(self, args[1:])

    def StartNode(self):
        evhand = erl_eventhandler.GetEventHandler()
        evhand.Loop()

    def action(self):
        self.monitor_start();
        self.subscribe_to_topic("testTopic", self.cbmMethod, TestMsg)
        #self.subscribe_to_topic("new_gen_msg", self.requestNewMethod, TestTypesMsg)

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
        tm.set_strList(["list from 1", "list from 2", "list from 3"])
        self.publish_message("tecd st_topic_from_py", tm)

    def requestNewMethod(self, msg):
        print "new msg str: ", msg.get_strParam()
        print "new msg bool: ", msg.get_boolParam()

        new_message = TestTypesMsg()
        new_message.set_boolParam(bool(True))
        new_message.set_intPara(int(5))
        #new_message.set_strParam("New String From python!")

        self.publish_message("new_gen_msg_response", new_message)


if __name__ == "__main__":
    bot = TestPythonFromIdea(sys.argv)
    bot.StartNode()
