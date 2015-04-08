package langlib.java;

import com.ericsson.otp.erlang.*;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.*;

//Java Otp Node Connector Class
public class BotNode {


    private String currenServerName; //Current server name machime_name

    private OtpNode otpNode; //Java Otp node

    private String otpNodeName; //Java Otp node name

    private OtpMbox otpMbox; //Otp node mail box

    private String otpMboxName; //Otp node mail box name

    private String coreNodeName; //Server name core@machime_name

    //private String registratorCoreNode;// DELETE //Core node registrator module

    private String publisherCoreNode; //Core message publisher module

    private String coreCookie; //Core node cookies

    //private String methodName; // DELETE

    private Map<String, Set<CollectionSubscribe>> subscribeDic;

    //private CallBack subscribeCallBacks; //Callback for subscribe topic

    private Thread receiveMBoxMessageThread = new Thread(new Runnable() {
        public void run()
        {
            while (true) {
                try {
                    OtpErlangTuple rMessage = receive(); // receive message from mail box
                    System.out.println("message was receive...");
                    invokeSubscribeMethodByTopicName("test_topic", rMessage);
                    if (rMessage != null) // if message exist
                    {
                        String msgType = ((OtpErlangString) rMessage.elementAt(0)).stringValue(); // message type
                        switch (msgType) {
                            // message from subscribe topic
                            case "subscribe":
                                System.out.println("subscribe");
                                String topicName = ((OtpErlangString) rMessage.elementAt(1)).stringValue(); // get topic name
                                OtpErlangTuple subscribeMessage = (OtpErlangTuple) rMessage.elementAt(2); // get topic message

                                invokeSubscribeMethodByTopicName(topicName, subscribeMessage); // invoke callback method with message parameter
                                break;

                            // system message
                            case "sysMsg":
                                System.out.println("sysMsg");
                                break;
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    });

    //Class constructor
    public BotNode(Class<?> subscribeClass, String otpNodeName, String currenServerName, String coreNodeName,
                String otpMboxName, String registratorCoreNode, String publisherCoreNode, String coreCookie)
            throws Exception
    {
        //subscribeClass.getDeclaredConstructor(IBotMsgInterface.class).newInstance("1");
        set_otpNode(createNode(otpNodeName, coreCookie));
        set_otpMbox(createMbox(otpMboxName));
        this.otpNodeName = otpNodeName; // init node name
        this.otpMboxName = otpMboxName; // init mail box name
        this.currenServerName = currenServerName; // init current server name
        this.coreNodeName = coreNodeName; // init core node name
        //this.registratorCoreNode = registratorCoreNode; // DELETE
        this.publisherCoreNode = publisherCoreNode; // init publisher node name
        this.coreCookie = coreCookie; // init core node cookie

        this.subscribeDic = new HashMap<String, Set<CollectionSubscribe>>(); // init subscribers collection


        receiveMBoxMessageThread.start();
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


    public void subscribeToTopic(String topicName, String callbackMethodName, Class<?> callbackMethodMessageType) throws IllegalAccessException, NoSuchMethodException, InstantiationException {
        OtpErlangObject[] subscribeObject = new OtpErlangObject[4];
        subscribeObject[0] = new OtpErlangAtom("reg_subscr");
        subscribeObject[1] = new OtpErlangAtom(this.otpMboxName);
        subscribeObject[2] = new OtpErlangAtom(this.otpNodeName + "@" + this.currenServerName);
        subscribeObject[3] = new OtpErlangAtom(topicName);
        this.otpMbox.send(this.publisherCoreNode, this.coreNodeName, new OtpErlangTuple(subscribeObject));
        System.out.println("subscribeToTopic " + topicName);


        Method findMethod = getObjectMethod(callbackMethodName, callbackMethodMessageType);

        CollectionSubscribe collectionSubscribe = new CollectionSubscribe(callbackMethodName, findMethod, callbackMethodMessageType);

        synchronized (this.subscribeDic) { // lock access to map from other thread

            if (this.subscribeDic.containsKey(topicName)) // add subscribe information to dictionary, if
            {
                Set<CollectionSubscribe> collectionSubscribesSet = this.subscribeDic.get(topicName);

                if (!collectionSubscribesSet.contains(collectionSubscribe)) {
                    collectionSubscribesSet.add(collectionSubscribe);
                }

                this.subscribeDic.put(topicName, collectionSubscribesSet);

            } else {
                Set<CollectionSubscribe> collectionSubscribesSet = new HashSet<CollectionSubscribe>();
                collectionSubscribesSet.add(collectionSubscribe);
                this.subscribeDic.put(topicName, collectionSubscribesSet);
            }
        }
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
        //this.set_methodName(methodName); DELETE
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

    public OtpErlangTuple receive() throws IllegalAccessException, NoSuchMethodException, InvocationTargetException, InstantiationException {
        try {
            //OtpErlangTuple par = (OtpErlangTuple) this.otpMbox.receive();
            //invoke(par);
            return (OtpErlangTuple) this.otpMbox.receive();
        } catch (OtpErlangExit otpErlangExit) {
            otpErlangExit.printStackTrace();
        } catch (OtpErlangDecodeException e) {
            e.printStackTrace();
        }

        return null;
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

    //DELETE
    //public void set_methodName(String methodName)
    //{
    //    this.methodName = methodName;
    //}




    // ====== Invoke callback method start ======

    // Invoke method
    public void invoke(Object... parameters) throws InvocationTargetException, IllegalAccessException, NoSuchMethodException, InstantiationException {
        Method method = this.getClass().getMethod("method name", getParameterClasses(parameters)); // get link to method from current object
        method.invoke(this, parameters); // invoke callback method
    }

    public void invokeCallbackMethod(Method callbackMethod, Object... parameters) throws InvocationTargetException, IllegalAccessException {
        callbackMethod.invoke(this, parameters);
    }

    private void invokeSubscribeSet(Set<CollectionSubscribe> collectionSubscribeSet, Object... parameters) throws InvocationTargetException, IllegalAccessException {
        for(CollectionSubscribe collectionSubscribe : collectionSubscribeSet)
        {
            invokeCallbackMethod(collectionSubscribe.get_MethodObj(), parameters);
        }
    }

    private void invokeSubscribeMethodByTopicName(String topicName, Object... parameters) throws InvocationTargetException, IllegalAccessException {
        synchronized (this.subscribeDic) { // lock access to map from other thread
            invokeSubscribeSet(this.subscribeDic.get(topicName), parameters);
        }
    }

    private Method getObjectMethod(String methodName, Class<?> methodParams) throws IllegalAccessException, InstantiationException, NoSuchMethodException {
        OtpErlangObject[] subscribeObject = new OtpErlangObject[1];
        subscribeObject[0] = new OtpErlangString("reg_subscr");
        return this.getClass().getMethod(methodName, getParameterClasses(new OtpErlangTuple(subscribeObject)));
    }

    //Find method from current class
    private Class[] getParameterClasses(Object... parameters) {
        Class[] classes = new Class[parameters.length];
        for (int i=0; i < classes.length; i++) {
            classes[i] = parameters[i].getClass();
        }
        return classes;
    }

    // ====== Invoke callback method end ======
}