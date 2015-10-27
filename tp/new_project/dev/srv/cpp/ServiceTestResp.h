#include "IBotMsgInterface.h"

class ServiceTestResp: public IBotMsgInterface {
public:

	std::string therdParamResp(" ");
	long secParamResp(0);
	std::string strParamResp(" ");

	ServiceTestResp() {
	}

	ServiceTestResp(matchable_ptr message_elements) {
	}

	def getMsg(self):
		return erl_term.ErlTuple(self.resultObject)