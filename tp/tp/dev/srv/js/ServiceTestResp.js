function ServiceTestResp() {

	this.therdParamResp;

	this.secParamResp;

	this.strParamResp;

	if (msg) {
		this.therdParamResp = msg[2];
		this.secParamResp = msg[1];
		this.strParamResp = msg[0];	
	}
	this.getMessage = function() {
		return erl_term.ErlTuple(self.resultObject);
	}	
}