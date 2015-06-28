from py_interface import erl_term

class TestMsg():

	def __init__(self):
		self.resultObject = []

	def getMsg(self):
		return erl_term.ErlTuple(self.resultObject);

	def __init__(self, msg):
		self.strParam = str(msg[0])

	@property
	def strParam(self): return self._strParam


	@strParam.setter
	def strParam(self, val):
		self._strParam = val
		self.resultObject[0] = erl_term.ErlString(val)

