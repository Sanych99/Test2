import sys
from py_interface import erl_eventhandler, erl_common
from py_i_bot_os.BotNode import BotNode
from py_ibot_messages.TestTypesMsg import TestTypesMsg


class first_py(BotNode):
    def __init__(self, args):
        self.TEST_TOPIC_NAME = "test_topic";
        self.SUBSCRIBE_TOPIC_NAME = "java_topic";
        BotNode.__init__(self, args[1:])

    def StartNode(self):
        evhand = erl_eventhandler.GetEventHandler()
        evhand.Loop()

    def action(self):
        self.subscribe_to_topic(self.TEST_TOPIC_NAME, self.receive_topic_message, TestTypesMsg)

    def receive_topic_message(self, topicMessage):
        self.log_message("Python message receive")
        self.log_message("Python message long value: ")
        topicMessage.set_strParam("New String!")
        self.publish_message(self.SUBSCRIBE_TOPIC_NAME, topicMessage)

if __name__ == "__main__":
    bot = first_py(sys.argv)
    bot.StartNode()
