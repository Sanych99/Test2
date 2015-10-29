function ServiceTestResp(msg) {

	this.strParamResp = " ";

	if (msg) {
		this.strParamResp = msg[0];	
	}

	this.getMessage = function() {
		return "[" + "\"" + this.strParamResp + "\"" + "]";
	}	
}