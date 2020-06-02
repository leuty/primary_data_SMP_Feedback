#!/bin/bash

SCHEDULER="SLURM"

# clean jobs
jobid=""
for part in [1-9]*_* ; do
  echo "cleaning ${part}"
  cd ${part} 
  if [ -f .jobid ]; then
    if [ "${SCHEDULER}" = "PBS" ]; then
      echo "killing job `cat .jobid`"
      qdel -W force `cat .jobid`
    else
      echo "killing job `cat .jobid`"
      scancel `cat .jobid`
    fi
    sleep 3
    \rm .jobid
  fi
  ./clean
  \rm core *.out INPUT INPUT_* job 2>/dev/null
  cd - 1>/dev/null 2>/dev/null
done

# clean data
\rm -rf input output 1_ifs2lm/extp2_EUROPE_MCH_12km.nc 3_lm2lm/extpar_2km_europe.nc input/lffd2006050100_lm_?.nc



