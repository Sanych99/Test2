package com.mycompany.app;

import com.ericsson.otp.erlang.*;
import langlib.java.IBotMsgInterface;

import java.util.ArrayList;
import java.util.List;

public class TestMsg_ implements IBotMsgInterface {

	private OtpErlangObject[] resultObject;

	private OtpErlangString strParamOtp;
	private String strParam;

	private OtpErlangLong longParamOtp;
	private Long longParam;

    private OtpErlangBoolean boolParamOtp;
    private boolean boolParam;

    private OtpErlangDouble doubleParamOtp;
    private double doubleParam;

    private OtpErlangList stringListOtp;
    private List<String> stringList;

	public TestMsg_() throws Exception {
		resultObject = new OtpErlangObject[5];
        stringList = new ArrayList<String>();
	}

	public OtpErlangTuple get_Msg() throws Exception {
		return new OtpErlangTuple(this.resultObject);
	}

	public TestMsg_(OtpErlangTuple msg) throws Exception {
		resultObject = new OtpErlangObject[5];
        stringList = new ArrayList<String>();
        this.create_strList_from_Message((OtpErlangList)msg.elementAt(4));
        this.set_doubleParam(((OtpErlangDouble) msg.elementAt(3)).doubleValue());
        //this.set_boolParam(Boolean.parseBoolean(((OtpErlangAtom) msg.elementAt(2)).atomValue()));
        this.set_boolParam(((OtpErlangAtom) msg.elementAt(2)).booleanValue());
		this.set_longParam(((OtpErlangLong)msg.elementAt(1)).longValue());
		this.set_strParam(((OtpErlangString)msg.elementAt(0)).stringValue());
	}

    /*Long*/
	public Long get_longParam() {
		return longParam;
	}

	public void set_longParam(Long longParam) {
		this.longParam = longParam;
		this.resultObject[1] = new OtpErlangLong(longParam);
	}
    /*Long*/


    /*String*/
	public String get_strParam() {
		return strParam;
	}

	public void set_strParam(String strParam) {
		this.strParam = strParam;
		this.resultObject[0] = new OtpErlangString(strParam);
	}
    /*String*/


    /*boolean*/
    public boolean get_boolParam() {
        return boolParam;
    }

    public void set_boolParam(boolean boolParam) {
        this.boolParam = boolParam;
        //Boolean bool = new Boolean(boolParam);
        //this.resultObject[2] = new OtpErlangAtom(bool.toString());
        this.resultObject[2] = new OtpErlangBoolean(boolParam);
    }
    /*boolean*/



    /*double*/
    public double get_doubleParam() {
        return doubleParam;
    }

    public void set_doubleParam(double doubleParam) {
        this.doubleParam = doubleParam;
        this.resultObject[3] = new OtpErlangDouble(doubleParam);
    }
    /*double*/


    /*List<String>*/
    public List<String> get_stringList() { return this.stringList; }

    public  void set_stringList(List<String> stringList) {
        this.stringList = stringList;

        OtpErlangObject[] testObject = new OtpErlangObject[this.stringList.size()];
        int counter = 0;
        for(String param : this.stringList) {
            testObject[counter] = new OtpErlangString(param);
            counter++;
        }

        this.resultObject[4] = new OtpErlangList(testObject);
    }

    private void create_strList_from_Message(OtpErlangList list) {
        for(OtpErlangObject param : list) {
            this.stringList.add(((OtpErlangString) param).stringValue());
        }
    }
    /*List<String>*/
}
