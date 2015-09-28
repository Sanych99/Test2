package com.mycompany.app;

import com.ericsson.otp.erlang.*;
import langlib.java.*;

public class TestTypesMsg implements IBotMsgInterface {

	private OtpErlangObject[] resultObject;

	private OtpErlangString strParamOtp;
	private String strParam;

	private OtpErlangLong longParamOtp;
	private Long longParam;

	private OtpErlangInt intParaOtp;
	private int intPara;

	private OtpErlangDouble doubleParamOtp;
	private double doubleParam;

	private OtpErlangBoolean boolParamOtp;
	private boolean boolParam;

	public TestTypesMsg() throws Exception {
		resultObject = new OtpErlangObject[5];
		this.set_defaultValues();
	}

	public OtpErlangTuple get_Msg() throws Exception {
		return new OtpErlangTuple(this.resultObject);
	}

	public TestTypesMsg(OtpErlangTuple msg) throws Exception {
		resultObject = new OtpErlangObject[5];
		this.set_defaultValues();
		this.set_boolParam(((OtpErlangAtom)msg.elementAt(4)).booleanValue());
		this.set_doubleParam(((OtpErlangDouble)msg.elementAt(3)).doubleValue());
		this.set_intPara(((OtpErlangLong)msg.elementAt(2)).intValue());
		this.set_longParam(((OtpErlangLong)msg.elementAt(1)).longValue());
		this.set_strParam(((OtpErlangString)msg.elementAt(0)).stringValue());	
	}

	private void set_defaultValues() {
		this.set_boolParam((boolean)true);
		this.set_doubleParam((double)0);
		this.set_intPara((int)0);
		this.set_longParam(new Long(0));
		this.set_strParam(new String(" "));
	}

	public boolean get_boolParam() {
		return boolParam;
	}

	public void set_boolParam(boolean boolParam) {
		this.boolParam = boolParam;
		this.resultObject[4] = new OtpErlangBoolean(boolParam);
	}


	public double get_doubleParam() {
		return doubleParam;
	}

	public void set_doubleParam(double doubleParam) {
		this.doubleParam = doubleParam;
		this.resultObject[3] = new OtpErlangDouble(doubleParam);
	}


	public int get_intPara() {
		return intPara;
	}

	public void set_intPara(int intPara) {
		this.intPara = intPara;
		this.resultObject[2] = new OtpErlangInt(intPara);
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