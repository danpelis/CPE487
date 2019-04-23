#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/home/dpelis/tools/Xilinx/SDK/2018.3/bin:/home/dpelis/tools/Xilinx/Vivado/2018.3/ids_lite/ISE/bin/lin64:/home/dpelis/tools/Xilinx/Vivado/2018.3/bin
else
  PATH=/home/dpelis/tools/Xilinx/SDK/2018.3/bin:/home/dpelis/tools/Xilinx/Vivado/2018.3/ids_lite/ISE/bin/lin64:/home/dpelis/tools/Xilinx/Vivado/2018.3/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=/home/dpelis/tools/Xilinx/Vivado/2018.3/ids_lite/ISE/lib/lin64
else
  LD_LIBRARY_PATH=/home/dpelis/tools/Xilinx/Vivado/2018.3/ids_lite/ISE/lib/lin64:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/home/dpelis/hex4digit/hex4digit.runs/impl_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

# pre-commands:
/bin/touch .write_bitstream.begin.rst
EAStep vivado -log hexcount.vdi -applog -m64 -product Vivado -messageDb vivado.pb -mode batch -source hexcount.tcl -notrace


