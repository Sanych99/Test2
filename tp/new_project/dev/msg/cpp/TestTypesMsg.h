#include "IBotMsgInterface.h"

class TestTypesMsg: public IBotMsgInterface {
public:

	bool boolParam(True);
	float_ doubleParam(0);
	int_ intPara(0);
	long longParam(0);
	std::string strParam(" ");

	TestTypesMsg() {
	}

	TestTypesMsg(matchable_ptr message_elements) {
	}

	def getMsg(self):
		return erl_term.ErlTuple(self.resultObject)