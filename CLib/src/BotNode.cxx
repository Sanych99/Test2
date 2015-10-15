// A simple program that computes the square root of a number
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <iostream>
#include <string>
#include "erl_interface.h"
#include "ei.h"
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

/*message log type*/
const std::string BotNode::LOG_TYPE_MESSAGE("Message");
/*warning log type*/
const std::string BotNode::LOG_TYPE_WARNING("Warning");
/*error log type*/
const std::string BotNode::LOG_TYPE_ERROR("Error");




