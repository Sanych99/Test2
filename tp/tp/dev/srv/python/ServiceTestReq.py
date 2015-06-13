from py_interface import erl_term

class ServiceTestReq():

	def __init__(self):
		self.resultObject = []

	def getMsg(self):
		return erl_term.ErlTuple(self.resultObject);

	def __init__(self, msg):
		self.therdParamReq = str(msg[2])
		self.secParamReq = int(msg[1])
		self.strParamReq = str(msg[0])

	@property
	def therdParamReq(self): return self._therdParamReq


	@therdParamReq.setter
	def therdParamReq(self, val):
		self._therdParamReq = val
		self.resultObject[2] = erl_term.ErlString(val)



	@property
	def secParamReq(self): return self._secParamReq


	@secParamReq.setter
	def secParamReq(self, val):
		self._secParamReq = val
		self.resultObject[1] = erl_term.ErlInt(val)



	@property
	def strParamReq(self): return self._strParamReq


	@strParamReq.setter
	def strParamReq(self, val):
		self._strParamReq = val
		self.resultObject[0] = erl_term.ErlString(val)

