function ServiceTestResp(msg) {

	this.therdParamResp = " ";

	this.secParamResp = 0;

	this.strParamResp = " ";

	if (msg) {
		this.therdParamResp = msg[2];
		this.secParamResp = msg[1];
		this.strParamResp = msg[0];	
	}

	this.getMessage = function() {
		return "[" + "\"" + this.strParamResp + "\"" + "," + this.secParamResp + "," + "\"" + this.therdParamResp + "\"" + "]";
	}	
}