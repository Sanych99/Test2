import com.ericsson.otp.erlang.*;
import java.math.BigInteger;
import langlib.java.*;

public class ServiceTestReq implements IBotMsgInterface {

	private OtpErlangObject[] resultObject;

	private OtpErlangString strParamReqOtp;
	private String strParamReq;

	private OtpErlangLong secParamReqOtp;
	private BigInteger secParamReq;

	private OtpErlangString therdParamReqOtp;
	private String therdParamReq;

	public ServiceTestReq() throws Exception {
		resultObject = new OtpErlangObject[3];
	}

	public OtpErlangTuple get_Msg() throws Exception {
		return new OtpErlangTuple(this.resultObject);
	}

	public ServiceTestReq(OtpErlangTuple msg) throws Exception {
		this.therdParamReq = ((OtpErlangString)msg.elementAt(2)).stringValue();
		this.secParamReq = ((OtpErlangLong)msg.elementAt(1)).longValue();
		this.strParamReq = ((OtpErlangString)msg.elementAt(0)).stringValue();	
	}

	public String get_therdParamReq() {
		return therdParamReq;
	}

	public void set_therdParamReq(String therdParamReq) {
		this.therdParamReq = therdParamReq;
		this.resultObject[2] = new OtpErlangString(therdParamReq);
	}


	public BigInteger get_secParamReq() {
		return secParamReq;
	}

	public void set_secParamReq(BigInteger secParamReq) {
		this.secParamReq = secParamReq;
		this.resultObject[1] = new OtpErlangLong(secParamReq);
	}


	public String get_strParamReq() {
		return strParamReq;
	}

	public void set_strParamReq(String strParamReq) {
		this.strParamReq = strParamReq;
		this.resultObject[0] = new OtpErlangString(strParamReq);
	}
}