package langlib.java;

import java.lang.reflect.Method;

/**
 * Created by alex on 4/16/15.
 */
public class CollectionServiceClient {
    private String clientMethodName;
    private Class<? extends IBotMsgInterface> serviceRequest;
    private Class<? extends IBotMsgInterface> serviceResponse;
    private Method clientServiceCallback;

    public CollectionServiceClient() {
    }

    public CollectionServiceClient(String clientMethodName,
                                   Class<? extends IBotMsgInterface> serviceRequest,
                                   Class<? extends IBotMsgInterface> serviceResponse,
                                   Method clientServiceCallback) {
        this.clientMethodName = clientMethodName;
        this.serviceRequest = serviceRequest;
        this.serviceResponse = serviceResponse;
        this.clientServiceCallback = clientServiceCallback;
    }

    public String getClientMethodName() {
        return clientMethodName;
    }

    public void setClientMethodName(String clientMethodName) {
        this.clientMethodName = clientMethodName;
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
}
