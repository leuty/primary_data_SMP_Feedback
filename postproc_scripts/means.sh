#!/bin/bash -l
#written by David Leutwyler, October 2015, david.leutwyler@@alumni.ethz.ch

PRUDENCE=$WDIR/external_data/data/${LM_MODEL}_PRUDENCE_MASKS_LAND.nc
pr_region=(ANALYSIS BI IP FR ME AL MD EA)

for YYYY in $(seq ${YYYY_START} ${YYYY_STOP});do
  FILE=$WDIR/external_data/rain_${YYYY}_jja.nc

  #Means
  cdo -s timmean $WDIR/external_data/1h_${YYYY}_jja.nc $ODIR/1h_seasmean_${YYYY}_jja.nc
  cdo -s timmean $FILE $ODIR/precip_seasmean_${YYYY}_jja.nc
  cdo -s monmean $FILE $ODIR/precip_monmean_${YYYY}_jja.nc
  #cdo -s timmean $WDIR/external_data/1h_p_${YYYY}_jja.nc $ODIR/1h_p_seasmean_${YYYY}_jja.nc
  cdo -s timmean $WDIR/external_data/24h_${YYYY}_jja.nc $ODIR/24h_seasmean_${YYYY}_jja.nc

  #Wethour Frequency
  cdo -s timmean -gtc,0.1 -selvar,TOT_PREC $FILE $ODIR/wh_frequency_${YYYY}_jja.nc

  #All_hour p90
  cdo -s timpctl,90 -selvar,TOT_PREC $FILE -timmin -selvar,TOT_PREC $FILE -timmax -selvar,TOT_PREC $FILE $ODIR/all_hour_p90_${YYYY}_jja.nc 

  #All_hour p90
  cdo -s timpctl,95 -selvar,TOT_PREC $FILE -timmin -selvar,TOT_PREC $FILE -timmax -selvar,TOT_PREC $FILE $ODIR/all_hour_p95_${YYYY}_jja.nc 

  #All_hour p99
  cdo -s timpctl,99 -selvar,TOT_PREC $FILE -timmin -selvar,TOT_PREC $FILE -timmax -selvar,TOT_PREC $FILE $ODIR/all_hour_p99_${YYYY}_jja.nc 

  #All_hour p99.5
  cdo -s timpctl,99.5 -selvar,TOT_PREC $FILE -timmin -selvar,TOT_PREC $FILE -timmax -selvar,TOT_PREC $FILE $ODIR/all_hour_p99_5_${YYYY}_jja.nc 

  #All_hour p99.9
  cdo -s timpctl,99.9 -selvar,TOT_PREC $FILE -timmin -selvar,TOT_PREC $FILE -timmax -selvar,TOT_PREC $FILE $ODIR/all_hour_p99_9_${YYYY}_jja.nc 

  #Wetday Frequency
  cdo -s -timmean -gtc,1 -daysum -selvar,TOT_PREC $FILE $ODIR/wd_frequency_${YYYY}_jja.nc

  #All_day p90
  cdo -s timpctl,90 -daysum -selvar,TOT_PREC $FILE -timmin -daysum -selvar,TOT_PREC $FILE -timmax -daysum -selvar,TOT_PREC $FILE $ODIR/all_day_p90_${YYYY}_jja.nc 

  #All_day p95
  cdo -s timpctl,95 -daysum -selvar,TOT_PREC $FILE -timmin -daysum -selvar,TOT_PREC $FILE -timmax -daysum -selvar,TOT_PREC $FILE $ODIR/all_day_p95_${YYYY}_jja.nc 

  #All_day p99
  cdo -s timpctl,99 -daysum -selvar,TOT_PREC $FILE -timmin -daysum -selvar,TOT_PREC $FILE -timmax -daysum -selvar,TOT_PREC $FILE $ODIR/all_day_p99_${YYYY}_jja.nc 

done

#Seasonal means
ncra -h $ODIR/1h_seasmean_????_jja.nc -O $ODIR/1h_seasmean_jja.nc
ncra -h $ODIR/precip_seasmean_????_jja.nc -O $ODIR/precip_seasmean_jja.nc
ncra -h $ODIR/precip_monmean_????_jja.nc -O $ODIR/precip_monmean_jja.nc
ncra -h $ODIR/1h_p_seasmean_????_jja.nc -O $ODIR/1h_p_seasmean_jja.nc
ncra -h $ODIR/24h_seasmean_????_jja.nc -O $ODIR/24h_seasmean_jja.nc

#Wethour Frequency
ncra -h $ODIR/wh_frequency_????_jja.nc -O $ODIR/wh_frequency_seasmean_jja.nc

#All_hour p90
ncra -h $ODIR/all_hour_p90_????_jja.nc -O $ODIR/all_hour_p90_seasmean_jja.nc

#All_hour p95
ncra -h $ODIR/all_hour_p95_????_jja.nc -O $ODIR/all_hour_p95_seasmean_jja.nc

#All_hour p99
ncra -h $ODIR/all_hour_p99_????_jja.nc -O $ODIR/all_hour_p99_seasmean_jja.nc

#Wetday Frequency
ncra -h $ODIR/wd_frequency_????_jja.nc -O $ODIR/wd_frequency_seasmean_jja.nc

#All_day p90
ncra -h $ODIR/all_day_p90_????_jja.nc -O $ODIR/all_day_p90_seasmean_jja.nc

#All_day p95
ncra -h $ODIR/all_day_p95_????_jja.nc -O $ODIR/all_day_p95_seasmean_jja.nc

#All_day p99
ncra -h $ODIR/all_day_p99_????_jja.nc -O $ODIR/all_day_p99_seasmean_jja.nc


