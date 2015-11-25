#!/bin/bash
clear

echo "create release directory"
rm -rf release
mkdir release

#echo "change directory to release"

#cd release

echo "clear release directory"

rm -rf release/*

echo "copy ibot_core to release"

mkdir release/ibot_os
cp -r ibot_os/rel release/ibot_os/rel

echo "copy CLib directories"
mkdir release/CLib
cp -r CLib release/

echo "copy PLib directories"
mkdir release/PLib
cp -r PLib release/

echo "copy PLib directories"
mkdir release/JLib
cp -r JLib/lib release/JLib/lib

echo "copy install_release.sh and clear_release_after_install.sh files"
cp install_release.sh release/install_release.sh
cp install_release.sh release/clear_release_after_install.sh

echo "copy LangLibs directory"
mkdir release/LangLibs
cp -r LangLibs/py_interface release/LangLibs/py_interface
cp -r LangLibs/tinch_pp release/LangLibs/tinch_pp

echo "copy start_core.sh file"
cp start_core.sh release/start_core.sh

echo "copy project directory"
mkdir release/project
#mkdir release/project/dev
cp -r project/dev release/project/dev
cp project/project.conf release/project/project.conf

