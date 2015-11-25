package dev.msg.java;

import com.ericsson.otp.erlang.*;
import langlib.java.*;

public class ServiceTestReq implements IBotMsgInterface {

	private OtpErlangObject[] resultObject;

	private OtpErlangString strParamReqOtp;
	private String strParamReq;

	public ServiceTestReq() throws Exception {
		resultObject = new OtpErlangObject[1];
		this.set_defaultValues();
	}

	public OtpErlangTuple get_Msg() throws Exception {
		return new OtpErlangTuple(this.resultObject);
	}

	public ServiceTestReq(OtpErlangTuple msg) throws Exception {
		resultObject = new OtpErlangObject[1];
		this.set_defaultValues();
		this.set_strParamReq(((OtpErlangString)msg.elementAt(0)).stringValue());	
	}

	private void set_defaultValues() {
		this.set_strParamReq(new String(" "));
	}

	public String get_strParamReq() {
		return strParamReq;
	}

	public void set_strParamReq(String strParamReq) {
		this.strParamReq = strParamReq;
		this.resultObject[0] = new OtpErlangString(strParamReq);
	}
}