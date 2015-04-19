package test;

import com.ericsson.otp.erlang.*;
import java.math.BigInteger;
import langlib.java.*;

public class BLA_BLA_C extends BotNode {

    public void testServiceClient(TestSrvReq req, TestSrvResp resp) {
        System.out.println(resp.get_bla1());
    }

    public BLA_BLA_C(String[] args) throws Exception {
        //super(args);
        super(new String[] {"BLA_BLA_C", "alex-N550JK", "core@alex-N550JK", "ibot_nodes_srv_topic", "ibot_nodes_srv_service", "jv"});
    }

    public void Action() throws Exception {
        System.out.println("READY!");


        this.registerServiceClient("testService", "testServiceClient", TestSrvReq.class, TestSrvResp.class);

        try {
            Thread.sleep(5000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        for(int i=0; i<500; i++) {
            TestSrvReq req = new TestSrvReq();
            req.set_bla1("Hello: " + i);
            req.set_bla2(i);
            req.set_bla3("World: " + i);
            this.asyncServiceRequest("testService", req);
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
        BLA_BLA_C BLA_BLA_C = new BLA_BLA_C(args);
        BLA_BLA_C.Action();
    }
}
