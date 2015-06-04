from py_interface import erl_term

class TestMsg():

    def __init__(self):
        self.strParam = "Not init StrParam..."

    def __init__(self, msgTuple):
        self.strParam = str(msgTuple[0])
