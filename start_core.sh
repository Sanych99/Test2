#!/bin/bash
clear
echo "Direcory release"
cd ~/iBotOS/iBotOS/ibot_os/rel/ibot_os/bin/
echo "Run release"
./ibot_os console -eval 'ibot_core_srv_project_info_loader:load_core_config().'

