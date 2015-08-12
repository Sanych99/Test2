function TestMsg() {

	this.strParam;

	if (msg) {
		this.strParam = msg[0];	
	}
	this.getMessage = function() {
		return erl_term.ErlTuple(self.resultObject);
	}	
}