#!/bin/bash -l
#written by David Leutwyler, October 2015, david.leutwyler@@alumni.ethz.ch

pr_region=(ANALYSIS BI IP FR ME AL MD EA)

export CDO_PCTL_NBINS=1001

for YYYY in $(seq ${YYYY_START} ${YYYY_STOP});do
  FILE=$WDIR/external_data/rain_${YYYY}_jja.nc

  cdo -s dhourmean $WDIR/external_data/1h_${YYYY}_jja.nc $ODIR/daycycle_1h_${YYYY}_jja.nc
  cdo -s dhourmean $WDIR/external_data/1h_p_${YYYY}_jja.nc $ODIR/daycycle_1h_p_${YYYY}_jja.nc

  cdo -s dhourmean $FILE $ODIR/daycycle_precip_${YYYY}_jja.nc 
  cdo -s dhourmean -gtc,0.1 $FILE $ODIR/daycycle_wh_freq_${YYYY}_jja.nc #Wet-hour Frequency

  #Diurnal Cylces
  for i in $(seq -w 00 23); do

    #Means
   # cdo -s timmean -settime,${i}:00:00 -selhour,$i $WDIR/external_data/1h_${YYYY}_jja.nc $WDIR/precip/daycycle_${YYYY}_jja_${i}.nc 1> /dev/null 2>&1 & 

    #Precip Means
    #cdo -s timmean -settime,${i}:00:00 -selhour,$i $FILE $WDIR/precip/daycycle_precip_${YYYY}_jja_${i}.nc 1> /dev/null 2>&1 & 
    #cdo -s monmean -settime,${i}:00:00 -selhour,${i} $FILE $WDIR/precip/daycycle_precip_monmean_${YYYY}_jja_${i}.nc 1> /dev/null 2>&1 & 

    #Precip Frequency
   # cdo -s timmean -settime,${i}:00:00 -gtc,0.1 -selhour,$i -selvar,TOT_PREC $FILE $WDIR/precip/daycycle_wh_freq_${YYYY}_jja_${i}.nc 1> /dev/null 2>&1 &

    #Precip All_hour p90
    cdo -s timpctl,90 -settime,${i}:00:00 -selhour,$i -selvar,TOT_PREC $FILE -timmin -selhour,$i -selvar,TOT_PREC $FILE -timmax -selhour,$i -selvar,TOT_PREC $FILE $WDIR/precip/daycycle_all_hour_p90_${YYYY}_jja_${i}.nc 1> /dev/null 2>&1 &

    #Precip All_hour p95
    cdo -s timpctl,95 -settime,${i}:00:00 -selhour,$i -selvar,TOT_PREC $FILE -timmin -selhour,$i -selvar,TOT_PREC $FILE -timmax -selhour,$i -selvar,TOT_PREC $FILE $WDIR/precip/daycycle_all_hour_p95_${YYYY}_jja_${i}.nc 1> /dev/null 2>&1 &

    #All_hour p99
    cdo -s timpctl,99 -settime,${i}:00:00 -selhour,$i -selvar,TOT_PREC $FILE -timmin -selhour,$i -selvar,TOT_PREC $FILE -timmax -selhour,$i -selvar,TOT_PREC $FILE $WDIR/precip/daycycle_all_hour_p99_${YYYY}_jja_${i}.nc 1> /dev/null 2>&1 &

    #All_hour p99.5
    cdo -s timpctl,99.5 -settime,${i}:00:00 -selhour,$i -selvar,TOT_PREC $FILE -timmin -selhour,$i -selvar,TOT_PREC $FILE -timmax -selhour,$i -selvar,TOT_PREC $FILE $WDIR/precip/daycycle_all_hour_p99_5_${YYYY}_jja_${i}.nc 1> /dev/null 2>&1 &

    #All_hour p99.9
    cdo -s timpctl,99.9 -settime,${i}:00:00 -selhour,$i -selvar,TOT_PREC $FILE -timmin -selhour,$i -selvar,TOT_PREC $FILE -timmax -selhour,$i -selvar,TOT_PREC $FILE $WDIR/precip/daycycle_all_hour_p99_9_${YYYY}_jja_${i}.nc 1> /dev/null 2>&1 &

    wait

  done

  #cdo -s -O mergetime $WDIR/precip/daycycle_${YYYY}_jja_??.nc $ODIR/daycycle_1h_${YYYY}_jja.nc
 # cdo -s -O mergetime $WDIR/precip/daycycle_precip_${YYYY}_jja_??.nc $ODIR/daycycle_precip_${YYYY}_jja.nc
  #cdo -s -O mergetime $WDIR/precip/daycycle_wh_freq_${YYYY}_jja_??.nc $ODIR/daycycle_wh_freq_${YYYY}_jja.nc
  cdo -s -O mergetime $WDIR/precip/daycycle_all_hour_p90_${YYYY}_jja_??.nc $ODIR/daycycle_all_hour_p90_${YYYY}_jja.nc
  cdo -s -O mergetime $WDIR/precip/daycycle_all_hour_p95_${YYYY}_jja_??.nc $ODIR/daycycle_all_hour_p95_${YYYY}_jja.nc
  cdo -s -O mergetime $WDIR/precip/daycycle_all_hour_p99_${YYYY}_jja_??.nc $ODIR/daycycle_all_hour_p99_${YYYY}_jja.nc
  cdo -s -O mergetime $WDIR/precip/daycycle_all_hour_p99_5_${YYYY}_jja_??.nc $ODIR/daycycle_all_hour_p99_5_${YYYY}_jja.nc
  cdo -s -O mergetime $WDIR/precip/daycycle_all_hour_p99_9_${YYYY}_jja_??.nc $ODIR/daycycle_all_hour_p99_9_${YYYY}_jja.nc

  rm $WDIR/precip/daycycle_all_hour_p90_${YYYY}_jja_??.nc $WDIR/precip/daycycle_all_hour_p95_${YYYY}_jja_??.nc $WDIR/precip/daycycle_all_hour_p99_${YYYY}_jja_??.nc $WDIR/precip/daycycle_all_hour_p99_5_${YYYY}_jja_??.nc $WDIR/precip/daycycle_all_hour_p99_9_${YYYY}_jja_??.nc 

done

cdo -s yhourmean -timsort -cat $ODIR/daycycle_precip_????_jja.nc $ODIR/daycycle_precip_seasmean_jja.nc
cdo -s yhourmean -timsort -cat $ODIR/daycycle_1h_????_jja.nc $ODIR/daycycle_1h_seasmean_jja.nc
cdo -s yhourmean -timsort -cat $ODIR/daycycle_wh_freq_????_jja.nc $ODIR/daycycle_wh_freq_seasmean_jja.nc
cdo -s yhourmean -timsort -cat $ODIR/daycycle_all_hour_p90_????_jja.nc $ODIR/daycycle_all_hour_p90_seasmean_jja.nc
cdo -s yhourmean -timsort -cat $ODIR/daycycle_all_hour_p95_????_jja.nc $ODIR/daycycle_all_hour_p95_seasmean_jja.nc
cdo -s yhourmean -timsort -cat $ODIR/daycycle_all_hour_p99_????_jja.nc $ODIR/daycycle_all_hour_p99_seasmean_jja.nc
cdo -s yhourmean -timsort -cat $ODIR/daycycle_all_hour_p99_5_????_jja.nc $ODIR/daycycle_all_hour_p99_5_seasmean_jja.nc
cdo -s yhourmean -timsort -cat $ODIR/daycycle_all_hour_p99_9_????_jja.nc $ODIR/daycycle_all_hour_p99_9_seasmean_jja.nc

#Diurnal Cycles in PRUDENCE regions
#-----------------------
for YYYY in $(seq ${YYYY_START} ${YYYY_STOP}) seasmean;do
  PRUDENCE=$WDIR/external_data/data/lm_c_PRUDENCE_MASKS_LAND.nc
  for vars in TOT_PREC; do
    for i in {0..7}; do
      cdo -s ifthen -selvar,MASK_${pr_region[$i]} -setgrid,$WDIR/external_data/data/CLM_lm_c_grid.txt $PRUDENCE -ifthen -selvar,FR_LAND -setgrid,$WDIR/external_data/data/CLM_lm_c_grid.txt $PRUDENCE -selvar,${vars} -setgrid,$WDIR/external_data/data/CLM_lm_c_grid.txt $ODIR/daycycle_precip_${YYYY}_jja.nc $WDIR/prudence/tmp_prdnce_${YYYY}_${vars}_${pr_region[$i]}.nc
      cdo -s copy -setname,${vars}_${pr_region[$i]} -fldmean $WDIR/prudence/tmp_prdnce_${YYYY}_${vars}_${pr_region[$i]}.nc $WDIR/prudence/prdnce_${YYYY}_${vars}_${pr_region[$i]}.nc
    done
    cdo -s -O merge $WDIR/prudence/prdnce_${YYYY}_${vars}* ${ODIR}/prudence/prudence_fldmean_daycycle_${YYYY}_${vars}.nc
    rm $WDIR/prudence/tmp_prdnce_${YYYY}_${vars}_*.nc $WDIR/prudence/prdnce_${YYYY}_${vars}*
  done

  for vars in wh_freq all_hour_p90 all_hour_p95 all_hour_p99 all_hour_p99_5 all_hour_p99_9; do
    for i in {0..7}; do
      cdo -s ifthen -selvar,MASK_${pr_region[$i]} -setgrid,$WDIR/external_data/data/CLM_lm_c_grid.txt $PRUDENCE -ifthen -selvar,FR_LAND -setgrid,$WDIR/external_data/data/CLM_lm_c_grid.txt $PRUDENCE -setgrid,$WDIR/external_data/data/CLM_lm_c_grid.txt $ODIR/daycycle_${vars}_${YYYY}_jja.nc $WDIR/prudence/tmp_prdnce_${YYYY}_${vars}_${pr_region[$i]}.nc
      cdo -s copy -setname,TOT_PREC_${pr_region[$i]} -fldmean $WDIR/prudence/tmp_prdnce_${YYYY}_${vars}_${pr_region[$i]}.nc $WDIR/prudence/prdnce_${YYYY}_${vars}_${pr_region[$i]}.nc
    done
    cdo -s -O merge  $WDIR/prudence/prdnce_${YYYY}_${vars}* ${ODIR}/prudence/prudence_fldmean_daycycle_${YYYY}_${vars}.nc
    rm $WDIR/prudence/tmp_prdnce_${YYYY}_${vars}_* $WDIR/prudence/prdnce_${YYYY}_${vars}* 
  done

  PRUDENCE=$WDIR/external_data/data/${LM_MODEL}_PRUDENCE_MASKS_LAND.nc
  for vars in T_2M ASHFL_S ALHFL_S; do
    for i in {0..7}; do
      cdo -s ifthen -selvar,MASK_${pr_region[$i]} -setgrid,$WDIR/external_data/data/CLM_${LM_MODEL}_grid.txt $PRUDENCE -ifthen -selvar,FR_LAND -setgrid,$WDIR/external_data/data/CLM_${LM_MODEL}_grid.txt $PRUDENCE -selvar,${vars} -setgrid,$WDIR/external_data/data/CLM_${LM_MODEL}_grid.txt $ODIR/daycycle_1h_${YYYY}_jja.nc $WDIR/prudence/tmp_prdnce_${YYYY}_${vars}_${pr_region[$i]}.nc
      cdo -s copy -setname,${vars}_${pr_region[$i]} -fldmean $WDIR/prudence/tmp_prdnce_${YYYY}_${vars}_${pr_region[$i]}.nc $WDIR/prudence/prdnce_${YYYY}_${vars}_${pr_region[$i]}.nc
    done
    cdo -s -O merge $WDIR/prudence/prdnce_${YYYY}_${vars}* ${ODIR}/prudence/prudence_fldmean_daycycle_${YYYY}_${vars}.nc
    rm $WDIR/prudence/tmp_prdnce_${YYYY}_${vars}_*.nc $WDIR/prudence/prdnce_${YYYY}_${vars}*
  done
done


