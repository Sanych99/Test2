import pyerl
import time

class BotNode:

    def __init__(self, otpNodeName, currentServerName, coreNodeName,
                 otpMboxName, registratorCoreNode, publisherCoreNode, coreCoockie):

        self.otpNodeName = otpNodeName
        self.currentServerName = currentServerName
        self.coreNodeName = coreNodeName
        self.registratorCoreNode = registratorCoreNode
        self.otpMboxName = otpMboxName
        self.publisherCoreNode = publisherCoreNode
        self.coreCoockie = coreCoockie

        self.currentNode =

        print "Constructor"

    def createNode(self, otpNodeName, currentServerName):
        return pyerl.connect_xinit(currentServerName, otpNodeName, otpNodeName + "@" + currentServerName, "127.0.0.1", cookie, 1)


if __name__ == "__main__":
    ibot = BotNode("ClientTest", "alexandr", "bar@alexandr", "Java", "java", "", "")


    host = "localhost"
    name = "test"
    node = name + "@" + host
    cookie = "jv"
    ret = pyerl.connect_xinit(host, name, node, "127.0.0.1", cookie, 1)
    #self.assertEqual(ret, 1);
    retry = 0
    while True:
        while True:
            time.sleep(1)
            sock = pyerl.xconnect("127.0.0.1", "node3")
            if sock > 0: break
            if retry > 3: break
            retry += 1
        #self.assertEqual(sock > 0, True)
        atom = pyerl.mk_atom("ping")
        args = pyerl.mk_list([atom]);
        eterm = pyerl.rpc(sock, "pingpong", "ping", args);
        print eterm
        ret = pyerl.close_connection(sock);
        #self.assertEqual(ret, 0);
        #self.assertEqual(eterm.type, pyerl.ATOM);
        #self.assertEqual(eterm.is_atom(), True);
        #self.assertEqual(str(eterm), "pong");

    print ibot.coreNodeName
    print ibot.registratorCoreNode
    print "Hellow"