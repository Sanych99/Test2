#!/bin/bash
clear

echo "start install release"

echo "update ubuntu repositories"

sudo apt-get update 

echo "install erlang"
wget http://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
sudo dpkg -i erlang-solutions_1.0_all.deb
sudo apt-get update
sudo apt-get install erlang
#HiPE stands for High-Performance Erlang Project. It is a native code compiler for Erlang. In most #cases, it positively affects performance. If you want to download it, call the following:
#sudo apt-get install erlang-base-hipe

echo "install java"
sudo apt-get install default-jre
sudo apt-get install default-jdk

echo "install python"
sudo add-apt-repository ppa:fkrull/deadsnakes
sudo apt-get update
sudo apt-get install python2.7

sudo apt-get install idle-python3.4

echo "install c++ compilers and cmake"
sudo apt-get install g++

sudo apt-get install software-properties-common
sudo add-apt-repository ppa:george-edison55/cmake-3.x
sudo apt-get update

sudo apt-get install cmake
sudo apt-get install checkinstall
#sudo checkinstall

echo "install py_interface"
cd ./LangLibs/py_interface
sudo python setup.py build
sudo python setup.py install

echo "install tinch_pp"
cd ../../LangLibs/tinch_pp
mkdir build
cd build
sudo cmake ..
sudo make
sudo make install

echo "install PLib"
cd ../../PLib
sudo python setup.py build
sudo python setup.py install

echo "install CLib"
cd ../../CLib
mkdir build
cd build
sudo cmake ..
sudo make

echo "install python messages and services"
cd ../../project/dev/msg/python
python setup.py build
sudo python setup.py install
cd ../../project/dev/srv/python
python setup.py build
sudo python setup.py install
