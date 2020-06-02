#!/bin/bash -l
. /etc/bash.bashrc

module load daint-gpu 
module load netcdf-python 

shdir=/users/davidle/analysis_soilmoistre_pertubation_10a/ncl
plotdir=${PROJECT}/results_soil-moisture_pertubation/analysis/plots
if [ ! -d $plotdir ]; then mkdir -p $plotdir; fi
pr_region=(ANALYSIS BI IP FR ME AL MD EA CH DE BANNI)

for LM_MODEL in lm_c lm_f; do
#  for i in {0..10}; do
  for i in 0; do
      ctrl_data=$PROJECT/results_soil-moisture_pertubation/analysis/ctrl/analysis/$LM_MODEL/prudence/prudence_fldmean_timeseries_W_SO.nc
      dry25_data=$PROJECT//results_soil-moisture_pertubation/analysis/dry25/analysis/$LM_MODEL/prudence/prudence_fldmean_timeseries_W_SO.nc
      wet25_data=$PROJECT//results_soil-moisture_pertubation/analysis/wet25/analysis/$LM_MODEL/prudence/prudence_fldmean_timeseries_W_SO.nc
      const=$PROJECT/results_clim/${LM_MODEL}/const.nc
      plotname=$plotdir/$LM_MODEL/timeseries_SM_${pr_region[$i]}
      python $shdir/soilmoist_timeseries.py $ctrl_data $dry25_data $wet25_data ${pr_region[$i]} $const $plotname
    
  done
done


