class CollectionSubscribe:

    def __init__(self, methodCallBack, methodMessageType):

        self.methodCallBack = methodCallBack
        self.methodMessageType = methodMessageType

    def getMethodCallBack(self):
        return self.methodCallBack

    def getMethodMessageType(self):
        return self.methodMessageType