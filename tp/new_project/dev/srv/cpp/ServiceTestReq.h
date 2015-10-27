#include "IBotMsgInterface.h"

class ServiceTestReq: public IBotMsgInterface {
public:

	std::string therdParamReq(" ");
	long secParamReq(0);
	std::string strParamReq(" ");

	ServiceTestReq() {
	}

	ServiceTestReq(matchable_ptr message_elements) {
	}

	def getMsg(self):
		return erl_term.ErlTuple(self.resultObject)