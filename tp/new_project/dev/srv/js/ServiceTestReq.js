function ServiceTestReq(msg) {

	this.strParamReq = " ";

	if (msg) {
		this.strParamReq = msg[0];	
	}

	this.getMessage = function() {
		return "[" + "\"" + this.strParamReq + "\"" + "]";
	}	
}