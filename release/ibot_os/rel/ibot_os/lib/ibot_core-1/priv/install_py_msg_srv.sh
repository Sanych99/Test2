#!/bin/bash
clear

args=("$@")

echo "Remove py_ibot_services from library"
echo 'alex!@#' | sudo -S rm -rf ${args[1]}/py_ibot_services

echo "Remove py_ibot_messages from library"
echo 'alex!@#' | sudo -S rm -rf ${args[1]}/py_ibot_messages

cd ${args[0]}/dev/msg/python

echo 'alex!@#' | sudo -S python setup.py build
echo 'alex!@#' | sudo -S python setup.py install

cd ${args[0]}/dev/srv/python

echo 'alex!@#' | sudo -S python setup.py build
echo 'alex!@#' | sudo -S python setup.py install
