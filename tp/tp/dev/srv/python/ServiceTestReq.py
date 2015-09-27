from py_interface import erl_term

class ServiceTestReq():

	def __init__(self, msg = None):
		self.resultObject = [None] * 3

		self.set_therdParamReq(str(""))
		self.set_secParamReq(long(0))
		self.set_strParamReq(str(""))

		if (msg is not None):
			self.set_therdParamReq(str(msg[2]))
			self.set_secParamReq(long(msg[1]))
			self.set_strParamReq(str(msg[0]))

	def get_therdParamReq(self): return self._therdParamReq


	def set_therdParamReq(self, val):
		self._therdParamReq = val
		self.resultObject[2] = erl_term.ErlString(val)



	def get_secParamReq(self): return self._secParamReq


	def set_secParamReq(self, val):
		self._secParamReq = val
		self.resultObject[1] = long(val)



	def get_strParamReq(self): return self._strParamReq


	def set_strParamReq(self, val):
		self._strParamReq = val
		self.resultObject[0] = erl_term.ErlString(val)



	def getMsg(self):
		return erl_term.ErlTuple(self.resultObject);