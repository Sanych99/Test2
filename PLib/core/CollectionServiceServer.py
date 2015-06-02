class CollectionServiceServer:

    def __init__(self,
                 serviceName,
                 serviceRequest,
                 serviceResponse,
                 serviceCallback):
        self.serviceName = serviceName
        self.serviceRequest = serviceRequest
        self.serviceResponse = serviceResponse
        self.serviceCallback = serviceCallback

    def getServiceName(self):
        return self.serviceName

    def setServiceName(self, serviceName):
        self.serviceName = serviceName

    def getServiceRequest(self):
        return self.serviceRequest

    def setServiceRequest(self, serviceRequest):
        self.serviceRequest = serviceRequest

    def getServiceResponse(self):
        return self.serviceResponse

    def setServiceResponse(self, serviceResponse):
        self.serviceResponse = serviceResponse

    def getServiceCallback(self):
        return self.serviceCallback

    def setServiceCallback(self, serviceCallback):
        self.serviceCallback = serviceCallback