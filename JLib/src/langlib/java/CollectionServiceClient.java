package langlib.java;

import com.ericsson.otp.erlang.OtpErlangAtom;

import java.lang.reflect.Method;

/**
 * Created by alex on 4/16/15.
 */
public class CollectionServiceClient {
    private String serviceMethodName;
    private Class<? extends IBotMsgInterface> serviceRequest;
    private Class<? extends IBotMsgInterface> serviceResponse;
    private Method clientServiceCallback;
    private OtpErlangAtom serviceMBox;
    private OtpErlangAtom serviceNode;

    public CollectionServiceClient() {
    }

    public CollectionServiceClient(String serviceMethodName,
                                   Class<? extends IBotMsgInterface> serviceRequest,
                                   Class<? extends IBotMsgInterface> serviceResponse,
                                   Method clientServiceCallback) {
        this.serviceMethodName = serviceMethodName;
        this.serviceRequest = serviceRequest;
        this.serviceResponse = serviceResponse;
        this.clientServiceCallback = clientServiceCallback;
    }

    public String getServiceMethodName() {
        return serviceMethodName;
    }

    public void setServiceMethodName(String serviceMethodName) {
        this.serviceMethodName = serviceMethodName;
    }

    public Class<? extends IBotMsgInterface> getServiceRequest() {
        return serviceRequest;
    }

    public void setServiceRequest(Class<? extends IBotMsgInterface> serviceRequest) {
        this.serviceRequest = serviceRequest;
    }

    public Class<? extends IBotMsgInterface> getServiceResponse() {
        return serviceResponse;
    }

    public void setServiceResponse(Class<? extends IBotMsgInterface> serviceResponse) {
        this.serviceResponse = serviceResponse;
    }

    public Method getClientServiceCallback() {
        return clientServiceCallback;
    }

    public void setClientServiceCallback(Method clientServiceCallback) {
        this.clientServiceCallback = clientServiceCallback;
    }

    public OtpErlangAtom getServiceMBox() {
        return serviceMBox;
    }

    public void setServiceMBox(OtpErlangAtom serviceMBox) {
        this.serviceMBox = serviceMBox;
    }

    public OtpErlangAtom getServiceNode() {
        return serviceNode;
    }

    public void setServiceNode(OtpErlangAtom serviceNode) {
        this.serviceNode = serviceNode;
    }
}
