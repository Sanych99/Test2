package test;

import com.ericsson.otp.erlang.*;
//import java.math.Integer;
import langlib.java.*;

public class TestSrvReq implements IBotMsgInterface {

	private OtpErlangObject[] resultObject;

	private OtpErlangString bla1Otp;
	private String bla1;

	private OtpErlangLong bla2Otp;
	private Integer bla2;

	private OtpErlangString bla3Otp;
	private String bla3;

	public TestSrvReq() throws Exception {
		resultObject = new OtpErlangObject[3];
	}

	public OtpErlangTuple get_Msg() throws Exception {
		return new OtpErlangTuple(this.resultObject);
	}

	public TestSrvReq(OtpErlangTuple msg) throws Exception {
		this.bla3 = ((OtpErlangString)msg.elementAt(2)).stringValue();
		this.bla2 = ((OtpErlangLong)msg.elementAt(1)).intValue();
		this.bla1 = ((OtpErlangString)msg.elementAt(0)).stringValue();	
	}

	public String get_bla3() {
		return bla3;
	}

	public void set_bla3(String bla3) {
		this.resultObject[2] = new OtpErlangString(bla3);
	}


	public Integer get_bla2() {
		return bla2;
	}

	public void set_bla2(Integer bla2) {
		this.resultObject[1] = new OtpErlangLong(bla2);
	}


	public String get_bla1() {
		return bla1;
	}

	public void set_bla1(String bla1) {
		this.resultObject[0] = new OtpErlangString(bla1);
	}
}
