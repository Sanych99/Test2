#!/bin/bash
clear
echo "Direcory release"
cd ~/iBotOS/iBotOS/tp/tp
echo "Run create jar"
jar cvf dev/srv/java/ServiceTestResp.jar dev/srv/java/ServiceTestResp.class
