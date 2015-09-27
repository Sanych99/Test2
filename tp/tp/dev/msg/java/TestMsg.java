package dev.msg.java;

import com.ericsson.otp.erlang.*;
import langlib.java.*;

public class TestMsg implements IBotMsgInterface {

	private OtpErlangObject[] resultObject;

	private OtpErlangString strParamOtp;
	private String strParam;

	private OtpErlangLong longParamOtp;
	private Long longParam;

	public TestMsg() throws Exception {
		resultObject = new OtpErlangObject[2];
		this.set_defaultValues();
	}

	public OtpErlangTuple get_Msg() throws Exception {
		return new OtpErlangTuple(this.resultObject);
	}

	public TestMsg(OtpErlangTuple msg) throws Exception {
		resultObject = new OtpErlangObject[2];
		this.set_defaultValues();
		this.set_longParam(((OtpErlangLong)msg.elementAt(1)).longValue());
		this.set_strParam(((OtpErlangString)msg.elementAt(0)).stringValue());	
	}

	private void set_defaultValues() {
		this.set_longParam(Long(0));
		this.set_strParam(String(" "));
	}

	public Long get_longParam() {
		return longParam;
	}

	public void set_longParam(Long longParam) {
		this.longParam = longParam;
		this.resultObject[1] = new OtpErlangLong(longParam);
	}


	public String get_strParam() {
		return strParam;
	}

	public void set_strParam(String strParam) {
		this.strParam = strParam;
		this.resultObject[0] = new OtpErlangString(strParam);
	}
}