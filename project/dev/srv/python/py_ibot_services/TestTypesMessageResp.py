from py_interface import erl_term

class TestTypesMessageResp():

	def __init__(self, msg = None):
		self.resultObject = [None] * 5

		self.set_boolParam(bool(True))
		self.set_doubleParam(float(0))
		self.set_intPara(int(0))
		self.set_longParam(long(0))
		self.set_strParam(str(" "))

		if (msg is not None):
			self.set_boolParam(bool(msg[4]))
			self.set_doubleParam(float(msg[3]))
			self.set_intPara(int(msg[2]))
			self.set_longParam(long(msg[1]))
			self.set_strParam(str(msg[0]))

	def get_boolParam(self): return self._boolParam


	def set_boolParam(self, val):
		self._boolParam = val
		self.resultObject[4] = erl_term.ErlAtom(str(val).lower())



	def get_doubleParam(self): return self._doubleParam


	def set_doubleParam(self, val):
		self._doubleParam = val
		self.resultObject[3] = float(val)



	def get_intPara(self): return self._intPara


	def set_intPara(self, val):
		self._intPara = val
		self.resultObject[2] = int(val)



	def get_longParam(self): return self._longParam


	def set_longParam(self, val):
		self._longParam = val
		self.resultObject[1] = long(val)



	def get_strParam(self): return self._strParam


	def set_strParam(self, val):
		self._strParam = val
		self.resultObject[0] = erl_term.ErlString(val)



	def getMsg(self):
		return erl_term.ErlTuple(self.resultObject)