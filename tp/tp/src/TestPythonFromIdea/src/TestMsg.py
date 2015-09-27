from py_interface import erl_term

class TestMsg():

    def __init__(self, msg = None):
        self.resultObject = [None] * 5
        if (msg is not None):
            self.set_strList(list(msg[4]))
            self.set_floatParam(float(msg[3]))
            self.set_boolParam(bool(msg[2]))
            self.set_longParam(long(msg[1]))
            self.set_strParam(str(msg[0]))


    def get_floatParam(self): return self._floatParam


    def set_floatParam(self, val):
        self._floatParam = val
        self.resultObject[3] = float(val)

    def get_boolParam(self): return self._boolParam


    def set_boolParam(self, val):
        self._boolParam = val
        self.resultObject[2] = erl_term.ErlAtom(str(val).lower())


    def get_longParam(self): return self._longParam


    def set_longParam(self, val):
        self._longParam = val
        self.resultObject[1] = long(val)



    def get_strParam(self): return self._strParam


    def set_strParam(self, val):
        self._strParam = val
        self.resultObject[0] = erl_term.ErlString(val)


    def getMsg(self):
        return erl_term.ErlTuple(self.resultObject);

    def set_strList(self, val):
        self.strList = val
        self.resultObject[4] = list(val)

    def get_strList(self):
        return self.strList