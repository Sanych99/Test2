from py_interface import erl_term

class ServiceTestReq():

	def __init__(self, msg = None):
		self.resultObject = [None] * 1

		self.set_strParamReq(str(" "))

		if (msg is not None):
			self.set_strParamReq(str(msg[0]))

	def get_strParamReq(self): return self._strParamReq


	def set_strParamReq(self, val):
		self._strParamReq = val
		self.resultObject[0] = erl_term.ErlString(val)



	def getMsg(self):
		return erl_term.ErlTuple(self.resultObject)