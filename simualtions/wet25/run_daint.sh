#!/bin/bash

while getopts "o" opt
   do
     case $opt in
        o ) export IO_REDUCED="yes";;
     esac
done

# global setup
export SCHEDULER="SLURM"
export QUEUE="normal"
export ACCOUNT="pr04"
export RUNCMD="srun"
export CORES_PER_NODE=16
export TASKS_PER_NODE=1
export GPUS_PER_NODE=1

# setup configurations
export NPX_IFS2LM=3
export NPY_IFS2LM=7
export NPIO_IFS2LM=1
export EXE_IFS2LM="./int2lm"

export NPX_LMC=12
export NPY_LMC=12
export NPIO_LMC=0
export EXE_LMC="./lm_f90"

export NPX_LM2LM=3
export NPY_LM2LM=7
export NPIO_LM2LM=1
export EXE_LM2LM="./int2lm"

export NPX_LMF=12
export NPY_LMF=12
export NPIO_LMF=0
export EXE_LMF="./lm_f90"

# launch jobs
jobid=""
parts="6_put_data_????"
for part in ${parts} ; do
  short=`echo "${part}" | sed 's/^[0-9]*_//g'`
  echo "launching ${short}"
  cd ${part} 
  jobid=`./run ${SCHEDULER} ${QUEUE} ${ACCOUNT} ${jobid}`
  cd - 1>/dev/null 2>/dev/null
done

