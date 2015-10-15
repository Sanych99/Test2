// A simple program that computes the square root of a number
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <iostream>

#include "erl_interface.h"
#include "ei.h"

#define NODE   "madonna@127.0.0.1"
#define ALIVE  "madonna"
#define IP_ADDR "127.0.0.1"

#define BUFSIZE 1000

using namespace std;

class test1 {
};

class tutorial: test1 {
public:
int foo(int x) {
  return x+1;
}

int bar(int y) {
  return y*2;
}
};

int main ()
{
	tutorial *bar;
	bar = new tutorial();
	cout << "obj's area: " << bar->foo(5) << '\n';
	cout << "obj's area: " << bar->bar(5) << '\n';
}
