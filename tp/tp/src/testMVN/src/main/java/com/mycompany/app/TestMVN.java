package com.mycompany.app;

import langlib.java.BotNode;

import java.util.ArrayList;
import java.util.List;

/**
 * Hello world!
 *
 */
public class TestMVN extends BotNode
{
    public TestMVN (String[] args) throws Exception {
        super(args);
    }

    public static void main( String[] args ) throws Exception {
        System.out.println("Hello World from maven project!");
        TestMVN app = new TestMVN(args);
        app.Action();
    }

    @Override
    public void Action() throws Exception {
        System.out.println("Message was send!");

        //this.subscribeToTopic("test_topic_from_py", "topicMethod", TestMsg_.class);
        TestMsg_ testMsg_ = new TestMsg_();
        testMsg_.set_doubleParam(2.5);
        testMsg_.set_strParam("TEST STRING !");
        testMsg_.set_boolParam(true);
        testMsg_.set_longParam((long) 50);

        List<String> testStrList =  new ArrayList<>();
        testStrList.add("test string 1");
        testStrList.add("test string 2");
        testStrList.add("test string 3");

        testMsg_.set_stringList(testStrList);

        //this.publishMessage("testTopic", testMsg_);

        this.subscribeToTopic("new_gen_msg_response", "newMethod", TestTypesMsg.class);
        TestTypesMsg testTypesMsg = new TestTypesMsg();
        testTypesMsg.set_strParam(new String("New String Param"));
        testTypesMsg.set_boolParam(false);
        this.publishMessage("new_gen_msg", testTypesMsg);
    }

    public void topicMethod(TestMsg_ msg) {
        System.out.println("YO! str " + msg.get_strParam());
        System.out.println("YO! long " + msg.get_longParam());
        System.out.println("YO! bool " + msg.get_boolParam());
        System.out.println("YO! float " + msg.get_doubleParam());
        for(String str : msg.get_stringList())
            System.out.println("YO! list " + str);
    }

    public void newMethod(TestTypesMsg testTypesMsg) {
        System.out.println("newTest str: " + testTypesMsg.get_strParam());
        System.out.println("newTest double: " + testTypesMsg.get_doubleParam());
        System.out.println("newTest int: " + testTypesMsg.get_intPara());
        System.out.println("newTest long: " + testTypesMsg.get_longParam());
        System.out.println("newTest bool: " + testTypesMsg.get_boolParam());


    }
}
