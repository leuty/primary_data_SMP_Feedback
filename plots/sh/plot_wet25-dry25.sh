#!/bin/bash -l

. /etc/bash.bashrc
module load daint-gpu
module load NCL 
module load netcdf-python
module load PyExtensions
module load CDO

 

shdir=/users/davidle/analysis_soilmoistre_pertubation_10a/ncl


cdata=/project/pr04/davidle/results_clim/lm_c/lffd1993110100c.nc
datadir=/project/pr04/davidle/results_soil-moisture_pertubation/analysis/
maskfile=/users/davidle/postproc_data/lm_c_PRUDENCE_MASKS_LAND.nc
workdir=$SCRATCH/sm_pert_10a/analysis_wet25-dry25
if [ ! -d $workdir ] ; then mkdir $workdir ; fi 

#Precipitation Amount
for LM_MODEL in lm_c lm_f; do
  cdo -s -ifthen -selvar,FR_LAND $cdata -ifthen -selvar,MASK_ANALYSIS $maskfile -sub  $datadir/wet25/analysis/${LM_MODEL}/precip_seasmean_jja.nc $datadir/dry25/analysis/${LM_MODEL}/precip_seasmean_jja.nc $workdir/${LM_MODEL}_wet25-dry25_precip_jja.nc
  cdo -s -ifthen -selvar,FR_LAND $cdata -ifthen -selvar,MASK_ANALYSIS $maskfile -sub  $datadir/wet25/analysis/${LM_MODEL}/wh_frequency_seasmean_jja.nc $datadir/dry25/analysis/${LM_MODEL}/wh_frequency_seasmean_jja.nc $workdir/${LM_MODEL}_wet25-dry25_wh_freq_jja.nc
  cdo -s -ifthen -selvar,FR_LAND $cdata -ifthen -selvar,MASK_ANALYSIS $maskfile -sub  $datadir/wet25/analysis/${LM_MODEL}/all_hour_p99_seasmean_jja.nc $datadir/dry25/analysis/${LM_MODEL}/all_hour_p99_seasmean_jja.nc $workdir/${LM_MODEL}_wet25-dry25_all_hour_p99_jja.nc
  cdo -s -ifthen -selvar,FR_LAND $cdata -ifthen -selvar,MASK_ANALYSIS $maskfile -sub  $datadir/wet25/analysis/${LM_MODEL}/eff_soil_sat_jja.nc $datadir/dry25/analysis/${LM_MODEL}/eff_soil_sat_jja.nc $workdir/${LM_MODEL}_wet25-dry25_eff_soil_sat_jja.nc
done

cdata=$PROJECT/results_clim/lm_c/lffd1993110100c.nc
plotdir=/project/pr04/davidle/results_soil-moisture_pertubation/analysis/plots/wet25-dry25

#Absolute Changes
for LM_MODEL in lm_c lm_f; do
    data=$workdir/${LM_MODEL}_wet25-dry25_precip_jja.nc
    plotname=$plotdir/${LM_MODEL}_wet25-dry25_precip_jja
    $shdir/sh/pass_args.sh $shdir/wet25-dry25/diff_precip_clim.ncl $data $cdata -5 5 1 $plotname

    data=$workdir/${LM_MODEL}_wet25-dry25_wh_freq_jja.nc
    plotname=$plotdir/${LM_MODEL}_wet25-dry25_wh_freq_jja
    $shdir/sh/pass_args.sh $shdir/wet25-dry25/diff_wh_freq_clim.ncl $data $cdata -12 12 3 $plotname

    data=$workdir/${LM_MODEL}_wet25-dry25_all_hour_p99_jja.nc
    plotname=$plotdir/${LM_MODEL}_wet25-dry25_all_hour_p99_jja
    $shdir/sh/pass_args.sh $shdir/wet25-dry25/diff_precip_clim.ncl $data $cdata -80 80 20 $plotname
done

