cmake_minimum_required (VERSION 2.6)
project (Tutorial)

set(INCLUDE_PATH /home/alex/iBotOS/iBotOS/tp/tp/src/TestCppin/includes)
set(SRC_PATH /home/alex/iBotOS/iBotOS/tp/tp/src/TestCppin/src)

include_directories(${INCLUDE_PATH})

set(HEADERS ${INCLUDE_PATH}/ParentClass.h)
set(LIB_SOURCES ${SRC_PATH}/ParentClass.cxx)

set(EXECUTABLE_FILES ${SRC_PATH}/main.cxx)

#Создание статических библиотек
add_library(ParentClassLib STATIC ${LIB_SOURCES} ${HEADERS})

#Добавление внешних библиотек
set(PP /home/alex/iBotOS/iBotOS/tp/tp/src/TestCppin)
link_directories(${PP})

add_executable(TestPC ${EXECUTABLE_FILES})
target_link_libraries (TestPC erl_interface ei pthread nsl ParentClassLib)

#Для создания статической библиотеки
#target_link_libraries (TutorialLib erl_interface ei pthread nsl)


