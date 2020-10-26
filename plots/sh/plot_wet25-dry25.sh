#!/bin/bash -l

. /etc/bash.bashrc
module load daint-gpu
module load NCL 
module load netcdf-python
module load PyExtensions
module load CDO

 

shdir=/users/davidle/primary_data_SMP_Feedback/plots


datadir=/project/pr94/davidle/results_soil-moisture_pertubation/analysis/
maskfile=/users/davidle/postproc_data/lm_c_PRUDENCE_MASKS_LAND.nc
workdir=$SCRATCH/sm_pert_10a/analysis_wet25-dry25
if [ ! -d $workdir ] ; then mkdir $workdir ; fi 

#Precipitation Amount
for LM_MODEL in lm_c lm_f; do
  echo "means" $LM_MODEL
  cdo -s -ifthen -selvar,FR_LAND $maskfile -ifthen -selvar,MASK_ANALYSIS $maskfile -sub  $datadir/wet25/analysis/${LM_MODEL}/precip_seasmean_jja.nc $datadir/dry25/analysis/${LM_MODEL}/precip_seasmean_jja.nc $workdir/${LM_MODEL}_wet25-dry25_precip_jja.nc
   echo $( cdo -s output -mulc,24 -fldmean  $workdir/${LM_MODEL}_wet25-dry25_precip_jja.nc )

  cdo -s -ifthen -selvar,FR_LAND $maskfile -ifthen -selvar,MASK_ANALYSIS $maskfile -sub  $datadir/wet25/analysis/${LM_MODEL}/wh_frequency_seasmean_jja.nc $datadir/dry25/analysis/${LM_MODEL}/wh_frequency_seasmean_jja.nc $workdir/${LM_MODEL}_wet25-dry25_wh_freq_jja.nc
  echo $( cdo -s output -mulc,100 -fldmean  $workdir/${LM_MODEL}_wet25-dry25_wh_freq_jja.nc )

  cdo -s -ifthen -selvar,FR_LAND $maskfile -ifthen -selvar,MASK_ANALYSIS $maskfile -sub  $datadir/wet25/analysis/${LM_MODEL}/all_hour_p99_seasmean_jja.nc $datadir/dry25/analysis/${LM_MODEL}/all_hour_p99_seasmean_jja.nc $workdir/${LM_MODEL}_wet25-dry25_all_hour_p99_jja.nc
  echo $( cdo -s output -mulc,24 -fldmean  $workdir/${LM_MODEL}_wet25-dry25_all_hour_p99_jja.nc )
done


for LM_MODEL in lm_c lm_f; do
  echo "Stdiv" $LM_MODEL
  for YYYY in {1999..2008}; do
    cdo -s -ifthen -selvar,FR_LAND $maskfile -ifthen -selvar,MASK_ANALYSIS $maskfile -sub  $datadir/wet25/analysis/${LM_MODEL}/precip_seasmean_${YYYY}_jja.nc $datadir/dry25/analysis/${LM_MODEL}/precip_seasmean_${YYYY}_jja.nc $workdir/${LM_MODEL}_wet25-dry25_precip_jja_${YYYY}.nc


    cdo -s -ifthen -selvar,FR_LAND $maskfile -ifthen -selvar,MASK_ANALYSIS $maskfile -sub  $datadir/wet25/analysis/${LM_MODEL}/wh_frequency_${YYYY}_jja.nc $datadir/dry25/analysis/${LM_MODEL}/wh_frequency_${YYYY}_jja.nc $workdir/${LM_MODEL}_wet25-dry25_wh_frequency_jja_${YYYY}.nc

    cdo -s -ifthen -selvar,FR_LAND $maskfile -ifthen -selvar,MASK_ANALYSIS $maskfile -sub  $datadir/wet25/analysis/${LM_MODEL}/all_hour_p99_${YYYY}_jja.nc $datadir/dry25/analysis/${LM_MODEL}/all_hour_p99_${YYYY}_jja.nc $workdir/${LM_MODEL}_wet25-dry25_all_hour_p99_jja_${YYYY}.nc

  done

   cdo -s timstd -cat $workdir/${LM_MODEL}_wet25-dry25_precip_jja_????.nc $workdir/${LM_MODEL}_wet25-dry25_precip_std_jja.nc
  echo $( cdo -s output -mulc,24 -timstd -fldmean -cat $workdir/${LM_MODEL}_wet25-dry25_precip_jja_????.nc )

   cdo -s timstd -cat $workdir/${LM_MODEL}_wet25-dry25_wh_frequency_jja_????.nc $workdir/${LM_MODEL}_wet25-dry25_wh_frequency_std_jja.nc
  echo $( cdo -s output -mulc,100 -timstd -fldmean -cat $workdir/${LM_MODEL}_wet25-dry25_wh_frequency_jja_????.nc )

   cdo -s timstd -cat $workdir/${LM_MODEL}_wet25-dry25_all_hour_p99_jja_????.nc $workdir/${LM_MODEL}_wet25-dry25_all_hour_p99_std_jja.nc
  echo $( cdo -s output -mulc,24 -timstd -fldmean -cat $workdir/${LM_MODEL}_wet25-dry25_all_hour_p99_jja_????.nc )
done

cdata=/project/pr94/davidle/results_soil-moisture_pertubation/wet25_lm_f/2006/lm_c/1h/lffd2006070100c.nc
plotdir=/project/pr94/davidle/results_soil-moisture_pertubation/analysis/plots/wet25-dry25

#Absolute Changes
for LM_MODEL in lm_c lm_f; do
    data=$workdir/${LM_MODEL}_wet25-dry25_precip_jja.nc
    datas=$workdir/${LM_MODEL}_wet25-dry25_precip_std_jja.nc
    plotname=$plotdir/${LM_MODEL}_wet25-dry25_precip_jja
    $shdir/sh/pass_args.sh $shdir/wet25-dry25/diff_precip_clim.ncl $data $datas $cdata 5 1 $plotname

    data=$workdir/${LM_MODEL}_wet25-dry25_wh_freq_jja.nc
    datas=$workdir/${LM_MODEL}_wet25-dry25_wh_frequency_std_jja.nc
    plotname=$plotdir/${LM_MODEL}_wet25-dry25_wh_freq_jja
    $shdir/sh/pass_args.sh $shdir/wet25-dry25/diff_wh_freq_clim.ncl $data $datas $cdata 12 3 $plotname

    data=$workdir/${LM_MODEL}_wet25-dry25_all_hour_p99_jja.nc
    datas=$workdir/${LM_MODEL}_wet25-dry25_all_hour_p99_std_jja.nc
    plotname=$plotdir/${LM_MODEL}_wet25-dry25_all_hour_p99_jja
    $shdir/sh/pass_args.sh $shdir/wet25-dry25/diff_precip_clim.ncl $data $datas $cdata 70 14 $plotname
done

