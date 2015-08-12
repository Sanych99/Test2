/**
 * Created by alex on 8/10/15.
 */

function TestMsg(msg)
{
    this.firstParam = "";

    if(msg) {
        this.firstParam = msg[0];
    }

    this.getMessage = function() {
        return "[\"" + this.firstParam + "\"]";
    }
}