function ServiceTestReq() {

	this.therdParamReq = "";

	this.secParamReq = 0;

	this.strParamReq = "";

	if (msg) {
		this.therdParamReq = msg[2];
		this.secParamReq = msg[1];
		this.strParamReq = msg[0];	
	}

	this.getMessage = function() {
		return "[" + "\"" + this.strParamReq + "\"" + "," + this.secParamReq + "," + "\"" + this.therdParamReq + "\"" + "]";
	}	
}