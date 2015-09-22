package com.mycompany.app;

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

        this.subscribeToTopic("test_topic_from_py", "topicMethod", TestMsg_.class);
        TestMsg_ testMsg_ = new TestMsg_();
        testMsg_.set_doubleParam(2.5);
        testMsg_.set_strParam("TEST STRING !");
        testMsg_.set_boolParam(true);
        testMsg_.set_longParam((long) 50);
        this.publishMessage("testTopic", testMsg_);
    }

    public void topicMethod(TestMsg_ msg) {
        System.out.println("YO! str " + msg.get_strParam());
        System.out.println("YO! long " + msg.get_longParam());
        System.out.println("YO! bool " + msg.get_boolParam());
        System.out.println("YO! float " + msg.get_doubleParam());

    }
}
