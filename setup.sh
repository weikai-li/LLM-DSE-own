#!/bin/bash

export VITIS_PYTHON_27_LIBRARY_PATH="$XILINX_VITIS/aietools/tps/lnx64/target_aie_ml/chessdir/python-2.7.13/lib"
export C_INCLUDE_PATH="$XILINX_HLS/lnx64/tools/gcc/lib/gcc/x86_64-unknown-linux-gnu/4.6.3/include/:$C_INCLUDE_PATH" 
export C_INCLUDE_PATH="$XILINX_HLS/include/:$C_INCLUDE_PATH" 
export C_INCLUDE_PATH="/opt/merlin/sources/Merlin-UCLA-Updated/trunk/source-opt/include/apint_include/:$C_INCLUDE_PATH" 
export C_INCLUDE_PATH="$XILINX_HLS/include:$C_INCLUDE_PATH"

export PATH=$XILINX_XRT/bin:$PATH
export PATH=$XILINX_VIVADO/bin:$PATH
export PATH=$XILINX_VITIS/bin:$XILINX_VITIS/runtime/bin:$PATH
export PATH=$XILINX_HLS/bin:$PATH

# make sure python = python 2.7, and python3 comes from the conda env
# When we run python main.py, we should use python3 main.py
# create shims so python3/pip3 come from this env
source "$HOME/miniconda3/etc/profile.d/conda.sh"
conda activate llm-dse
SHIMS_DIR="$HOME/.shims"
mkdir -p "$SHIMS_DIR"
ln -sf "$CONDA_PREFIX/bin/python" "$SHIMS_DIR/python3"
ln -sf "$CONDA_PREFIX/bin/pip"    "$SHIMS_DIR/pip3"

# PATH order: shims first (gives you conda python3), then /usr/bin (gives you system python 2.7), then everything else
export PATH="$SHIMS_DIR:/usr/bin:$PATH"

export WORK_DIR=/scratch/weikaili
