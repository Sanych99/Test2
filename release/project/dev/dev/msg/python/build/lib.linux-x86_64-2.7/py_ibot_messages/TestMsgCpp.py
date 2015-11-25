from py_interface import erl_term

class TestMsgCpp():

	def __init__(self, msg = None):
		self.resultObject = [None] * 2

		self.set_longParam(int(0))
		self.set_strParam(str(" "))

		if (msg is not None):
			self.set_longParam(int(msg[1]))
			self.set_strParam(str(msg[0]))

	def get_longParam(self): return self._longParam


	def set_longParam(self, val):
		self._longParam = val
		self.resultObject[1] = int(val)



	def get_strParam(self): return self._strParam


	def set_strParam(self, val):
		self._strParam = val
		self.resultObject[0] = erl_term.ErlString(val)



	def getMsg(self):
		return erl_term.ErlTuple(self.resultObject)