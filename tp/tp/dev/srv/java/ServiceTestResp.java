package dev.msg.java;

import com.ericsson.otp.erlang.*;
import langlib.java.*;

public class ServiceTestResp implements IBotMsgInterface {

	private OtpErlangObject[] resultObject;

	private OtpErlangString strParamRespOtp;
	private String strParamResp;

	private OtpErlangLong secParamRespOtp;
	private Long secParamResp;

	private OtpErlangString therdParamRespOtp;
	private String therdParamResp;

	public ServiceTestResp() throws Exception {
		resultObject = new OtpErlangObject[3];
		this.set_defaultValues();
	}

	public OtpErlangTuple get_Msg() throws Exception {
		return new OtpErlangTuple(this.resultObject);
	}

	public ServiceTestResp(OtpErlangTuple msg) throws Exception {
		resultObject = new OtpErlangObject[3];
		this.set_defaultValues();
		this.set_therdParamResp(((OtpErlangString)msg.elementAt(2)).stringValue());
		this.set_secParamResp(((OtpErlangLong)msg.elementAt(1)).longValue());
		this.set_strParamResp(((OtpErlangString)msg.elementAt(0)).stringValue());	
	}

	private void set_defaultValues() {
		this.set_therdParamResp(new String(" "));
		this.set_secParamResp(new Long(0));
		this.set_strParamResp(new String(" "));
	}

	public String get_therdParamResp() {
		return therdParamResp;
	}

	public void set_therdParamResp(String therdParamResp) {
		this.therdParamResp = therdParamResp;
		this.resultObject[2] = new OtpErlangString(therdParamResp);
	}


	public Long get_secParamResp() {
		return secParamResp;
	}

	public void set_secParamResp(Long secParamResp) {
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