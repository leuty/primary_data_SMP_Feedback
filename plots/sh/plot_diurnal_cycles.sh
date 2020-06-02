#!/bin/bash -l

. /etc/bash.bashrc
module load daint-gpu
module load PyExtensions 
module load netcdf-python

shdir=/users/davidle/analysis_soilmoistre_pertubation_10a/ncl
plotdir=/project/pr04/davidle/results_soil-moisture_pertubation/analysis/plots
if [ ! -d $plotdir ]; then mkdir -p $plotdir; fi
pr_region=(ANALYSIS BI IP FR ME AL MD EA)

#Precipitation
cat >> job <<EOF_job
#!/usr/local/bin/bash -l
#SBATCH --job-name="ncl"
#SBATCH --time=01:20:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --output=dcycle.out
#SBATCH --error=dcycle.err
#SBATCH --partition=normal
#SBATCH --constraint=gpu
#SBATCH --account=pr04

EOF_job

datadir=/project/pr04/davidle/results_soil-moisture_pertubation/analysis

#Precip
#--------------
for vars in TOT_PREC wh_freq all_hour_p99;do
  for LM_MODEL in lm_c lm_f; do
    #for i in {0..7}; do
    for i in 0; do
      ctrl_data=$datadir/ctrl/analysis/${LM_MODEL}/prudence/
      dry25_data=$datadir/dry25/analysis/${LM_MODEL}/prudence/
      wet25_data=$datadir/wet25/analysis/${LM_MODEL}/prudence/
      plotname=$plotdir/$LM_MODEL/diurnal_cycle/diurnal_cycle_${vars}_${pr_region[$i]}
      echo srun python3 $shdir/daycycles/precip_daycycle_${vars}.py $ctrl_data $dry25_data $wet25_data $vars ${pr_region[$i]} $plotname >> job
      python3 $shdir/daycycles/precip_daycycle_${vars}.py $ctrl_data $dry25_data $wet25_data $vars ${pr_region[$i]} $plotname
    done
  done
done




# clean away old *.out files
#sbatch job

# clean away old *.out files
rm -f job 2>/dev/null

