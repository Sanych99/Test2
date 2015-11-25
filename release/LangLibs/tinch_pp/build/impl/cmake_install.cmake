# Install script for directory: /home/alex/iBotOS/testLib/tinch_pp-master/impl

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
  FILE(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/tinch_pp-0.3.0/lib" TYPE STATIC_LIBRARY FILES "/home/alex/iBotOS/testLib/tinch_pp-master/build/impl/libtinch++.a")
ENDIF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")

IF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  FILE(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/tinch_pp-0.3.0/impl" TYPE FILE FILES
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/node_connection.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/epmd_protocol.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/control_msg.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/control_msg_unlink.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/RefToValue.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/matchable_range.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/node_msg.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/node_connection_state.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/link_policies.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/control_msg_link.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/mailbox_controller_type.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/md5.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/node_connection_access.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/actual_node.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/linker.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/handshake_grammar.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/control_msg_exit.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/utils.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/ctrl_msg_dispatcher.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/types.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/networker.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/control_msg_reg_send.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/control_msg_exit2.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/string_matcher.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/epmd_requestor.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/node_async_tcp_ip.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/actual_mailbox.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/node_access.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/term_conversions.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/node_connector.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/constants.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/ScopeGuard.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/ext_term_grammar.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/control_msg_send.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/list_matcher.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/matchable_seq.h"
    "/home/alex/iBotOS/testLib/tinch_pp-master/impl/ext_message_builder.h"
    )
ENDIF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")

