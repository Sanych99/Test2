# Install script for directory: /home/alex/iBotOS/testLib/tinch_pp-master/tinch_pp

# Set the install prefix
IF(NOT DEFINED CMAKE_INSTALL_PREFIX)
  SET(CMAKE_INSTALL_PREFIX "/usr/local")
ENDIF(NOT DEFINED CMAKE_INSTALL_PREFIX)
STRING(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
IF(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  IF(BUILD_TYPE)
    STRING(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  ELSE(BUILD_TYPE)
    SET(CMAKE_INSTALL_CONFIG_NAME "")
  ENDIF(BUILD_TYPE)
  MESSAGE(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
ENDIF(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)

# Set the component getting installed.
IF(NOT CMAKE_INSTALL_COMPONENT)
  IF(COMPONENT)
    MESSAGE(STATUS "Install component: \"${COMPONENT}\"")
    SET(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  ELSE(COMPONENT)
    SET(CMAKE_INSTALL_COMPONENT)
  ENDIF(COMPONENT)
ENDIF(NOT CMAKE_INSTALL_COMPONENT)

# Install shared libraries without execute permission?
IF(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  SET(CMAKE_INSTALL_SO_NO_EXE "1")
ENDIF(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)

IF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  FILE(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/tinch_pp-0.3.0/tinch_pp" TYPE FILE FILES
    "/home/alex/iBotOS/testLib/tinch_pp-master/tinch_pp/erlang_types.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/tinch_pp/erlang_value_types.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/tinch_pp/erl_any.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/tinch_pp/erl_list.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/tinch_pp/erl_object.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/tinch_pp/erl_string.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/tinch_pp/erl_tuple.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/tinch_pp/exceptions.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/tinch_pp/mailbox.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/tinch_pp/make_erl_tuple.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/tinch_pp/matchable.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/tinch_pp/node.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/tinch_pp/rpc.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/tinch_pp/type_makers.h"
    )
ENDIF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")

