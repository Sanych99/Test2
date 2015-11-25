class CollectionServiceClient:

    def __init__(self,
                 serviceMethodName,
                 clientMethodCallbackName,
                 serviceRequest,
                 serviceResponse,
                 clientServiceCallback):
        self.serviceMethodName = serviceMethodName
        self.clientMethodCallbackName = clientMethodCallbackName
        self.serviceRequest = serviceRequest
        self.serviceResponse = serviceResponse
        self.clientServiceCallback = clientServiceCallback

    def getServiceMethodName(self):
        return self.serviceMethodName

    def setServiceMethodName(self, serviceMethodName):
        self.serviceMethodName = serviceMethodName

    def getServiceRequest(self):
        return self.serviceRequest

    def setServiceRequest(self, serviceRequest):
        self.serviceRequest = serviceRequest

    def getServiceResponse(self):
        return self.serviceResponse

    def setServiceResponse(self, serviceResponse):
        self.serviceResponse = serviceResponse

    def getClientServiceCallback(self):
        return self.clientServiceCallback

    def setClientServiceCallback(self, clientServiceCallback):
        self.clientServiceCallback = clientServiceCallback

    def getServiceMBox(self):
        return self.serviceMBox

    def setServiceMBox(self, serviceMBox):
        self.serviceMBox = serviceMBox

    def getServiceNode(self):
        return self.serviceNode

    def setServiceNode(self, serviceNode):
        self.serviceNode = serviceNode

    def getClientMethodCallbackName(self):
        return self.clientMethodCallbackName

    def setClientMethodCallbackName(self, clientMethodCallbackName):
        self.clientMethodCallbackName = clientMethodCallbackName