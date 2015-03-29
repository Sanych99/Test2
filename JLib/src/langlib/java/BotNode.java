package langlib.java;

import com.ericsson.otp.erlang.*;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Dictionary;

//Java Otp Node Connector Class
public class BotNode {

    private String currenServerName; //Current server name machime_name

    private OtpNode otpNode; //Java Otp node

    private String otpNodeName; //Java Otp node name

    private OtpMbox otpMbox; //Otp node mail box

    private String otpMboxName; //Otp node mail box name

    private String coreNodeName; //Server name core@machime_name

    private String registratorCoreNode; //Core node registrator module

    private String publisherCoreNode; //Core message publisher module

    private String coreCoockies; //Core node coockies

    private String methodName;

    private Dictionary<OtpErlangAtom, String> subscribeDic;

    //private CallBack subscribeCallBacks; //Callback for subscribe topic

    //Class constructor
    public BotNode(Class<?> subscribeClass, String otpNodeName, String currenServerName, String coreNodeName,
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
        //this.subscribeCallBacks = new CallBack(subscribeClass);
    }


    //Creation Methods

    //OtpNode create method
    public OtpNode createNode(String otpNodeName, String coreCoockes) throws Exception
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
        subscribeObject[1] = new OtpErlangAtom(this.otpMboxName);
        subscribeObject[2] = new OtpErlangAtom(this.otpNodeName + "@" + this.currenServerName);
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

    public void subscribe(String methodName)
    {
        this.set_methodName(methodName);
        try {
            receive();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            e.printStackTrace();
        } catch (InstantiationException e) {
            e.printStackTrace();
        }
    }

    public void receive() throws IllegalAccessException, NoSuchMethodException, InvocationTargetException, InstantiationException {
        try {
            OtpErlangTuple par = (OtpErlangTuple) this.otpMbox.receive();
             invoke(par);
        } catch (OtpErlangExit otpErlangExit) {
            otpErlangExit.printStackTrace();
        } catch (OtpErlangDecodeException e) {
            e.printStackTrace();
        }
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

    public void set_methodName(String methodName)
    {
        this.methodName = methodName;
    }


    public void invoke(Object... parameters) throws InvocationTargetException, IllegalAccessException, NoSuchMethodException, InstantiationException {
        Method method = this.getClass().getMethod(methodName, getParameterClasses(parameters));
        method.invoke(this, parameters);
    }

    private Class[] getParameterClasses(Object... parameters) {
        Class[] classes = new Class[parameters.length];
        for (int i=0; i < classes.length; i++) {
            classes[i] = parameters[i].getClass();
        }
        return classes;
    }
}