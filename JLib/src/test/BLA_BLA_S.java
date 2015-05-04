package test;

import com.ericsson.otp.erlang.*;
import java.math.BigInteger;
import langlib.java.*;

public class BLA_BLA_S extends BotNode {

    public TestSrvResp testService(TestSrvReq req) throws Exception {
        TestSrvResp resp = new TestSrvResp();
        resp.set_bla1("Hello=)");
        resp.set_bla2(10);
        resp.set_bla3("WORLD!");
        return resp;
    }

    public BLA_BLA_S(String[] args) throws Exception {
        //super(args);
        super(new String[] {"BLA_BLA_S", "alex-N550JK", "core@alex-N550JK", "ibot_nodes_srv_connector", "ibot_nodes_srv_topic", "ibot_nodes_srv_service", "jv"});
    }

    public void Action() throws IllegalAccessException, NoSuchMethodException, InstantiationException {
        System.out.println("READY!");

        this.registerServiceServer("testService", TestSrvReq.class, TestSrvResp.class);

        try {
            Thread.sleep(5000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }




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
        BLA_BLA_S BLA_BLA_S = new BLA_BLA_S(args);
        BLA_BLA_S.Action();
    }
}
