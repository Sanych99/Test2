from py_interface import erl_term

class ServiceTestResp():

	def __init__(self):
		self.resultObject = []

	def getMsg(self):
		return erl_term.ErlTuple(self.resultObject);

	def __init__(self, msg):
		self.therdParamResp = str(msg[2])
		self.secParamResp = int(msg[1])
		self.strParamResp = str(msg[0])

	@property
	def therdParamResp(self): return self._therdParamResp


	@therdParamResp.setter
	def therdParamResp(self, val):
		self._therdParamResp = val
		self.resultObject[2] = erl_term.ErlString(val)



	@property
	def secParamResp(self): return self._secParamResp


	@secParamResp.setter
	def secParamResp(self, val):
		self._secParamResp = val
		self.resultObject[1] = erl_term.ErlInt(val)



	@property
	def strParamResp(self): return self._strParamResp


	@strParamResp.setter
	def strParamResp(self, val):
		self._strParamResp = val
		self.resultObject[0] = erl_term.ErlString(val)

