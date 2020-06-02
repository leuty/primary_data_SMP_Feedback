#!/bin/bash -l
. /etc/bash.bashrc
module load daint-gpu
module load NCL
module load netcdf-python
module load PyExtensions


shdir=~/analysis_soilmoistre_pertubation_10a/ncl
datadir=/project/pr04/davidle/results_soil-moisture_pertubation/analysis
plotdir=/project/pr04/davidle/results_soil-moisture_pertubation/analysis/plots/freq_dist/

if [ ! -d $plotdir ]; then mkdir -p $plotdir; fi
pr_region=(ANALYSIS BI IP FR ME AL MD EA CH BANNI)


#Convective Precipitation

datadir=$SCRATCH/sm_pert_10a
plotdir=/project/pr04/davidle/results_soil-moisture_pertubation/analysis/plots/freq_dist/prcip_conv

if [ ! -d $plotdir ]; then mkdir -p $plotdir; fi
#Mean
for LM_MODEL in lm_c lm_f; do
  plotname=$plotdir/${LM_MODEL}_pr_freq_dist_ANALYSIS
  ctrl=$datadir/analysis_ctrl_${LM_MODEL}/OUTPUT/ctrl/analysis/${LM_MODEL}_conv/prudence/histfreq_TOT_PREC_jja.nc
  wet=$datadir/analysis_wet25_${LM_MODEL}/OUTPUT/wet25/analysis/${LM_MODEL}_conv/prudence/histfreq_TOT_PREC_jja.nc
  dry=$datadir/analysis_dry25_${LM_MODEL}/OUTPUT/dry25/analysis/${LM_MODEL}_conv/prudence/histfreq_TOT_PREC_jja.nc
  python $shdir/precip_histfreq.py $ctrl $wet $dry $plotname
done
