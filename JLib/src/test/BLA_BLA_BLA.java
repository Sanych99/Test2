package test;

import com.ericsson.otp.erlang.*;
import java.math.BigInteger;
import langlib.java.*;

public class BLA_BLA_BLA extends BotNode {

    public void OutPutMessageMethod(OtpErlangTuple msg)
    {
        System.out.println("OutPutMessageMethod" + ((OtpErlangString)msg.elementAt(0)).stringValue());
    }

    public TestSrvResp testService(TestSrvReq req) throws Exception {
        TestSrvResp resp = new TestSrvResp();
        resp.set_bla1("Hello=)");
        resp.set_bla2(10);
        resp.set_bla3("WORLD!");
        return resp;
    }

    public BLA_BLA_BLA(String[] args) throws Exception {
        //String[] args2 = new String[5];
        //super("BLA_BLA_BLA", "alex-N550JK", "core@alex-N550JK", "ibot_nodes_srv_topic", "jv");
        super(new String[] {"BLA_BLA_BLA", "alex-N550JK", "core@alex-N550JK", "ibot_nodes_srv_topic", "ibot_nodes_srv_service", "jv"});
        //super(args);
    }

    public void Action() throws IllegalAccessException, NoSuchMethodException, InstantiationException {
        System.out.println("READY!");

        this.registerServiceServer("testService", TestSrvReq.class, TestSrvResp.class);

        try {
            Thread.sleep(5000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        //subscribeToTopic("test_topic", "OutPutMessageMethod", OtpErlangTuple.class);
        System.out.println("subscribeToTopic...");
        try {
            Thread.sleep(5000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }


        System.out.println("Message was send!");
        System.out.println("Test");
        //System.exit(2);
        //throw new IllegalArgumentException("Final speed can not be less than zero");
        //}
    }

    public static void main (String[] args) throws Exception {
        BLA_BLA_BLA bla_bla_bla = new BLA_BLA_BLA(args);
        bla_bla_bla.Action();
    }
}