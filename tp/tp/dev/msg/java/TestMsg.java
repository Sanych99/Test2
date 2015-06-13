import com.ericsson.otp.erlang.*;
import java.math.BigInteger;
import langlib.java.*;

public class TestMsg implements IBotMsgInterface {

	private OtpErlangObject[] resultObject;

	private OtpErlangString strParamOtp;
	private String strParam;

	public TestMsg() throws Exception {
		resultObject = new OtpErlangObject[1];
	}

	public OtpErlangTuple get_Msg() throws Exception {
		return new OtpErlangTuple(this.resultObject);
	}

	public TestMsg(OtpErlangTuple msg) throws Exception {
		this.strParam = ((OtpErlangString)msg.elementAt(0)).stringValue();	
	}

	public String get_strParam() {
		return strParam;
	}

	public void set_strParam(String strParam) {
		this.resultObject[0] = new OtpErlangString(strParam);
	}
}