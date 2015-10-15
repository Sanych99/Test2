// A simple program that computes the square root of a number
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

#include "erl_interface.h"
#include "ei.h"

#define NODE   "madonna@127.0.0.1"
#define ALIVE  "madonna"
#define IP_ADDR "127.0.0.1"

#define BUFSIZE 1000

class Tutorial : public ParentClass {

int foo(int x) {
  return x+1;
}

int bar(int y) {
  return y*2;
}

int main (int argc, char *argv[])
{

/*int socket_desc;
    socket_desc = socket(AF_INET , SOCK_STREAM , 0);
     
    if (socket_desc < 0)
    {
        fprintf(stderr, "ERROR %i\n\r", socket_desc);
    }	
else { fprintf(stderr, "GOOD %i\n\r", socket_desc); }
*/
//	int fd;                                  /* fd to Erlang node */
	int loop = 1;                            /* Loop flag */
	int got;                                 /* Result of receive */
	unsigned char buf[BUFSIZE];              /* Buffer for incoming message */
	ErlMessage emsg;                         /* Incoming message */
	

	ETERM *fromp, *tuplep, *fnp, *argp, *resp;
	int res;

	erl_init(NULL, 0);
fprintf(stderr, "One %i\n\r", erl_connect_init(1, "jv", 0));
/*===================Other=======================*/
	  if (erl_connect_init(1, "jv", 0) == -1)
    erl_err_quit("erl_connect_init");


struct in_addr addr;
addr.s_addr = inet_addr(IP_ADDR);

erl_connect_xinit("127.0.0.1", "cnode_test", "cnode@127.0.0.1",
                  &addr, "jv", 0);
erl_publish(3);
erl_connect("cnode_test@127.0.0.1");
/*
ei_cnode ec;

int fd = ei_connect(&ec, NODE);
fprintf(stderr, "FIRST FD: %i\n\r", fd);


struct in_addr addr;
addr.s_addr = inet_addr(IP_ADDR);
fd = ei_xconnect(&ec, &addr, ALIVE);
fprintf(stderr, "SECOND FD: %i\n\r", fd);
*/

/*
fprintf(stderr, "Two\n\r");
  if ((fd = erl_connect("test@alex-N550JK")) < 0) {
	fprintf(stderr, "%i\n\r", fd);
    erl_err_quit("erl_connect");
	
}
*/
  /*fprintf(stderr, "Connected to ei@idril\n\r");

  while (loop) {

    got = erl_receive_msg(fd, buf, BUFSIZE, &emsg);
    if (got == ERL_TICK) {
 
    } else if (got == ERL_ERROR) {
      loop = 0;
    } else {

      if (emsg.type == ERL_REG_SEND) {
	fromp = erl_element(2, emsg.msg);
	tuplep = erl_element(3, emsg.msg);
	fnp = erl_element(1, tuplep);
	argp = erl_element(2, tuplep);

	if (strncmp(ERL_ATOM_PTR(fnp), "foo", 3) == 0) {
	  res = foo(ERL_INT_VALUE(argp));
	} else if (strncmp(ERL_ATOM_PTR(fnp), "bar", 3) == 0) {
	  res = bar(ERL_INT_VALUE(argp));
	}

	resp = erl_format("{cnode, ~i}", res);
	erl_send(fd, fromp, resp);

	erl_free_term(emsg.from); erl_free_term(emsg.msg);
	erl_free_term(fromp); erl_free_term(tuplep);
	erl_free_term(fnp); erl_free_term(argp);
	erl_free_term(resp);
      }
    }
  }*/
}
}
