import com.ericsson.otp.erlang.*;
import langlib.java.*;

public class ServiceTestReq implements IBotMsgInterface {

	private OtpErlangObject[] resultObject;

	private OtpErlangString strParamReqOtp;
	private String strParamReq;

	private OtpErlangLong secParamReqOtp;
	private Long secParamReq;

	private OtpErlangString therdParamReqOtp;
	private String therdParamReq;

	public ServiceTestReq() throws Exception {
		resultObject = new OtpErlangObject[3];
	}

	public OtpErlangTuple get_Msg() throws Exception {
		return new OtpErlangTuple(this.resultObject);
	}

	public ServiceTestReq(OtpErlangTuple msg) throws Exception {
		resultObject = new OtpErlangObject[3];
		this.set_therdParamReq(((OtpErlangString)msg.elementAt(2)).stringValue());
		this.set_secParamReq(((OtpErlangLong)msg.elementAt(1)).longValue());
		this.set_strParamReq(((OtpErlangString)msg.elementAt(0)).stringValue());	
	}

	public String get_therdParamReq() {
		return therdParamReq;
	}

	public void set_therdParamReq(String therdParamReq) {
		this.therdParamReq = therdParamReq;
		this.resultObject[2] = new OtpErlangString(therdParamReq);
	}


	public Long get_secParamReq() {
		return secParamReq;
	}

	public void set_secParamReq(Long secParamReq) {
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