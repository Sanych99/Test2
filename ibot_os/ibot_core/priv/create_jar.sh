#!/bin/bash
clear

args=("$@")

echo "Compile java messages"

javac -classpath ${args[0]}:${args[1]} ${args[2]}/dev/msg/java/*.java

echo "Compile java messages"

javac -classpath ${args[0]}:${args[1]} ${args[2]}/dev/srv/java/*.java

echo "Generate jar files"
cd ${args[2]}

echo "Generate jar messages files"
for entry in dev/msg/java/*.class
do
  echo "$entry"
  filename=$(basename "$entry")
  extension="${filename##*.}"
  filename="${filename%.*}"

  jar cvf dev/msg/java/"$filename".jar dev/msg/java/"$filename".class
done

echo "Generate jar services files"
for entry in dev/srv/java/*.class
do
  echo "$entry"
  filename=$(basename "$entry")
  extension="${filename##*.}"
  filename="${filename%.*}"

  jar cvf dev/srv/java/"$filename".jar dev/srv/java/"$filename".class
done
