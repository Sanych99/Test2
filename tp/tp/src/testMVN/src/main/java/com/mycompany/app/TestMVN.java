package com.mycompany.app;

import dev.msg.java.TestMsg;
import langlib.java.BotNode;
/**
 * Hello world!
 *
 */
public class TestMVN extends BotNode
{
    public TestMVN (String[] args) throws Exception {
        super(args);
        //super(args);
    }

    public static void main( String[] args ) throws Exception {
        System.out.println("Hello World from maven project!");
        TestMVN app = new TestMVN(args);
        app.Action();
    }

    @Override
    public void Action() throws Exception {
        System.out.println("Message was send!");

        this.subscribeToTopic("testTopic", "topicMethod", TestMsg.class);
    }

    public void topicMethod(TestMsg msg) {
        System.out.println("YO! " + msg.get_strParam());
    }
}
