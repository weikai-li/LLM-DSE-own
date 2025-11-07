#!/bin/bash

# TODO: Please download HLS version 2024.2, then set up the following environment variables based on your own paths
xilinx_path=/opt/xilinx
tools_path=/opt/xilinx/tools
XILINX_VITIS=/opt/xilinx/tools/Vitis_HLS/2024.2
XILINX_XRT=/opt/xilinx/xrt
XILINX_VIVADO=/opt/xilinx/tools/Vivado/2024.2

########################

# TODO: Change to your docker path
imagename="/home/weikaili/installed_softwares/merlinsif_sandbox"  # Path to the docker image

# TODO: I used apptainer to run the docker image. Please change the following commands to your commands to run the docker image
ml apptainer
source $XILINX_VITIS/settings64.sh
apptainer exec --bind /home:/home --bind $tools_path:$tools_path,$xilinx_path:$xilinx_path "$imagename" /bin/bash 
