package dev.msg.java;

import com.ericsson.otp.erlang.*;
import langlib.java.*;

public class TestMsgCpp implements IBotMsgInterface {

	private OtpErlangObject[] resultObject;

	private OtpErlangString strParamOtp;
	private String strParam;

	private OtpErlangInt longParamOtp;
	private int longParam;

	public TestMsgCpp() throws Exception {
		resultObject = new OtpErlangObject[2];
		this.set_defaultValues();
	}

	public OtpErlangTuple get_Msg() throws Exception {
		return new OtpErlangTuple(this.resultObject);
	}

	public TestMsgCpp(OtpErlangTuple msg) throws Exception {
		resultObject = new OtpErlangObject[2];
		this.set_defaultValues();
		this.set_longParam(((OtpErlangLong)msg.elementAt(1)).intValue());
		this.set_strParam(((OtpErlangString)msg.elementAt(0)).stringValue());	
	}

	private void set_defaultValues() {
		this.set_longParam((int)0);
		this.set_strParam(new String(" "));
	}

	public int get_longParam() {
		return longParam;
	}

	public void set_longParam(int longParam) {
		this.longParam = longParam;
		this.resultObject[1] = new OtpErlangInt(longParam);
	}


	public String get_strParam() {
		return strParam;
	}

	public void set_strParam(String strParam) {
		this.strParam = strParam;
		this.resultObject[0] = new OtpErlangString(strParam);
	}
}