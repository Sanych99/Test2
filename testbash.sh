#!/bin/bash
clear
var="Generate jar files"
echo $var
cd ~/iBotOS/iBotOS/tp/tp


for entry in dev/srv/java/*.class
do
  echo "$entry"
  filename=$(basename "$entry")
  extension="${filename##*.}"
  filename="${filename%.*}"

  jar cvf dev/srv/java/"$filename".jar dev/srv/java/"$filename".class
done