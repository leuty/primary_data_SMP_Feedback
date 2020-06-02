#!/bin/bash -l
#written by David Leutwyler, May 2016, david.leutwyler@@alumni.ethz.ch

pr_region=(ANALYSIS BI IP FR ME AL MD EA)
PRUDENCE=$WDIR/external_data/data/${LM_MODEL}_PRUDENCE_MASKS_LAND.nc

#TOT_PREC
for i in {0..7}; do
  for YYYY in $(seq ${YYYY_START} ${YYYY_STOP});do
    cdo -s ifthen -selvar,MASK_${pr_region[$i]} -setgrid,$WDIR/external_data/data/CLM_${LM_MODEL}_grid.txt $PRUDENCE -ifthen -selvar,FR_LAND -setgrid,$WDIR/external_data/data/CLM_${LM_MODEL}_grid.txt $PRUDENCE -selvar,TOT_PREC -setgrid,$WDIR/external_data/data/CLM_${LM_MODEL}_grid.txt $WDIR/external_data/TOT_PREC_${YYYY}_jja.nc  $WDIR/prudence/tmp_${YYYY}_prdnce_TOT_PREC_${pr_region[$i]}.nc
  done
  cdo -s ydaymean -setname,TOT_PREC_${pr_region[$i]} -fldmean -mergetime "$WDIR/prudence/tmp_????_prdnce_TOT_PREC_${pr_region[$i]}.nc" $WDIR/prudence/prdnce_tseries_TOT_PREC_${pr_region[$i]}.nc
done
cdo -s -O merge "$WDIR/prudence/prdnce_tseries_TOT_PREC_*" ${ODIR}/prudence/prudence_fldmean_timeseries_TOT_PREC.nc
rm $WDIR/prudence/tmp_????_prdnce_TOT_PREC_*.nc $WDIR/prudence/prdnce_tseries_TOT_PREC_*.nc

for i in {0..7}; do
  for YYYY in $(seq ${YYYY_START} ${YYYY_STOP});do
    cdo -s ifthen -selvar,MASK_${pr_region[$i]} -setgrid,$WDIR/external_data/data/CLM_${LM_MODEL}_grid.txt $PRUDENCE -ifthen -selvar,FR_LAND -setgrid,$WDIR/external_data/data/CLM_${LM_MODEL}_grid.txt $PRUDENCE -selvar,W_SO -setgrid,$WDIR/external_data/data/CLM_${LM_MODEL}_grid.txt -timsort -merge $WDIR/external_data/W_SO_${YYYY}_jja.nc $WDIR/prudence/tmp_${YYYY}_prdnce_W_SO_${pr_region[$i]}.nc
  done
  cdo -s ydaymean  -setname,W_SO_${pr_region[$i]} -fldmean -timsort -merge $WDIR/prudence/tmp_????_prdnce_W_SO_${pr_region[$i]}.nc $WDIR/prudence/prdnce_tseries_W_SO_${pr_region[$i]}.nc 
done
cdo -s -O merge $WDIR/prudence/prdnce_tseries_W_SO_* ${ODIR}/prudence/prudence_fldmean_timeseries_W_SO.nc
rm $WDIR/prudence/tmp_????_prdnce_W_SO_* $WDIR/prudence/prdnce_tseries_W_SO*


