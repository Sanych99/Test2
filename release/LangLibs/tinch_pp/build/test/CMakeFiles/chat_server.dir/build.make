# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 2.8

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list

# Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/alex/iBotOS/testLib/tinch_pp-master

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/alex/iBotOS/testLib/tinch_pp-master/build

# Utility rule file for chat_server.

# Include the progress variables for this target.
include test/CMakeFiles/chat_server.dir/progress.make

test/CMakeFiles/chat_server:
	cd /home/alex/iBotOS/testLib/tinch_pp-master/build/test && /usr/bin/erlc -o /home/alex/iBotOS/testLib/tinch_pp-master/build/test /home/alex/iBotOS/testLib/tinch_pp-master/test/chat_server.erl

chat_server: test/CMakeFiles/chat_server
chat_server: test/CMakeFiles/chat_server.dir/build.make
.PHONY : chat_server

# Rule to build all files generated by this target.
test/CMakeFiles/chat_server.dir/build: chat_server
.PHONY : test/CMakeFiles/chat_server.dir/build

test/CMakeFiles/chat_server.dir/clean:
	cd /home/alex/iBotOS/testLib/tinch_pp-master/build/test && $(CMAKE_COMMAND) -P CMakeFiles/chat_server.dir/cmake_clean.cmake
.PHONY : test/CMakeFiles/chat_server.dir/clean

test/CMakeFiles/chat_server.dir/depend:
	cd /home/alex/iBotOS/testLib/tinch_pp-master/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/alex/iBotOS/testLib/tinch_pp-master /home/alex/iBotOS/testLib/tinch_pp-master/test /home/alex/iBotOS/testLib/tinch_pp-master/build /home/alex/iBotOS/testLib/tinch_pp-master/build/test /home/alex/iBotOS/testLib/tinch_pp-master/build/test/CMakeFiles/chat_server.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : test/CMakeFiles/chat_server.dir/depend
