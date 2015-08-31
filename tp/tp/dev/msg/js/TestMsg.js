function TestMsg(msg) {

	this.longParam = 0;

	this.strParam = "";

	if (msg) {
		this.longParam = msg[1];
		this.strParam = msg[0];	
	}

	this.getMessage = function() {
		return "[" + "\"" + this.strParam + "\"" + "," + this.longParam + "]";
	}	
}