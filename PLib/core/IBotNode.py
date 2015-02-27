class IBotNode:

    def __init__(self, otpNodeName, currentServerName, coreNodeName,
                 otpMboxName, registratorCoreNode, publisherCoreNode, coreCoockes):

        self.currentServerName = currentServerName
        self.coreNodeName = coreNodeName
        self.registratorCoreNode = registratorCoreNode
        self.publisherCoreNode = publisherCoreNode
        self.coreCoockes = coreCoockes

        print "Constructor"


if __name__ == "__main__":
    ibot = IBotNode("ClientTest", "alexandr", "bar@alexandr", "Java", "java", "", "")
    print ibot.coreNodeName
    print ibot.registratorCoreNode
    print "Hellow"