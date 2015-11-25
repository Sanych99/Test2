function TestTypesMsg_logic(msg) {

	this.action = function() {
        $('#messages').html("from logic file: string: " + msg.strParam + "  long: " + msg.longParam + "  int: " + msg.intPara
        + "  double: " + msg.doubleParam + "    boolean: " + msg.boolParam);
    }
}