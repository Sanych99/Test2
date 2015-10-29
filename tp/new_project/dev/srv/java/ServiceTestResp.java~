package dev.msg.java;

import com.ericsson.otp.erlang.*;
import langlib.java.*;

public class ServiceTestResp implements IBotMsgInterface {

	private OtpErlangObject[] resultObject;

	private OtpErlangString strParamRespOtp;
	private String strParamResp;

	public ServiceTestResp() throws Exception {
		resultObject = new OtpErlangObject[1];
		this.set_defaultValues();
	}

	public OtpErlangTuple get_Msg() throws Exception {
		return new OtpErlangTuple(this.resultObject);
	}

	public ServiceTestResp(OtpErlangTuple msg) throws Exception {
		resultObject = new OtpErlangObject[1];
		this.set_defaultValues();
		this.set_strParamResp(((OtpErlangString)msg.elementAt(0)).stringValue());	
	}

	private void set_defaultValues() {
		this.set_strParamResp(new String(" "));
	}

	public String get_strParamResp() {
		return strParamResp;
	}

	public void set_strParamResp(String strParamResp) {
		this.strParamResp = strParamResp;
		this.resultObject[0] = new OtpErlangString(strParamResp);
	}
}