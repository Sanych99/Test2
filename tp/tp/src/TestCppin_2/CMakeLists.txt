cmake_minimum_required (VERSION 2.6)
project (cpp_ibot_lib)

set(INCLUDE_PATH includes)
set(SRC_PATH src)

set(TINCH_LIB /usr/local/tinch_pp-0.3.0/lib)
set(TINCH_IMPL /usr/local/tinch_pp-0.3.0/impl)
set(TINCH_DIR /usr/local/tinch_pp-0.3.0)

include_directories(${INCLUDE_PATH})
include_directories(${TINCH_LIB})
include_directories(${TINCH_IMPL})
include_directories(${TINCH_DIR})

set(HEADERS ${INCLUDE_PATH}/BotNode.h)
set(LIB_SOURCES ${SRC_PATH}/BotNode.cxx)

set(C_LIB_OUTPUT_DIR ../lib)
set(C_BIN_OUTPUT_DIR ../bin)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${C_LIB_OUTPUT_DIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${C_LIB_OUTPUT_DIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${C_BIN_OUTPUT_DIR})

#Создание статических библиотек
add_library(cpp_ibot_lib STATIC ${LIB_SOURCES} ${HEADERS})

#Для создания статической библиотеки
target_link_libraries (cpp_ibot_lib erl_interface ei pthread nsl)


