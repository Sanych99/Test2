package ibot.java.nodes;

import dev.msg.java.TestMsg;
import dev.msg.java.TestTypesMsg;
import dev.srv.java.ServiceTestReq;
import dev.srv.java.ServiceTestResp;
import langlib.java.BotNode;

/**
 * Hello world!
 *
 */
public class FirstJava extends BotNode {

    private final String TEST_TOPIC_NAME = "test_topic";
    private final String SUBSCRIBE_TOPIC_NAME = "java_topic";

    public FirstJava(String[] args) throws Exception {
        super(args);
    }

    public static void main( String[] args ) throws Exception {
        System.out.println( "Hello World! 2" );
        FirstJava app = new FirstJava(args);
        app.Action();
    }

    @Override
    public void Action() throws Exception {
        this.logMessage("Start node Action method");
        this.logWarning("Log test WARNING message");
        this.logError("Test ERROR message");

        TestMsg testMsg = new TestMsg();

        testMsg.set_strParam("String for send ui test...");
        testMsg.set_longParam((long) 555);
        this.sendMessageToUI(testMsg, "TestMsg");

        this.subscribeToTopic(SUBSCRIBE_TOPIC_NAME, "receiveTopicMessage", TestTypesMsg.class);

        TestTypesMsg testTypesMsg = new TestTypesMsg();
        testTypesMsg.set_boolParam(false);
        testTypesMsg.set_strParam("Test from new project");
        this.publishMessage(TEST_TOPIC_NAME, testTypesMsg);





        ServiceTestReq req = new ServiceTestReq();
        req.set_strParamReq("Hello from java!");
        this.registerServiceClient("new_cpp_service", "serviceResponse", ServiceTestReq.class, ServiceTestResp.class);
        this.asyncServiceRequest("new_cpp_service", req);


    }

    public void receiveTopicMessage(TestTypesMsg topicMessage) {
        this.logMessage("Message received");
        this.logMessage("String value: " + topicMessage.get_strParam());
        this.logMessage("Boolean value: " + topicMessage.get_boolParam());
    }

    public void serviceResponse(ServiceTestReq req, ServiceTestResp resp) {
        System.out.println( "Message from client: " +req.get_strParamReq() );
        System.out.println( "Message from service: " +resp.get_strParamResp() );
        this.logMessage("Message from client: " +req.get_strParamReq());
        this.logMessage("Message from client: " +req.get_strParamReq());
    }
}
