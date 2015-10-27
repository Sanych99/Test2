#include "IBotMsgInterface.h"

class TestMsg: public IBotMsgInterface {
public:

	long longParam(0);
	std::string strParam(" ");

	TestMsg() {
	}

	TestMsg(matchable_ptr message_elements) {
	}

	def getMsg(self):
		return erl_term.ErlTuple(self.resultObject)