cmake_minimum_required (VERSION 2.6)
project (Tutorial)

#set(ERL_PATH /usr/lib/erlang/lib/erl_interface-3.7.20)
#include_directories(${ERL_PATH}/include)
#link_directories(${ERL_PATH}/lib)

#Создание статических библиотек
#add_library(InClass STATIC src/tutorial.c)

#Добавление внешних библиотек
set(PP /home/alex/iBotOS/iBotOS/tp/tp/src/TestCpp)
link_directories(${PP})

add_executable(Tutorial src/tutorial.cxx)
target_link_libraries (Tutorial erl_interface ei pthread nsl InClass)

#Для создания статической библиотеки
#target_link_libraries (TutorialLib erl_interface ei pthread nsl)


