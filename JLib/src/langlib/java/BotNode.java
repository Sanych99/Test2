package langlib.java;

import com.ericsson.otp.erlang.*;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.*;

/**
 * Java Otp Node Connector Class
 */
public abstract class BotNode implements IBotNode {

    //====== Константы / Constants Start ======

    public final String LOG_TYPE_MESSAGE = "Message";
    public final String LOG_TYPE_WARNING = "Warning";
    public final String LOG_TYPE_ERROR = "Error";

    private OtpErlangTuple logSenderName;

    //====== Константы / Constants End ======

    /**
     * Current server name machine name
     */
    private String currentServerName;

    /**
     * Java Otp node
     */
    private OtpNode otpNode;

    /**
     * Java Otp node name
     */
    private String otpNodeName;

    /**
     * Otp node mail box
     */
    private OtpMbox otpMboxAsync;

    /**
     * Otp node mail box name
     */
    private String otpMboxNameAsync;

    private OtpMbox otpMbox;

    private String otpMboxName;

    /**
     * Server name core@machine_name
     */
    private String coreNodeName;

    /**
     * Core message publisher module
     */
    private String publisherCoreNode;

    private String serviceCoreNode;

    private String connectorCodeNode;

    private String uiInteractionNode;

    private String loggerInteractionNode;

    /**
     * Core node cookies
     */
    private String coreCookie;


    /**
     * Subscribe callback methods collection
     */
    private Map<String, Set<CollectionSubscribe>> subscribeDic;

    /**
     * Async client services collection
     */
    private Map<String, CollectionServiceClient> asyncServiceClientDic;

    /**
     * Async server services collection
     */
    private Map<String, CollectionServiceServer> asyncServiceServerDic;

    /**
     * Operation in action
     */
    private volatile boolean coreIsActive;
    /**
     * Operation in action locker
     */
    private Object coreIsActiveLocker;

    /**
     * Node has monitor
     */
    private boolean isMonitor;


    /**
     * Receive message thread from node mailbox
     */
    private Thread receiveMBoxMessageThread = new Thread(new Runnable() {
        public void run()
        {
            while (ok()) {
                try {
                    OtpErlangTuple rMessage = receive(); // receive message from mail box

                    if (rMessage != null) // if message exist
                    {
                        String msgType = ((OtpErlangAtom) rMessage.elementAt(0)).toString(); // message type
                        switch (msgType) {
                            // message from subscribe topic
                            case "subscribe":
                                String topicName = ((OtpErlangAtom) rMessage.elementAt(1)).toString(); // get topic name
                                OtpErlangTuple subscribeMessage = (OtpErlangTuple) rMessage.elementAt(2); // get topic message

                                invokeSubscribeMethodByTopicName(topicName, subscribeMessage); // invoke callback method with message parameter

                                logMessage(String.format("node with name: %1$s received subscribe from topic %2$s", otpNodeName, topicName));
                                break;

                            case "call_service_method":
                                String serviceMethodName = ((OtpErlangString) rMessage.elementAt(1)).stringValue();
                                OtpErlangAtom clientMailBoxName = (OtpErlangAtom) rMessage.elementAt(2);
                                OtpErlangAtom clientNodeFullName = (OtpErlangAtom) rMessage.elementAt(3);
                                OtpErlangString clientMethodNameCallback = (OtpErlangString) rMessage.elementAt(4);
                                OtpErlangTuple requestMessageFromClient = (OtpErlangTuple) rMessage.elementAt(5);

                                IBotMsgInterface response = invokeServerServiceMethod(serviceMethodName, requestMessageFromClient);

                                OtpErlangObject[] serviceResponseObject = new OtpErlangObject[7];
                                serviceResponseObject[0] = new OtpErlangAtom("response_service_message");
                                serviceResponseObject[1] = (OtpErlangString) rMessage.elementAt(1);
                                serviceResponseObject[2] = clientMailBoxName;
                                serviceResponseObject[3] = clientNodeFullName;
                                serviceResponseObject[4] = clientMethodNameCallback;
                                serviceResponseObject[5] = requestMessageFromClient;
                                serviceResponseObject[6] = response.get_Msg();

                                otpMboxAsync.send(serviceCoreNode, coreNodeName, new OtpErlangTuple(serviceResponseObject));

                                logMessage(String.format("node with name: %1$s call_service_method %2$s", otpNodeName, serviceMethodName));
                                break;

                            case "call_client_service_callback_method":
                                String invokedServiceMethodName = ((OtpErlangString) rMessage.elementAt(1)).stringValue();
                                String clientMethodName = ((OtpErlangString) rMessage.elementAt(2)).stringValue();
                                OtpErlangTuple requestMessage = (OtpErlangTuple) rMessage.elementAt(3);
                                OtpErlangTuple responseMessage = (OtpErlangTuple) rMessage.elementAt(4);
                                invokeClientServiceMethodCallback(invokedServiceMethodName, requestMessage, responseMessage);

                                logMessage(String.format("node with name: %1$s call_client_service_callback_method %2$s from service: %3$s",
                                        otpNodeName, clientMethodName, invokedServiceMethodName));
                                break;

                            // system message
                            case "system":
                                String systemAction = ((OtpErlangAtom) rMessage.elementAt(1)).toString(); // system action

                                switch (systemAction) {
                                    case "exit" : set_coreIsActive(false);
                                        monitorStop(); // stop monitor is exist

                                        logMessage(String.format("node with name: %1$s exit message received", otpNodeName));
                                        break;

                                    case "monitor" : //monitor actions
                                        String monitorAction = ((OtpErlangString) rMessage.elementAt(2)).stringValue();
                                        switch (monitorAction) {
                                            // when monitor was started
                                            case "monitorIsStart" : isMonitor = true;
                                                logMessage(String.format("node with name: %1$s monitor start message", otpNodeName));
                                                break;
                                            default:isMonitor = false;
                                                logMessage(String.format("node with name: %1$s monitor stop message", otpNodeName));
                                                break;
                                        }
                                }
                                break;
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            logMessage(String.format("node with name: %1$s finished work...", otpNodeName));
        }
    });

    /**
     * Class constructor
     * @param args Init parameters
     * @throws Exception
     */
    public BotNode(String[] args)
            throws Exception
    {
        this.otpNodeName = args[0]; // init node name
        this.currentServerName = args[1]; // init current server name
        this.coreNodeName = args[2]; // init core node name
        this.otpMboxNameAsync = args[0] + "_MBoxAsync"; // init asynchronous mail box name
        this.otpMboxName = args[0] + "_MBox"; // init mail box name
        this.connectorCodeNode = args[3];  // init connector node name
        this.publisherCoreNode = args[4]; // init publisher node name
        this.serviceCoreNode = args[5]; // init service node name
        this.uiInteractionNode = args[6]; // init ui interaction node name
        this.loggerInteractionNode = args[7]; // init message logger node name
        this.coreCookie = args[8]; // init core node cookie

        this.subscribeDic = new HashMap<>(); // init subscribers collection

        this.asyncServiceClientDic = new HashMap<>();
        this.asyncServiceServerDic = new HashMap<>();

        setOtpNode(createNode(this.otpNodeName + "@" + this.currentServerName, coreCookie));
        setOtpMboxAsync(createMbox(otpMboxNameAsync));
        setOtpMbox(createMbox(otpMboxName));

        this.coreIsActive = true;
        this.coreIsActiveLocker = new Object();

        //идентификатор отправителя сообщения для лога / message log sender identification
        OtpErlangObject[] logSenderObject = new OtpErlangObject[2];
        logSenderObject[0] = new OtpErlangString(this.otpNodeName);
        logSenderObject[1] = new OtpErlangString(this.coreNodeName);
        this.logSenderName = new OtpErlangTuple(logSenderObject);

        receiveMBoxMessageThread.start();

        registerAdditionalNodeInfo();

        logMessage(String.format("node with name: %1$s start node", otpNodeName));
    }


    /* ====== Creation Methods Start ====== */

    /**
     * OtpNode create method
     * @param otpNodeName Node name
     * @param coreCookies Core node cookie
     * @return Node object
     * @throws Exception
     */
    public OtpNode createNode(String otpNodeName, String coreCookies) throws Exception
    {
        return new OtpNode(otpNodeName, coreCookies);
    }

    /**
     * OtpMbox create method
     * @param otpMboxName Node main box name
     * @return Node mail box object
     */
    private OtpMbox createMbox(String otpMboxName)
    {
        return getOtpNode().createMbox(otpMboxName);
    }


    private void registerAdditionalNodeInfo()
    {
        OtpErlangObject[] infoObject = new OtpErlangObject[3];
        infoObject[0] = new OtpErlangAtom("register_additional_node_info");
        infoObject[1] = new OtpErlangAtom(this.otpNodeName);

        OtpErlangObject[] innerObject = new OtpErlangObject[2];
        innerObject[0] = new OtpErlangString(this.coreNodeName);
        innerObject[1] = new OtpErlangAtom(this.coreNodeName);

        infoObject[2] = new OtpErlangTuple(innerObject);
        this.otpMboxAsync.send(this.connectorCodeNode, this.coreNodeName, new OtpErlangTuple(infoObject));
    }


    /**
     * Subscribe node to topic
     * @param topicName Topic name
     * @param callbackMethodName Callback method name for invoke on message
     * @param callbackMethodMessageType Callback message type class
     * @throws IllegalAccessException
     * @throws NoSuchMethodException
     * @throws InstantiationException
     */
    public void subscribeToTopic(String topicName, String callbackMethodName, Class<? extends IBotMsgInterface> callbackMethodMessageType) throws IllegalAccessException, NoSuchMethodException, InstantiationException {
        OtpErlangObject[] subscribeObject = new OtpErlangObject[4];
        subscribeObject[0] = new OtpErlangAtom("reg_subscr");
        subscribeObject[1] = new OtpErlangAtom(this.otpMboxNameAsync);
        subscribeObject[2] = new OtpErlangAtom(this.otpNodeName + "@" + this.currentServerName);
        subscribeObject[3] = new OtpErlangAtom(topicName);
        this.otpMboxAsync.send(this.publisherCoreNode, this.coreNodeName, new OtpErlangTuple(subscribeObject));

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

        logMessage(String.format("node with name: %1$s subscribe to topic: %2$s", otpNodeName, topicName));
    }

    /* ====== Creation Methods End ====== */


    /* ====== Action Methods Start ====== */

    //Message publish method
    //public void publishMsg(OtpErlangTuple tuple)
    //{
    //    this.otpMboxAsync.send(this.publisherCoreNode, this.coreNodeName, tuple);
    //}

    public void publishMessage(String topicName, Object msg) throws Exception
    {
        IBotMsgInterface msgIn = (IBotMsgInterface)msg;

        OtpErlangObject[] subscribeObject = new OtpErlangObject[5];
        subscribeObject[0] = new OtpErlangAtom("broadcast");
        subscribeObject[1] = new OtpErlangAtom(this.otpMboxNameAsync);
        subscribeObject[2] = new OtpErlangAtom(this.otpNodeName + "@" + this.currentServerName);
        subscribeObject[3] = new OtpErlangAtom(topicName);
        subscribeObject[4] = msgIn.get_Msg();
        this.otpMboxAsync.send(this.publisherCoreNode, this.coreNodeName, new OtpErlangTuple(subscribeObject));

        logMessage(String.format("node with name: %1$s publish method to topic: %2$s", otpNodeName, topicName));
    }


    /**
     * Start other node from project
     * @param nodeName Node name
     * @throws Exception
     */
    public void startProjectNode(String nodeName) throws Exception
    {
        OtpErlangObject[] subscribeObject = new OtpErlangObject[2];
        subscribeObject[0] = new OtpErlangAtom("start_node_from_node");
        subscribeObject[1] = new OtpErlangString(nodeName);
        this.otpMboxAsync.send(this.connectorCodeNode, this.coreNodeName, new OtpErlangTuple(subscribeObject));

        logMessage(String.format("node with name: %1$s start project node: %2$s", otpNodeName, nodeName));
    }

    /**
     * Stop other node from project
     * @param nodeName Node name
     * @throws Exception
     */
    public void stopProjectNode(String nodeName) throws Exception
    {
        OtpErlangObject[] subscribeObject = new OtpErlangObject[2];
        subscribeObject[0] = new OtpErlangAtom("stop_node_from_node");
        subscribeObject[1] = new OtpErlangString(nodeName);
        this.otpMboxAsync.send(this.connectorCodeNode, this.coreNodeName, new OtpErlangTuple(subscribeObject));

        logMessage(String.format("node with name: %1$s stop project node: %2$s", otpNodeName, nodeName));
    }


    public void sendMessageToUI(Object msg, String msgClassName) throws Exception
    {
        this.sendMessageToUI(msg, msgClassName, "none");
    }

    public void sendMessageToUI(Object msg, String msgClassName, String additionalInfo) throws Exception
    {
        IBotMsgInterface msgIn = (IBotMsgInterface)msg;

        OtpErlangObject[] subscribeObject = new OtpErlangObject[5];
        subscribeObject[0] = new OtpErlangAtom("send_data_to_ui");
        subscribeObject[1] = new OtpErlangAtom(this.otpNodeName);
        subscribeObject[2] = new OtpErlangAtom(msgClassName);
        subscribeObject[3] = new OtpErlangAtom(additionalInfo);
        subscribeObject[4] = msgIn.get_Msg();
        this.otpMboxAsync.send(this.uiInteractionNode, this.coreNodeName, new OtpErlangTuple(subscribeObject));
        logMessage(String.format("node with name: %1$s send message to ui: %2$s", otpNodeName, msgClassName));
    }


    //====== Логгирование / Logging Start======

    public void logMessage(String MessageText) {
        this.logMessage(LOG_TYPE_MESSAGE, MessageText);
    }

    public void logWarning(String MessageText) {
        this.logMessage(LOG_TYPE_WARNING, MessageText);
    }

    public void logError(String MessageText) {
        this.logMessage(LOG_TYPE_ERROR, MessageText);
    }

    private void logMessage(String MessageType, String MessageText) {
        OtpErlangObject[] loggerObject = new OtpErlangObject[4];
        loggerObject[0] = new OtpErlangAtom("node_logger_message");
        loggerObject[1] = new OtpErlangString(MessageType);
        loggerObject[2] = new OtpErlangString(MessageText);
        loggerObject[3] = this.logSenderName;
        this.otpMboxAsync.send(this.loggerInteractionNode, this.coreNodeName, new OtpErlangTuple(loggerObject));
    }

    //====== Логгирование / Logging End======

    //public void subscribe(String methodName)
    //{
    //    //this.set_methodName(methodName); DELETE
    //    try {
    //        receive();
    //    } catch (IllegalAccessException e) {
    //        e.printStackTrace();
    //    } catch (NoSuchMethodException e) {
    //        e.printStackTrace();
    //    } catch (InvocationTargetException e) {
    //        e.printStackTrace();
    //    } catch (InstantiationException e) {
    //        e.printStackTrace();
    //    }
    //}

    public OtpErlangTuple receive() throws IllegalAccessException, NoSuchMethodException, InvocationTargetException, InstantiationException {
        try {
            //OtpErlangTuple par = (OtpErlangTuple) this.otpMboxAsync.receive();
            //invoke(par);
            return (OtpErlangTuple) this.otpMboxAsync.receive();
        } catch (OtpErlangExit otpErlangExit) {
            otpErlangExit.printStackTrace();
        } catch (OtpErlangDecodeException e) {
            e.printStackTrace();
        }

        return null;
    }


    /**
     * Call sync service
     * @param serviceMethodName call service name
     * @param req Request object
     * @param <TResp> Request object type
     * @param <TReq> Response object type
     * @return Response object
     */
    public <TResp extends IBotMsgInterface, TReq extends IBotMsgInterface> TResp syncServiceRequest(String serviceMethodName, TReq req) {
        return null;
    }



    public void asyncServiceRequest(String serviceMethodName, IBotMsgInterface req) throws Exception {

        synchronized (this.asyncServiceClientDic) {
            CollectionServiceClient serviceClient = this.asyncServiceClientDic.get(serviceMethodName);

            OtpErlangObject[] requestServiceObject = new OtpErlangObject[6];
            requestServiceObject[0] = new OtpErlangAtom("request_service_message");
            requestServiceObject[1] = new OtpErlangAtom(this.otpMboxNameAsync);
            requestServiceObject[2] = new OtpErlangAtom(this.otpNodeName + "@" + this.currentServerName);
            requestServiceObject[3] = new OtpErlangString(serviceClient.getClientMethodCallbackName());
            requestServiceObject[4] = new OtpErlangString(serviceMethodName);
            requestServiceObject[5] = req.get_Msg();

            this.otpMboxAsync.send(this.serviceCoreNode, this.coreNodeName, new OtpErlangTuple(requestServiceObject));
        }

        logMessage(String.format("node with name: %1$s async request server service method: %2$s", otpNodeName, serviceMethodName));
    }



    //Getters and Setters

    //otpNode Getter
    public OtpNode getOtpNode()
    {
        return this.otpNode;
    }

    //otpNode Setter
    private void setOtpNode(OtpNode otpNode)
    {
        this.otpNode = otpNode;
    }


    //otpMboxAsync Getter
    public OtpMbox getOtpMboxAsync()
    {
        return  this.otpMboxAsync;
    }

    //otpMboxAsync Setter
    private void setOtpMboxAsync(OtpMbox otpMbox)
    {
        this.otpMboxAsync = otpMbox;
    }

    public OtpMbox getOtpMbox() {
        return otpMbox;
    }

    public void setOtpMbox(OtpMbox otpMbox) {
        this.otpMbox = otpMbox;
    }

    public String getOtpMboxName() {
        return otpMboxName;
    }

    public void setOtpMboxName(String otpMboxName) {
        this.otpMboxName = otpMboxName;
    }

    public boolean ok() {
        boolean isOk;
        synchronized (coreIsActiveLocker)
        {
            isOk = this.coreIsActive;
        }
        return isOk;
    }

    public void set_coreIsActive(boolean isActive) {
        synchronized (coreIsActiveLocker) {
            this.coreIsActive = isActive;
        }
    }

    /* ====== Action Methods End ====== */




    /* ====== Service methods Start ====== */

    public void registerServiceClient(String serverServiceMethodName, String clientServiceMethodName,
                                  Class<? extends IBotMsgInterface> serviceRequest, Class<? extends IBotMsgInterface> serviceResponse) throws IllegalAccessException, NoSuchMethodException, InstantiationException {

        OtpErlangObject[] clientServiceObject = new OtpErlangObject[4];
        clientServiceObject[0] = new OtpErlangAtom("reg_async_client_service_callback");
        clientServiceObject[1] = new OtpErlangAtom(this.otpMboxNameAsync);
        clientServiceObject[2] = new OtpErlangAtom(this.otpNodeName + "@" + this.currentServerName);
        clientServiceObject[3] = new OtpErlangAtom(serverServiceMethodName);
        this.otpMboxAsync.send(this.serviceCoreNode, this.coreNodeName, new OtpErlangTuple(clientServiceObject));

        synchronized (this.asyncServiceClientDic) {

            Method serviceMethod = getServiceClientCallbackObjectMethod(clientServiceMethodName, serviceRequest, serviceResponse);

            if(serviceMethod != null) {

                CollectionServiceClient serviceClient = new CollectionServiceClient(serverServiceMethodName, clientServiceMethodName,
                        serviceRequest, serviceResponse, serviceMethod);

                this.asyncServiceClientDic.put(serverServiceMethodName, serviceClient);
            }
        }

        logMessage(String.format("node with name: %1$s registered client service method: %2$s to service: %3$s",
                otpNodeName, clientServiceMethodName, serverServiceMethodName));
    }


    public void registerServiceServer(String serviceMethodName, Class<? extends IBotMsgInterface> requestType, Class<? extends IBotMsgInterface> responseType) throws IllegalAccessException, NoSuchMethodException, InstantiationException {
        OtpErlangObject[] clientServiceObject = new OtpErlangObject[4];
        clientServiceObject[0] = new OtpErlangAtom("reg_async_server_service_callback");
        clientServiceObject[1] = new OtpErlangAtom(this.otpMboxNameAsync);
        clientServiceObject[2] = new OtpErlangAtom(this.otpNodeName + "@" + this.currentServerName);
        clientServiceObject[3] = new OtpErlangString(serviceMethodName);
        this.otpMboxAsync.send(this.serviceCoreNode, this.coreNodeName, new OtpErlangTuple(clientServiceObject));

        Method serviceMethod = getServiceObjectMethod(serviceMethodName, requestType);

        if (serviceMethod != null) {
            CollectionServiceServer serviceServer = new CollectionServiceServer(serviceMethodName, requestType, responseType, serviceMethod);
            this.asyncServiceServerDic.put(serviceMethodName, serviceServer);
        }

        logMessage(String.format("node with name: %1$s registered server service method: %2$s",
                otpNodeName, serviceMethodName));
    }

    /* ====== Service methods End ====== */





    /* ====== Monitor start / stop functions Start ====== */

    /**
     * Start node monitor
     */
    public void monitorStart() {
        if(!isMonitor) {
            OtpErlangObject[] monitorObject = new OtpErlangObject[5];
            monitorObject[0] = new OtpErlangAtom("start_monitor");
            monitorObject[1] = new OtpErlangString(this.otpNodeName);
            monitorObject[2] = new OtpErlangAtom(this.otpNodeName);
            monitorObject[3] = new OtpErlangAtom(this.currentServerName);
            monitorObject[4] = new OtpErlangAtom(this.otpNodeName + "@" + this.currentServerName);
            this.otpMboxAsync.send(this.connectorCodeNode, this.coreNodeName, new OtpErlangTuple(monitorObject));

            isMonitor = true;

            logMessage(String.format("node with name: %1$s start monitor", otpNodeName));
        }
    }

    /**
     * Stop node monitor
     */
    public void monitorStop() {
        if(isMonitor) {
            OtpErlangObject[] monitorObject = new OtpErlangObject[2];
            monitorObject[0] = new OtpErlangAtom("stop_monitor");
            monitorObject[1] = new OtpErlangString(this.otpNodeName);
            this.otpMboxAsync.send(this.connectorCodeNode, this.coreNodeName, new OtpErlangTuple(monitorObject));
        }

        isMonitor = false;

        logMessage(String.format("node with name: %1$s stop monitor", otpNodeName));
    }

    /* ====== Monitor start / stop functions End ====== */





    /* ====== Invoke callback method Start ====== */

    // Invoke method
    public void invoke(Object... parameters) throws InvocationTargetException, IllegalAccessException, NoSuchMethodException, InstantiationException {
        Method method = this.getClass().getMethod("method name", getParameterClasses(parameters)); // get link to method from current object
        method.invoke(this, parameters); // invoke callback method
    }

    public void invokeCallbackMethod(Method callbackMethod, Class<? extends IBotMsgInterface> obj, Object... parameters) throws InvocationTargetException, IllegalAccessException, InstantiationException, NoSuchMethodException {
        IBotMsgInterface msg = obj.getDeclaredConstructor(OtpErlangTuple.class).newInstance(parameters);
        callbackMethod.invoke(this, msg);
    }

    /**
     * Invoke all methods subscribed to topic
     * @param collectionSubscribeSet Subscribed methods list
     * @param parameters method parameter
     * @throws InvocationTargetException
     * @throws IllegalAccessException
     * @throws InstantiationException
     */
    private void invokeSubscribeSet(Set<CollectionSubscribe> collectionSubscribeSet, Object... parameters) throws InvocationTargetException, IllegalAccessException, InstantiationException, NoSuchMethodException {
        for(CollectionSubscribe collectionSubscribe : collectionSubscribeSet)
        {
            invokeCallbackMethod(collectionSubscribe.get_MethodObj(), collectionSubscribe.get_MethodMessageType(), parameters);
        }
    }

    /**
     * Invoke callback method subscribed to topic
     * @param topicName Topic name
     * @param parameters Method parameter
     * @throws InvocationTargetException
     * @throws IllegalAccessException
     * @throws InstantiationException
     */
    private void invokeSubscribeMethodByTopicName(String topicName, Object... parameters) throws InvocationTargetException, IllegalAccessException, InstantiationException, NoSuchMethodException {
        synchronized (this.subscribeDic) { // lock access to map from other thread
            invokeSubscribeSet(this.subscribeDic.get(topicName), parameters);
        }
    }

    /**
     * Find callback method
     * @param methodName Method name
     * @param methodParams Method parameters
     * @return Callback method link
     * @throws IllegalAccessException
     * @throws InstantiationException
     * @throws NoSuchMethodException
     */
    private Method getObjectMethod(String methodName, Class<?> methodParams) throws IllegalAccessException, InstantiationException, NoSuchMethodException {
        IBotMsgInterface obj = (IBotMsgInterface) methodParams.newInstance();
        return this.getClass().getMethod(methodName, getParameterClasses(obj));
    }

    /**
     * Find callback service method
     * @param methodName Method name
     * @param methodParamRequest Method request type
     * @param methodParamResponse Method response type
     * @return Callback method link
     * @throws IllegalAccessException
     * @throws InstantiationException
     * @throws NoSuchMethodException
     */
    private Method getServiceClientCallbackObjectMethod(String methodName, Class<?> methodParamRequest, Class<?> methodParamResponse) throws IllegalAccessException, InstantiationException, NoSuchMethodException {
        IBotMsgInterface objReq = (IBotMsgInterface) methodParamRequest.newInstance();
        IBotMsgInterface objResp = (IBotMsgInterface) methodParamResponse.newInstance();
        return this.getClass().getMethod(methodName, getParameterClasses(objReq, objResp));
    }


    private Method getServiceObjectMethod(String methodName, Class<?> methodParamRequest) throws IllegalAccessException, InstantiationException, NoSuchMethodException {
        IBotMsgInterface objReq = (IBotMsgInterface) methodParamRequest.newInstance();
        return this.getClass().getMethod(methodName, getParameterClasses(objReq));
    }

    /**
     * Find method from current class
     * @param parameters Method parameters
     * @return Class
     */
    private Class[] getParameterClasses(Object... parameters) {
        Class[] classes = new Class[parameters.length];
        for (int i=0; i < classes.length; i++) {
            classes[i] = parameters[i].getClass();
        }
        return classes;
    }

    /* ====== Invoke callback method End ====== */

    private void invokeClientServiceMethodCallback(String invokedServiceMethodName, Object... parameters)
            throws InvocationTargetException, IllegalAccessException, NoSuchMethodException, InstantiationException {
        CollectionServiceClient client = this.asyncServiceClientDic.get(invokedServiceMethodName);
        if(client!=null) {
            IBotMsgInterface request = client.getServiceRequest().getDeclaredConstructor(OtpErlangTuple.class).newInstance(parameters[0]);
            IBotMsgInterface response = client.getServiceResponse().getDeclaredConstructor(OtpErlangTuple.class).newInstance(parameters[1]);
            client.getClientServiceCallback().invoke(this, request, response);
        }
    }

    private <T extends IBotMsgInterface> T invokeServerServiceMethod(String serviceMethodName, Object requestMessage) throws InvocationTargetException, IllegalAccessException, NoSuchMethodException, InstantiationException {
        CollectionServiceServer serviceServer = this.asyncServiceServerDic.get(serviceMethodName);
        IBotMsgInterface request = serviceServer.getServiceRequest().getDeclaredConstructor(OtpErlangTuple.class).newInstance(requestMessage);
        return (T) serviceServer.getServiceCallback().invoke(this, request);
    }
}