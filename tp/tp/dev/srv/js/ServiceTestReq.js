function ServiceTestReq() {

	this.therdParamReq;

	this.secParamReq;

	this.strParamReq;

	if (msg) {
		this.therdParamReq = msg[2];
		this.secParamReq = msg[1];
		this.strParamReq = msg[0];	
	}
	this.getMessage = function() {
		return erl_term.ErlTuple(self.resultObject);
	}	
}