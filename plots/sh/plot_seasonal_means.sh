#!/bin/bash -l

. /etc/bash.bashrc
module load daint-gpu
module load NCL 
module load CDO
 

shdir=/users/davidle/primary_data_SMP_Feedback/plots/
plotdir=/project/pr94/davidle/results_soil-moisture_pertubation/analysis/plots
if [ ! -d $plotdir ]; then mkdir -p $plotdir; fi
pr_region=(ANALYSIS BI IP FR ME AL MD EA)


#Precip
#--------------
for LM_MODEL in lm_c lm_f; do
    datadir=$PROJECT/results_soil-moisture_pertubation/analysis/ctrl/analysis/${LM_MODEL}
    cdata=$PROJECT/results_clim/lm_c/lffd1993110100c.nc

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

    #Latent Heatflux
    cdata=$PROJECT/results_clim/${LM_MODEL}/const.nc
    data=$datadir/1h_seasmean_jja.nc
    plotname=$plotdir/$LM_MODEL/seasmean_lhflx
    $shdir/sh/pass_args.sh $shdir/seasonal_mean_lhfl.ncl $data $cdata $plotname 

    maskfile=/users/davidle/postproc_data/${LM_MODEL}_PRUDENCE_MASKS_LAND.nc
    echo "LHFLX mean" $LM_MODEL
    echo $( cdo -s output -fldmean -selvar,ALHFL_S -ifthen -selvar,FR_LAND $maskfile -ifthen -selvar,MASK_ANALYSIS $maskfile $data )
    cdo -s ifthen -selvar,FR_LAND $maskfile -ifthen -selvar,MASK_ANALYSIS $maskfile -selvar,ALHFL_S,ASHFL_S -cat $datadir/1h_seasmean_????_jja.nc $SCRATCH/1h_seasmean_1999-2008_jja.nc
    echo $( cdo -s output -timstd -fldmean -selvar,ALHFL_S $SCRATCH/1h_seasmean_1999-2008_jja.nc )

    #Sensible Heatflux
    cdata=$PROJECT/results_clim/${LM_MODEL}/const.nc
    data=$datadir/1h_seasmean_jja.nc
    plotname=$plotdir/$LM_MODEL/seasmean_shflx
    $shdir/sh/pass_args.sh $shdir/seasonal_mean_shfl.ncl $data $cdata $plotname 

    echo "SHFLX mean" $LM_MODEL
    echo $( cdo -s output -fldmean -selvar,ASHFL_S -ifthen -selvar,FR_LAND $maskfile -ifthen -selvar,MASK_ANALYSIS $maskfile $data )
    echo $( cdo -s output -timstd -fldmean -selvar,ASHFL_S $SCRATCH/1h_seasmean_1999-2008_jja.nc )
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
rm -f job 2>/dev/null


