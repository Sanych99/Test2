#!/usr/bin/env python

import unittest
import subprocess
import time
import pyerl

class RPCTest(unittest.TestCase):
    def setUp(self): pass
    #ret = subprocess.call(["erlc", "pingpong.erl"])
    #self.assertEqual(ret, 0)
    #cmd = 'erl -noshell -setcookie "TESTCOOKIE" -sname node2@localhost -s pingpong start'
    #self.proc = subprocess.Popen(cmd, shell=True)

    def tearDown(self): pass
    #ret = subprocess.call(["kill", str(self.proc.pid)])
    #pyerl.eterm_release()
    #allocated, freed = pyerl.eterm_statistics()
    #self.assertEqual(allocated, 0)
    #self.assertEqual(freed, 0)
    #self.proc.wait()

    def test_rpc(self):
        host = "alex-K55A"
        name = "test"
        node = name + "@" + host
        cookie = "jv"
        ret = pyerl.connect_xinit(host, name, node, "127.0.0.1", cookie, 1)
        #ret = pyerl.connect_init(1, cookie, 1)
        self.assertEqual(ret, 1);
        retry = 0
        while True:
            time.sleep(1)
            sock = pyerl.xconnect("127.0.0.1", "core")
            #sock = pyerl.connect("core@alex-K55A")
            if sock > 0: break
            if retry > 3: self.fail()
            retry += 1

        self.assertEqual(sock > 0, True)
        atom = pyerl.mk_atom("ping")
        args = pyerl.mk_list([atom]);
        eterm = pyerl.rpc(sock, "pingpong", "ping", args);
        #pyerl.rpc(sock, "ibot_core_srv_project_info_loader", "load_core_config", [])
        #erlang:send({ibot_nodes_srv_topic, 'core@alex-K55A'},{"hello"}).
        to = pyerl.mk_tuple((pyerl.mk_atom("ibot_nodes_srv_topic"), pyerl.mk_atom("core@alex-K55A")))
        msg = pyerl.mk_tuple((pyerl.mk_atom("hello"), pyerl.mk_atom("hello")))
        ls = pyerl.mk_list([to, msg])
        print pyerl.reg_send(sock, "ibot_nodes_srv_topic", msg)
        print str(pyerl.xreceive_msg(sock))
        #pyerl.rpc(sock, "erlang", "send", ls);
        #while True: print "123"
        ret = pyerl.close_connection(sock);
        #self.assertEqual(ret, 0);
        #self.assertEqual(eterm.type, pyerl.ATOM);
        #self.assertEqual(eterm.is_atom(), True);
        #self.assertEqual(str(eterm), "pong");

if __name__ == '__main__':
    unittest.main()