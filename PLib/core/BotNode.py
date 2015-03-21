import pyerl
import time

class BotNode:

    def __init__(self, otpNodeName, currentServerName, coreNodeName,
                 otpMboxName, registratorCoreNode, publisherCoreNode, coreCoockie):

        self.currentServerName = currentServerName
        self.coreNodeName = coreNodeName
        self.registratorCoreNode = registratorCoreNode
        self.publisherCoreNode = publisherCoreNode
        self.coreCoockie = coreCoockie

        print "Constructor"


if __name__ == "__main__":
    ibot = BotNode("ClientTest", "alexandr", "bar@alexandr", "Java", "java", "", "")


    host = "127.0.0.1"
    name = "test"
    node = name + "@" + host
    cookie = "jv"
    ret = pyerl.connect_xinit(host, name, node, "127.0.0.1", cookie, 1)
    retry = 0
    while True:
        time.sleep(1)
        sock = pyerl.xconnect("127.0.0.1", "node1")
        if sock > 0: break
        retry += 1
    atom = pyerl.mk_atom("ping")
    args = pyerl.mk_list([atom]);
    eterm = pyerl.rpc(sock, "pingpong", "ping", args);
    ret = pyerl.close_connection(sock);


    print ibot.coreNodeName
    print ibot.registratorCoreNode
    print "Hellow"