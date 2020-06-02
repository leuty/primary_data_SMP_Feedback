#!/bin/bash -l
#written by David Leutwyler, October 2015, david.leutwyler@@alumni.ethz.ch

PRUDENCE=$WDIR/external_data/data/lm_c_PRUDENCE_MASKS_LAND.nc
pr_region=(ANALYSIS BI IP FR ME AL MD EA)

for YYYY in $(seq ${YYYY_START} ${YYYY_STOP});do
  FILE=$WDIR/external_data/rain_${YYYY}_jja.nc

  #Precipitation Distribution
  #--------------------------
  
  bins=`python -c "import numpy as np; print(','.join(map(str, np.logspace(-2,2,401))))"`
  
  #Check if file exists and size
  
  if [ ! -f $WDIR/histfreq_TOT_PREC_${YYYY}_jja.nc ] || [ $( stat -c%s $WDIR/histfreq_TOT_PREC_${YYYY}_jja.nc ) -lt  200000000 ]; then   
    cdo -s setgrid,$WDIR/external_data/data/CLM_lm_c_grid.txt -histfreq,$bins -selvar,TOT_PREC $FILE $WDIR/histfreq_TOT_PREC_${YYYY}_jja.nc
    cdo -s setgrid,$WDIR/external_data/data/CLM_lm_c_grid.txt -histfreq,$bins -daymax -selvar,TOT_PREC $FILE $WDIR/histfreq_TOT_PREC_daymax_${YYYY}_jja.nc
  fi

  #Cut prudence regions
  for i in {0..7}; do
    if [ ! -f $WDIR/prudence/histfreq_TOT_PREC_${YYYY}_jja_${pr_region[$i]}.nc ]; then
      cdo -s ifthen -selvar,MASK_${pr_region[$i]} $PRUDENCE -ifthen -selvar,FR_LAND $PRUDENCE $WDIR/histfreq_TOT_PREC_${YYYY}_jja.nc $WDIR/precip/freqdist/histfreq_TOT_PREC_${YYYY}_jja_${pr_region[$i]}.nc
      cdo -s copy -setname,histfreq_${pr_region[$i]} -fldmean $WDIR/precip/freqdist/histfreq_TOT_PREC_${YYYY}_jja_${pr_region[$i]}.nc $WDIR/prudence/histfreq_TOT_PREC_${YYYY}_jja_${pr_region[$i]}.nc
    fi
  done
  if [ -f $ODIR/prudence/histfreq_TOT_PREC_${YYYY}_jja.nc ] ; then rm $ODIR/prudence/histfreq_TOT_PREC_${YYYY}_jja.nc ; fi
  cdo -s merge $WDIR/prudence/histfreq_TOT_PREC_${YYYY}_jja_*.nc $ODIR/prudence/histfreq_TOT_PREC_${YYYY}_jja.nc
  rm $WDIR/prudence/histfreq_TOT_PREC_${YYYY}_jja_*
  nces -h $ODIR/prudence/histfreq_TOT_PREC_????_jja.nc -O $ODIR/prudence/histfreq_TOT_PREC_jja.nc

  #Daymax
  for i in {0..7}; do
    if [ ! -f $WDIR/prudence/histfreq_TOT_PREC_daymax_${YYYY}_jja_${pr_region[$i]}.nc ]; then
      cdo -s ifthen -selvar,MASK_${pr_region[$i]} $PRUDENCE -ifthen -selvar,FR_LAND $PRUDENCE $WDIR/histfreq_TOT_PREC_daymax_${YYYY}_jja.nc $WDIR/precip/freqdist/histfreq_TOT_PREC_daymax_${YYYY}_jja_${pr_region[$i]}.nc
      cdo -s copy -setname,histfreq_${pr_region[$i]} -fldmean $WDIR/precip/freqdist/histfreq_TOT_PREC_daymax_${YYYY}_jja_${pr_region[$i]}.nc $WDIR/prudence/histfreq_TOT_PREC_daymax_${YYYY}_jja_${pr_region[$i]}.nc
    fi
  done
  if [ -f $ODIR/prudence/histfreq_TOT_PREC_daymax_${YYYY}_jja.nc ] ; then rm $ODIR/prudence/histfreq_TOT_PREC_daymax_${YYYY}_jja.nc ; fi
  cdo -s merge $WDIR/prudence/histfreq_TOT_PREC_daymax_${YYYY}_jja_*.nc $ODIR/prudence/histfreq_TOT_PREC_daymax_${YYYY}_jja.nc
  rm $WDIR/prudence/histfreq_TOT_PREC_daymax_${YYYY}_jja_*
  nces -h $ODIR/prudence/histfreq_TOT_PREC_daymax_????_jja.nc -O $ODIR/prudence/histfreq_TOT_PREC_daymax_jja.nc

done

