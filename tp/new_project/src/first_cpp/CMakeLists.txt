# ./first_cpp first_cpp alex-N550JK core@alex-N550JK ibot_nodes_srv_connector ibot_nodes_srv_topic ibot_nodes_srv_service ibot_nodes_srv_ui_interaction ibot_events_srv_node_interaction jv

#start file
cmake_minimum_required (VERSION 2.6)

#project name
project (first_cpp)

#include(CheckCXXCompilerFlag)
#CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)
#CHECK_CXX_COMPILER_FLAG("-std=c++0x" COMPILER_SUPPORTS_CXX0X)
#if(COMPILER_SUPPORTS_CXX11)
#    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
#elseif(COMPILER_SUPPORTS_CXX0X)
#    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
#else()
#        message(STATUS "The compiler ${CMAKE_CXX_COMPILER} has no C++11 support. Please use a different C++ compiler.")
#endif()

#====== find boost package ======
find_package(Boost 1.54.0 REQUIRED COMPONENTS system)
if (${Boost_FOUND})
message(BOOST HERE)

#====== files paths ======
#tinch libs
set(TINCH_LIB_PATH /usr/local/tinch_pp-0.3.0/lib)
#tinch implementations
set(TINCH_IMPL_PATH /usr/local/tinch_pp-0.3.0/impl)
#tinch headers
set(TINCH_DIR_PATH /usr/local/tinch_pp-0.3.0)
#ibot headers
set(IBOT_INCLUDES_PATH /home/alex/iBotOS/iBotOS/CLib/includes)
#ibot libs
set(IBOT_LIB_PATH /home/alex/iBotOS/iBotOS/CLib/lib)

set(IBOT_PROJECT_MESSAGES_PATH /home/alex/iBotOS/iBotOS/tp/new_project/dev/msg/cpp)
set(IBOT_PROJECT_SERVICES_PATH /home/alex/iBotOS/iBotOS/tp/new_project/dev/srv/cpp)
#!====== files paths ======

#====== direcory includes ======
#include tich libs dir
include_directories(${TINCH_LIB_PATH})
#include tinch inplementation dir
include_directories(${TINCH_IMPL_PATH})
#include tinch headers dir
include_directories(${TINCH_DIR_PATH})
#include ibot libs dir
include_directories(${IBOT_LIB_PATH})
#incldue ibot headers dir
include_directories(${IBOT_INCLUDES_PATH})

include_directories(${IBOT_PROJECT_MESSAGES_PATH})
include_directories(${IBOT_PROJECT_SERVICES_PATH})
#!====== direcory includes ======

#====== include boost paths ======
include_directories(${Boost_INCLUDE_DIR})
include_directories(${Boost_LIBRARY_DIRS})
include_directories(${Boost_ROOT})
#!====== include boost paths ======

#====== cmake result output path ======
#set path for create libs
set(C_LIB_OUTPUT_DIR ../lib)
#set path for create executable file
set(C_BIN_OUTPUT_DIR ../../../dev/nodes/first_cpp)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${C_LIB_OUTPUT_DIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${C_LIB_OUTPUT_DIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${C_BIN_OUTPUT_DIR})
#!====== cmake result output path ======

#====== sets of header files ======
set(IBOT_HEADERS ${IBOT_INCLUDES_PATH}/BotNode.h)

set(IBOT_PROJECT_MESSAGES_HEADERS ${IBOT_PROJECT_MESSAGES_PATH}/TestMsgCpp.h)
set(IBOT_PROJECT_SREVICES_HEADERS ${IBOT_PROJECT_SERVICES_PATH}/ServiceTestReq.h ${IBOT_PROJECT_SERVICES_PATH}/ServiceTestResp.h)
#!====== set of header files ======

#====== sets of libs ======
set(IBOT_LIBS ${IBOT_LIB_PATH}/libcpp_ibot_lib.a)
set(TINCH_LIBS ${TINCH_LIB_PATH}/libtinch++.a)
file(GLOB ALLB ${Boost_LIBRARY_DIRS}/libboost*.a)
#!====== sets of libs ======

#====== executable file settings ======
add_executable(first_cpp src/first_cpp.cxx ${IBOT_HEADERS} ${IBOT_PROJECT_MESSAGES_HEADERS} ${IBOT_PROJECT_SERVICES_PATH})
#!====== executable file settings ======

#====== link libs ======
target_link_libraries (first_cpp ${TINCH_LIBS}  ${IBOT_LIBS} ${Boost_LIBRARIES} ${ALLB} pthread)
#!====== link libs ======

else (${Boost_FOUND})
  message(NO BOOST)
endif (${Boost_FOUND})
#====== find boost package ======

#install(TARGETS TCP RUNTIME DESTINATION bin)
