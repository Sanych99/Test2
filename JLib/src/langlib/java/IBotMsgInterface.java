package langlib.java;

import com.ericsson.otp.erlang.*;

public interface IBotMsgInterface{
    OtpErlangTuple get_Msg() throws Exception;
}
