#!/bin/bash -l

. /etc/bash.bashrc
module load daint-gpu
module load NCL 
 

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

cdata=$PROJECT/results_clim/lm_c/lffd1993110100c.nc

#Precip
#--------------
for LM_MODEL in lm_c lm_f; do
    datadir=$PROJECT/results_soil-moisture_pertubation/analysis/ctrl/analysis/${LM_MODEL}

    data=$datadir/precip_seasmean_jja.nc
    plotname=$plotdir/$LM_MODEL/seasmean_hourly_precip_amount
    $shdir/sh/pass_args.sh $shdir/precip_seasmean/hourly_precip_seasmean.ncl $data $cdata $plotname 

    #Hourly frequency
    data=$datadir/wh_frequency_seasmean_jja.nc
    plotname=$plotdir/$LM_MODEL/seasmean_wh_freq
    $shdir/sh/pass_args.sh $shdir/precip_seasmean/freq_seasmean.ncl $data $cdata $plotname 

    #p99
    data=$datadir/all_hour_p99_seasmean_jja.nc
    plotname=$plotdir/$LM_MODEL/seasmean_p99
    $shdir/sh/pass_args.sh $shdir/precip_seasmean/p99_seasmean.ncl $data $cdata $plotname 

done

#Convective Precip
#--------------
for LM_MODEL in lm_c lm_f; do
    datadir=$PROJECT/results_soil-moisture_pertubation/analysis/ctrl/analysis/${LM_MODEL}_conv

    data=$datadir/precip_seasmean_jja.nc
    plotname=$plotdir/$LM_MODEL/seasmean_hourly_conv_precip_amount
    $shdir/sh/pass_args.sh $shdir/precip_seasmean/hourly_precip_seasmean.ncl $data $cdata $plotname 

    #Hourly frequency
    data=$datadir/wh_frequency_seasmean_jja.nc
    plotname=$plotdir/$LM_MODEL/seasmean_conv_wh_freq
    $shdir/sh/pass_args.sh $shdir/precip_seasmean/freq_seasmean.ncl $data $cdata $plotname 

    #p99
    data=$datadir/all_hour_p99_seasmean_jja.nc
    plotname=$plotdir/$LM_MODEL/seasmean_conv_p99
    $shdir/sh/pass_args.sh $shdir/precip_seasmean/p99_seasmean.ncl $data $cdata $plotname 

done


# clean away old *.out files
#sbatch job

# clean away old *.out files
rm -f job 2>/dev/null


