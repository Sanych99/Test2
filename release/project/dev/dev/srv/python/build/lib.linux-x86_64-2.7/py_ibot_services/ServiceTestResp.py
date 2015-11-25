from py_interface import erl_term

class ServiceTestResp():

	def __init__(self, msg = None):
		self.resultObject = [None] * 1

		self.set_strParamResp(str(" "))

		if (msg is not None):
			self.set_strParamResp(str(msg[0]))

	def get_strParamResp(self): return self._strParamResp


	def set_strParamResp(self, val):
		self._strParamResp = val
		self.resultObject[0] = erl_term.ErlString(val)



	def getMsg(self):
		return erl_term.ErlTuple(self.resultObject)