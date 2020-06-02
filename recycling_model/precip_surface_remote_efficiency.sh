#!/bin/bash 
#written by David Leutwyler, Nov. 2018, david.leutwyler@mpimet.mpg.de

#Load Modules
. /etc/bash.bashrc
module load daint-gpu
module load PyExtensions
module load netcdf-python

PROJECT=/project/pr04/davidle

for MODEL in lm_c lm_f; do

  echo $MODEL
  echo ====

  #unset variables
  if [ -z ${AD+x} ]; then unset AD  ;fi
  if [ -z ${ATL+x} ]; then unset ATL  ;fi
  if [ -z ${AL+x} ]; then unset AL ;fi
  if [ -z ${EU+x} ]; then unset EU ;fi

  for YYYY in {1999..2008};do

    #Atlantic
    ATL[$YYYY-1999]=`python recycling_model.py $PROJECT/results_soil-moisture_pertubation/analysis/dry25/analysis/${MODEL}/1h_seasmean_${YYYY}_jja.nc $SCRATCH/sm_pert_10a/analysis_dry25_${MODEL}/external_data/1h/lffd${YYYY}053123.nc $SCRATCH/sm_pert_10a/analysis_dry25_${MODEL}/external_data/1h/lffd${YYYY}090100.nc $PROJECT/results_soil-moisture_pertubation/analysis/wet25/analysis/${MODEL}/1h_seasmean_${YYYY}_jja.nc $SCRATCH/sm_pert_10a/analysis_wet25_${MODEL}/external_data/1h/lffd${YYYY}053123.nc $SCRATCH/sm_pert_10a/analysis_wet25_${MODEL}/external_data/1h/lffd${YYYY}090100.nc $SCRATCH/sm_pert_10a/analysis_ctrl_${MODEL}/external_data//1h/lffd1999050100c.nc -11.47 -7.32 44.04 50.93`

    #Alpine Domain
    AL[$YYYY-1998]=`python recycling_model.py $PROJECT/results_soil-moisture_pertubation/analysis/dry25/analysis/${MODEL}/1h_seasmean_${YYYY}_jja.nc $SCRATCH/sm_pert_10a/analysis_dry25_${MODEL}/external_data/1h/lffd${YYYY}053123.nc $SCRATCH/sm_pert_10a/analysis_dry25_${MODEL}/external_data/1h/lffd${YYYY}090100.nc $PROJECT/results_soil-moisture_pertubation/analysis/wet25/analysis/${MODEL}/1h_seasmean_${YYYY}_jja.nc $SCRATCH/sm_pert_10a/analysis_wet25_${MODEL}/external_data/1h/lffd${YYYY}053123.nc $SCRATCH/sm_pert_10a/analysis_wet25_${MODEL}/external_data/1h/lffd${YYYY}090100.nc $SCRATCH/sm_pert_10a/analysis_ctrl_${MODEL}/external_data//1h/lffd1999050100c.nc 3.67 15.92 44.37 48.83`

    #Northern Europe
    EU[$YYYY-1998]=`python recycling_model.py $PROJECT/results_soil-moisture_pertubation/analysis/dry25/analysis/${MODEL}/1h_seasmean_${YYYY}_jja.nc $SCRATCH/sm_pert_10a/analysis_dry25_${MODEL}/external_data/1h/lffd${YYYY}053123.nc $SCRATCH/sm_pert_10a/analysis_dry25_${MODEL}/external_data/1h/lffd${YYYY}090100.nc $PROJECT/results_soil-moisture_pertubation/analysis/wet25/analysis/${MODEL}/1h_seasmean_${YYYY}_jja.nc $SCRATCH/sm_pert_10a/analysis_wet25_${MODEL}/external_data/1h/lffd${YYYY}053123.nc $SCRATCH/sm_pert_10a/analysis_wet25_${MODEL}/external_data/1h/lffd${YYYY}090100.nc $SCRATCH/sm_pert_10a/analysis_ctrl_${MODEL}/external_data//1h/lffd1999050100c.nc 5.45 28.67 51.05 54.03`
  done

  echo -n "Analysis domain " ;python -c "from numpy import mean ; print('{0:.2f}'.format(mean([$( IFS=$','; echo "${AD[*]}" )])))"
  echo -n "Atlantic " ;python -c "from numpy import mean ; print('{0:.2f}'.format(mean([$( IFS=$','; echo "${ATL[*]}" )])))"
  echo -n "Alps " ;python -c "from numpy import mean ; print('{0:.2f}'.format(mean([$( IFS=$','; echo "${AL[*]}" )])))"
  echo -n "Northern Europe " ;python -c "from numpy import mean ; print('{0:.2f}'.format(mean([$( IFS=$','; echo "${EU[*]}" )])))"

done
