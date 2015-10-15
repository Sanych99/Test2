// A simple program that computes the square root of a number
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <iostream>
#include <string>
#include "BotNode.h"

#include "tinch_pp/node.h"
#include "tinch_pp/rpc.h"
#include "tinch_pp/mailbox.h"
#include "tinch_pp/erlang_types.h"
#include <boost/thread.hpp>
#include <boost/assign/list_of.hpp>
#include <iostream>
#include <stdexcept>
using namespace tinch_pp;
using namespace tinch_pp::erl;
using namespace boost::assign;

using namespace std;

class TestClass: BotNode {
  public:
    void print() {
      cout << "TestClass" << "\n\r";
    }
};

int main() {
  TestClass *ts;
  ts = new TestClass();
  //ts->print();
  //ts.print();
  int i = 0;
  while(i<10000000) 
  {
    ts->print();
  }
}