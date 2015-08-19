package com.ibotmsg;

import com.ericsson.otp.erlang.OtpErlangObject;
import com.ericsson.otp.erlang.OtpErlangString;
import com.ericsson.otp.erlang.OtpErlangTuple;
import langlib.java.IBotMsgInterface;

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
		resultObject = new OtpErlangObject[1];
		this.strParam = ((OtpErlangString)msg.elementAt(0)).stringValue();	
	}

	public String get_strParam() {
		return strParam;
	}

	public void set_strParam(String strParam) {
		this.strParam = strParam;
		this.resultObject[0] = new OtpErlangString(strParam);
	}
}