from py_interface import erl_term

class ServiceTestResp():

	def __init__(self, msg = None):
		self.resultObject = [None] * 3

		self.set_therdParamResp(str(" "))
		self.set_secParamResp(long(0))
		self.set_strParamResp(str(" "))

		if (msg is not None):
			self.set_therdParamResp(str(msg[2]))
			self.set_secParamResp(long(msg[1]))
			self.set_strParamResp(str(msg[0]))

	def get_therdParamResp(self): return self._therdParamResp


	def set_therdParamResp(self, val):
		self._therdParamResp = val
		self.resultObject[2] = erl_term.ErlString(val)



	def get_secParamResp(self): return self._secParamResp


	def set_secParamResp(self, val):
		self._secParamResp = val
		self.resultObject[1] = long(val)



	def get_strParamResp(self): return self._strParamResp


	def set_strParamResp(self, val):
		self._strParamResp = val
		self.resultObject[0] = erl_term.ErlString(val)



	def getMsg(self):
		return erl_term.ErlTuple(self.resultObject)