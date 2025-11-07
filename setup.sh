#!/bin/bash

# TODO: Change to your paths
export VITIS_PYTHON_27_LIBRARY_PATH="$XILINX_VITIS/aietools/tps/lnx64/target_aie_ml/chessdir/python-2.7.13/lib"
export C_INCLUDE_PATH="$XILINX_HLS/lnx64/tools/gcc/lib/gcc/x86_64-unknown-linux-gnu/4.6.3/include/:$C_INCLUDE_PATH" 
export C_INCLUDE_PATH="$XILINX_HLS/include/:$C_INCLUDE_PATH" 
export C_INCLUDE_PATH="/opt/merlin/sources/Merlin-UCLA-Updated/trunk/source-opt/include/apint_include/:$C_INCLUDE_PATH" 
export C_INCLUDE_PATH="$XILINX_HLS/include:$C_INCLUDE_PATH"

# TODO: Change to your paths
export PATH=$XILINX_XRT/bin:$PATH
export PATH=$XILINX_VIVADO/bin:$PATH
export PATH=$XILINX_VITIS/bin:$XILINX_VITIS/runtime/bin:$PATH
export PATH=$XILINX_HLS/bin:$PATH

# TODO: Change to your conda environment name
# A tricky thing is that Merlin requires Python <= 2.7, while the rest of the code uses Python 3.
# So we need to make sure that when Merlin calls "python", it uses Python 2
# When we call "python3", we use the correct Python 3 from the conda environment 
source "$HOME/miniconda3/etc/profile.d/conda.sh"
conda activate llm-dse
# create shims so python3/pip3 come from this env
SHIMS_DIR="$HOME/.shims"
mkdir -p "$SHIMS_DIR"
ln -sf "$CONDA_PREFIX/bin/python" "$SHIMS_DIR/python3"
ln -sf "$CONDA_PREFIX/bin/pip"    "$SHIMS_DIR/pip3"
# PATH order: shims first (gives you conda python3), then /usr/bin (gives you system python 2.7), then everything else
export PATH="$SHIMS_DIR:/usr/bin:$PATH"

# TODO: The WORK_DIR is the place where Merlin saves intermediate files and reports. Change it to your own paths.
# Merlin produces a lot of files, requires a lot of I/O and occupies much space.
# If your server has a specific scratch directory for such purpose, it is recommended to use that as WORK_DIR, and delete files from it regularly.
export WORK_DIR=/scratch/weikaili
