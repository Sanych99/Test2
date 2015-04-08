package test;

import com.ericsson.otp.erlang.*;
import java.math.BigInteger;
import langlib.java.*;

public class BLA_BLA_BLA extends BotNode {

    public void OutPutMessageMethod(OtpErlangTuple msg)
    {
        System.out.println("OutPutMessageMethod" + ((OtpErlangString)msg.elementAt(0)).stringValue());
    }

    public BLA_BLA_BLA() throws Exception {
        super(BLA_BLA_BLA.class, "BLA_BLA_BLA", "alex-N550JK", "core@alex-N550JK", "facserver", "ibot_nodes_srv_registrator", "ibot_nodes_srv_topic", "jv");
    }

    public void Action() throws IllegalAccessException, NoSuchMethodException, InstantiationException {
        System.out.println("READY!");

        try {
            Thread.sleep(5000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        subscribeToTopic("test_topic", "OutPutMessageMethod", OtpErlangTuple.class);
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
        BLA_BLA_BLA bla_bla_bla = new BLA_BLA_BLA();
        bla_bla_bla.Action();
    }
}