cmake_minimum_required (VERSION 2.6)

project (TCP)

set(TINCH_LIB /usr/local/tinch_pp-0.3.0/lib)
set(TINCH_IMPL /usr/local/tinch_pp-0.3.0/impl)
set(TINCH_DIR /usr/local/tinch_pp-0.3.0)

set(IBOT_INCLUDES /home/alex/iBotOS/iBotOS/CLib/includes)
set(IBOT_LIB /home/alex/iBotOS/iBotOS/CLib/lib)



set(C_LIB_OUTPUT_DIR ../lib)
set(C_BIN_OUTPUT_DIR ../bin)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${C_LIB_OUTPUT_DIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${C_LIB_OUTPUT_DIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${C_BIN_OUTPUT_DIR})


include_directories(${TINCH_LIB})
include_directories(${TINCH_IMPL})
include_directories(${TINCH_DIR})

include_directories(${IBOT_LIB})
include_directories(${IBOT_INCLUDES})


set(IBOT_HEADERS ${IBOT_INCLUDES}/BotNode.h)


add_executable(TCP src/TC.cxx ${IBOT_HEADERS})

find_package(Boost 1.54.0 REQUIRED COMPONENTS system)
if (${Boost_FOUND})
  INCLUDE_DIRECTORIES( ${Boost_INCLUDE_DIR} )
  INCLUDE_DIRECTORIES( ${Boost_LIBRARY_DIRS} )
  INCLUDE_DIRECTORIES( ${Boost_ROOT} )
  message(BOOST HERE)
  message(ECHO ${Boost_LIBRARY_DIRS})
  message(${Boost_LIBRARY_DIRS})
else (${Boost_FOUND})
  message(NO BOOST)
endif (${Boost_FOUND})

FILE(GLOB ALLB ${Boost_LIBRARY_DIRS}/libboost*.a)


target_link_libraries (TCP ${TINCH_LIB}/libtinch++.a ${IBOT_LIB}/libcpp_ibot_lib.a pthread ${Boost_LIBRARIES} ${Boost_LIBRARY_DIRS}/libboost_thread.a ${ALLB})

#install(TARGETS TCP RUNTIME DESTINATION bin)
