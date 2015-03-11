package langlib.java;

import com.ericsson.otp.erlang.*;

//Java Otp Node Connector Class
public class IBotNode {

    private String currenServerName; //Current server name machime_name

    private OtpNode otpNode; //Java Otp node

    private String otpNodeName; //Java Otp node name

    private OtpMbox otpMbox; //Otp node mail box

    private String otpMboxName; //Otp node mail box name

    private String coreNodeName; //Server name core@machime_name

    private String registratorCoreNode; //Core node registrator module

    private String publisherCoreNode; //Core message publisher module

    private String coreCoockies; //Core node coockies

    //Class constructor
    public IBotNode(String otpNodeName, String currenServerName, String coreNodeName,
                String otpMboxName, String registratorCoreNode, String publisherCoreNode, String coreCoockes)
            throws Exception
    {
        set_otpNode(createNode(otpNodeName, coreCoockes));
        set_otpMbox(createMbox(otpMboxName));
        this.otpNodeName = otpNodeName;
        this.otpMboxName = otpMboxName;
        //Mss mss = new Mss();
        this.currenServerName = currenServerName;
        this.coreNodeName = coreNodeName;
        this.registratorCoreNode = registratorCoreNode;
        this.publisherCoreNode = publisherCoreNode;
        this.coreCoockies = coreCoockes;
    }


    //Creation Methods

    //OtpNode create method
    private OtpNode createNode(String otpNodeName, String coreCoockes) throws Exception
    {
        return new OtpNode(otpNodeName, coreCoockes);
    }

    //OtpMbox create method
    private OtpMbox createMbox(String otpMboxName)
    {
        return get_otpNode().createMbox(otpMboxName);
    }


    public void subscribeToTopic(String topicName)
    {
        OtpErlangObject[] subscribeObject = new OtpErlangObject[4];
        subscribeObject[0] = new OtpErlangAtom("reg_subscr");
        subscribeObject[1] = new OtpErlangString(this.otpMboxName);
        subscribeObject[2] = new OtpErlangString(this.otpNodeName + "@" + this.currenServerName);
        subscribeObject[3] = new OtpErlangAtom(topicName);
        this.otpMbox.send(this.publisherCoreNode, this.coreNodeName, new OtpErlangTuple(subscribeObject));
        System.out.println("subscribeToTopic " + topicName);
    }


    //Action Methods

    //Message publish method
    public void publishMsg(OtpErlangTuple tuple)
    {
        this.otpMbox.send(this.publisherCoreNode, this.coreNodeName, tuple);
    }

    public void publishMessage(Object msg) throws Exception
    {
        IBotMsgInterface msgIn = (IBotMsgInterface)msg;
        this.otpMbox.send(this.publisherCoreNode, this.coreNodeName, msgIn.get_Msg());
    }


    //Getters and Setters

    //otpNode Getter
    public OtpNode get_otpNode()
    {
        return this.otpNode;
    }

    //otpNode Setter
    private void set_otpNode(OtpNode otpNode)
    {
        this.otpNode = otpNode;
    }


    //otpMbox Getter
    public OtpMbox get_otpMbox()
    {
        return  this.otpMbox;
    }

    //otpMbox Setter
    private void set_otpMbox(OtpMbox otpMbox)
    {
        this.otpMbox = otpMbox;
    }
}