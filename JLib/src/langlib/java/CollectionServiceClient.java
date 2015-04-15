package langlib.java;

import java.lang.reflect.Method;

/**
 * Created by alex on 4/16/15.
 */
public class CollectionServiceClient {
    private String serviceName;
    private Class<? extends IBotMsgInterface> serviceRequest;
    private Class<? extends IBotMsgInterface> serviceResponse;
    private Method serviceCallback;

    public CollectionServiceClient() {
    }

    public CollectionServiceClient(String serviceName,
                                   Class<? extends IBotMsgInterface> serviceRequest,
                                   Class<? extends IBotMsgInterface> serviceResponse,
                                   Method serviceCallback) {
        this.serviceName = serviceName;
        this.serviceRequest = serviceRequest;
        this.serviceResponse = serviceResponse;
        this.serviceCallback = serviceCallback;
    }

    public String getServiceName() {
        return serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
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

    public Method getServiceCallback() {
        return serviceCallback;
    }

    public void setServiceCallback(Method serviceCallback) {
        this.serviceCallback = serviceCallback;
    }
}
