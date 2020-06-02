#!/bin/bash -l

export USERGRP=pr04
export BINDIR=/users/${USER}/analysis_soilmoistre_pertubation_10a

export YYYY_START=1999
export MM_START=06
export DD_START=01
export ZZ_START=00

export YYYY_STOP=2008
export MM_STOP=08
export DD_STOP=31
export ZZ_STOP=00

export LM_MODEL=${1:-lm_c}

#Validation Data
export EOBS_PR=/project/$USERGRP/observations/pr/ENS/rr_0.25deg_reg_v10.0.nc
export EOBS_T_2M=/project/$USERGRP/observations/t2m/ENS/tg_0.25deg_reg_v10.0.nc
export EOBS_T_MIN=/project/$USERGRP/observations/t2m/ENS/tn_0.25deg_reg_v10.0.nc
export EOBS_T_MAX=/project/$USERGRP/observations/t2m/ENS/tx_0.25deg_reg_v10.0.nc
export EXTERNAL_DATA=/users/$USER/lmp/bin/postprocessing/data

#Grid descriptions
export CLM_GRID=$EXTERNAL_DATA/CLM_${LM_MODEL}_grid.txt
export CLM_TERRAIN=$EXTERNAL_DATA/CLM_${LM_MODEL}_terrain.nc
export EOBS_TERRAIN=$EXTERNAL_DATA/elev_0.25deg_reg_v10.0.nc
export EOBS_GRID=$EXTERNAL_DATA/e-obs_rr_9_grid.txt
export REMAPWEIGHTS=$EXTERNAL_DATA/remapweights_${LM_MODEL}_to_e-obs_con.nc
export PRUDENCE_MASK=$EXTERNAL_DATA/${LM_MODEL}_PRUDENCE_MASKS_LAND.nc
export PRUDENCE_MASK_EOBS=$EXTERNAL_DATA/EOBS_PRUDENCE_MASKS_LAND.nc
export PRUDENCE_MASK=$EXTERNAL_DATA/${LM_MODEL}_PRUDENCE_MASKS_LAND.nc

#CDO Options
export CDO_PCTL_NBINS=100

for exp in ctrl dry25 wet25; do

  export exp=$exp
  export logfiles=${BINDIR}/logfiles_${exp}

  export ADIR=/project/$USERGRP/davidle/results_soil-moisture_pertubation/$exp   #The archive on /project
  export PDIR=$ADIR/postprocessing/$LM_MODEL                                     #The postprocessed data 
  export WDIR=$SCRATCH/sm_pert_10a/analysis_${exp}_${LM_MODEL}   #Working directory
  
  #Create necessary directories
  if [ ! -d $WDIR/external_data/data ]; then mkdir -p $WDIR/external_data/data; fi
  if [ ! -d $WDIR/external_data ]; then mkdir -p $WDIR/external_data; fi
  if [ ! -d $WDIR/external_data/validation_data ]; then mkdir -p $WDIR/external_data/validation_data; fi
  if [ ! -d $WDIR/precip ]; then mkdir -p $WDIR/precip; fi
  if [ ! -d $WDIR/precip/freqdist ]; then mkdir -p $WDIR/precip/freqdist; fi
  if [ ! -d $WDIR/prudence ]; then mkdir -p $WDIR/prudence; fi
  if [ ! -d $WDIR/soilmoisture ]; then mkdir -p $WDIR/soilmoisture; fi
  if [ ! -d $WDIR/recycling_rate ]; then mkdir -p $WDIR/recycling_rate; fi
  if [ ! -d logfiles_${exp} ]; then mkdir logfiles_${exp} ; fi

  #Link /scratch Data dir
#  ln -nsf $WDIR/../${exp}/output/${LM_MODEL}/1h $WDIR/external_data/ 
#  ln -nsf $WDIR/../${exp}/output/${LM_MODEL}/24h $WDIR/external_data/

  export ODIR=$WDIR/OUTPUT/${exp}/analysis/$LM_MODEL                                      #Output directory

  #Output Dirs
  if [ ! -d $ODIR   ]; then mkdir -p $ODIR ; fi
  if [ ! -d $ODIR/prudence   ]; then mkdir -p $ODIR/prudence ; fi

  #Submit Jobs
  #Copy Data
  jobid_copy_data=`sbatch ${BINDIR}/jobfiles/job_copy_data | cut -d' ' -f4`
  jobid_copy_external_data=`sbatch ${BINDIR}/jobfiles/job_copy_external_data | cut -d' ' -f4`
  jobid_merge=`sbatch --dependency=afterok:${jobid_copy_data} ${BINDIR}/jobfiles/job_merge | cut -d' ' -f4`
  jobid_means=`sbatch --dependency=afterok:${jobid_merge} ${BINDIR}/jobfiles/job_means | cut -d' ' -f4`
  jobid_means_conv=`sbatch --dependency=afterok:${jobid_merge} ${BINDIR}/jobfiles/job_means_conv | cut -d' ' -f4`
  jobid_daycylces=`sbatch --dependency=afterok:${jobid_merge} ${BINDIR}/jobfiles/job_daycycles | cut -d' ' -f4`
  jobid_histfreq=`sbatch --dependency=afterok:${jobid_merge} ${BINDIR}/jobfiles/job_histfreq | cut -d' ' -f4`
  jobid_histfreq_conv=`sbatch --dependency=afterok:${jobid_merge} ${BINDIR}/jobfiles/job_histfreq_conv | cut -d' ' -f4`
  jobid_timeseries=`sbatch --dependency=afterok:${jobid_merge_vw_so_rel} ${BINDIR}/jobfiles/job_timeseries | cut -d' ' -f4`

done #experiments

#Cleanup
if ls ${BINDIR}/slurm-* 1> /dev/null 2>&1 ; then rm -f ${BINDIR}/slurm-* ; fi
