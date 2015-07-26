import com.ericsson.otp.erlang.*;
import java.math.BigInteger;
import langlib.java.*;

public class ServiceTestResp implements IBotMsgInterface {

	private OtpErlangObject[] resultObject;

	private OtpErlangString strParamRespOtp;
	private String strParamResp;

	private OtpErlangLong secParamRespOtp;
	private BigInteger secParamResp;

	private OtpErlangString therdParamRespOtp;
	private String therdParamResp;

	public ServiceTestResp() throws Exception {
		resultObject = new OtpErlangObject[3];
	}

	public OtpErlangTuple get_Msg() throws Exception {
		return new OtpErlangTuple(this.resultObject);
	}

	public ServiceTestResp(OtpErlangTuple msg) throws Exception {
		this.therdParamResp = ((OtpErlangString)msg.elementAt(2)).stringValue();
		this.secParamResp = ((OtpErlangLong)msg.elementAt(1)).longValue();
		this.strParamResp = ((OtpErlangString)msg.elementAt(0)).stringValue();	
	}

	public String get_therdParamResp() {
		return therdParamResp;
	}

	public void set_therdParamResp(String therdParamResp) {
		this.therdParamResp = therdParamResp;
		this.resultObject[2] = new OtpErlangString(therdParamResp);
	}


	public BigInteger get_secParamResp() {
		return secParamResp;
	}

	public void set_secParamResp(BigInteger secParamResp) {
		this.secParamResp = secParamResp;
		this.resultObject[1] = new OtpErlangLong(secParamResp);
	}


	public String get_strParamResp() {
		return strParamResp;
	}

	public void set_strParamResp(String strParamResp) {
		this.strParamResp = strParamResp;
		this.resultObject[0] = new OtpErlangString(strParamResp);
	}
}