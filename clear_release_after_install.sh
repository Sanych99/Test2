#!/bin/bash
clear

echo "clear release after install"

echo "remove LangLibs directory"
rm -rf LangLibs

echo "remove PLib"
rm -rg PLib

echo "clear CLib"
rm -rf CLib/bin
rm -rf CLib/build
rm -rf CLib/src
rm  CLib/*.txt

echo "remove install and clear scripts"
rm install_release.sh
rm clear_release_after_install.sh


