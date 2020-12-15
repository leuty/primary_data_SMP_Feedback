#!/bin/bash -l

. /etc/bash.bashrc
module load daint-gpu
module load NCL 
module load CDO 
 

shdir=/users/davidle/primary_data_SMP_Feedback/plots
if [ ! -d $plotdir ]; then mkdir -p $plotdir; fi

datadir=/project/pr94/davidle/results_soil-moisture_pertubation/analysis
cdata=/project/pr94/davidle/results_soil-moisture_pertubation/ctrl/1999/lm_c/1h/lffd1999050100c.nc

#Precip
#--------------
for LM_MODEL in lm_c lm_f; do
  echo $LM_MODEL

  #Western_Alps_x3
  #---------------
  if [ $LM_MODEL == lm_c ]; then
    cdata_model=$PROJECT/results_clim/lm_c/lffd1993110100c.nc
  else
    cdata_model=$PROJECT/results_clim/lm_f/lffd1998110100c.nc
  fi

  #Convdays 200607
  data=$datadir/wet25-dry25_convdays_200607_Western_Alps_x3/${LM_MODEL}_diff_convdays_200607_timmean.nc
  plotdir=/project/pr94/davidle/results_soil-moisture_pertubation/analysis/plots_Western_Alps_x3
  plotname=$plotdir/$LM_MODEL/wet25-dry25_convdays_precip_amount_zoom
  $shdir/sh/pass_args.sh $shdir/wet25-dry25_convdays/diff_precip_amount_twatfluxes_Alps.ncl $data $cdata_model $plotname

  #All 200607
  data=$datadir/wet25-dry25_convdays_200607_Western_Alps_x3/${LM_MODEL}_diff_200607_timmean.nc
  plotdir=/project/pr94/davidle/results_soil-moisture_pertubation/analysis/plots_Western_Alps_x3
  plotname=$plotdir/$LM_MODEL/wet25-dry25_precip_amount_zoom
  $shdir/sh/pass_args.sh $shdir/wet25-dry25_convdays/diff_precip_amount_twatfluxes_Alps.ncl $data $cdata_model $plotname

  #Region
  data=$HOME/postproc_data/mask_Western_Alps_x3_${LM_MODEL}.nc
  plotdir=/project/pr94/davidle/results_soil-moisture_pertubation/analysis/plots_Western_Alps_x3
  plotname=$plotdir/$LM_MODEL/region
  $shdir/sh/pass_args.sh $shdir/wet25-dry25_convdays/region.ncl $data $cdata_model $plotname

  #Alps
  #---------------
  if [ $LM_MODEL == lm_c ]; then
    cdata_model=$PROJECT/results_clim/lm_c/lffd1993110100c.nc
  else
    cdata_model=$PROJECT/results_clim/lm_f/lffd1998110100c.nc
  fi

  #Convdays 200607
  plotdir=/project/pr94/davidle/results_soil-moisture_pertubation/analysis/plots_Alps

  #amount twatfluxes
  data=$datadir/wet25-dry25_convdays_200607_Alps/${LM_MODEL}_diff_convdays_200607_timmean.nc
  plotname=$plotdir/$LM_MODEL/wet25-dry25_convdays_precip_amount_zoom
  $shdir/sh/pass_args.sh $shdir/wet25-dry25_convdays/diff_precip_amount_twatfluxes_Alps.ncl $data $cdata_model $plotname

  #amount twatfluxes
  data=$datadir/wet25-dry25_convdays_200607_Alps/${LM_MODEL}_diff_convdays_200607_timmean.nc
  cdo -s output -mulc,24 -fldmean -ifthen -selvar,MASK $HOME/postproc_data/mask_cathy_${LM_MODEL}.nc -selvar,TOT_PREC $data 
  plotname=$plotdir/$LM_MODEL/wet25-dry25_convdays_precip_amount_nowatfluxes_zoom
  $shdir/sh/pass_args.sh $shdir/wet25-dry25_convdays/diff_precip_amount_Alps.ncl $data $cdata_model $plotname

  #wet-hour frequency
  data=$datadir/wet25-dry25_convdays_200607_Alps/${LM_MODEL}_wethours_wet25-dry25_convdays_200607.nc
  cdo -s output -mulc,100 -fldmean -ifthen -selvar,MASK $HOME/postproc_data/mask_cathy_${LM_MODEL}.nc -selvar,TOT_PREC $data 
  plotname=$plotdir/$LM_MODEL/wet25-dry25_convdays_precip_frequency_zoom
  $shdir/sh/pass_args.sh $shdir/wet25-dry25_convdays/diff_precip_frequency_Alps.ncl $data $cdata_model $plotname

  #all-hour p99
  data=$datadir/wet25-dry25_convdays_200607_Alps/${LM_MODEL}_all-hour-p99_wet25-dry25_convdays_200607.nc
  cdo -s output -mulc,24 -fldmean -ifthen -selvar,MASK $HOME/postproc_data/mask_cathy_${LM_MODEL}.nc -selvar,TOT_PREC $data 
  plotname=$plotdir/$LM_MODEL/wet25-dry25_convdays_precip_p99_zoom
  $shdir/sh/pass_args.sh $shdir/wet25-dry25_convdays/diff_precip_p99_Alps.ncl $data $cdata_model $plotname


  #All 200607
  data=$datadir/wet25-dry25_convdays_200607_Alps/${LM_MODEL}_diff_200607_timmean.nc
  plotdir=/project/pr94/davidle/results_soil-moisture_pertubation/analysis/plots_Alps
  plotname=$plotdir/$LM_MODEL/wet25-dry25_precip_amount_zoom
  $shdir/sh/pass_args.sh $shdir/wet25-dry25_convdays/diff_precip_amount_twatfluxes_Alps.ncl $data $cdata_model $plotname

  #Region
  data=$HOME/postproc_data/mask_cathy_${LM_MODEL}.nc
  plotdir=/project/pr94/davidle/results_soil-moisture_pertubation/analysis/plots_Alps
  plotname=$plotdir/$LM_MODEL/region
  $shdir/sh/pass_args.sh $shdir/wet25-dry25_convdays/region.ncl $data $cdata_model $plotname

 #Europe lm_f
  #---------------

  if [ $LM_MODEL == lm_f ]; then
   cdata_model=$PROJECT/results_clim/lm_f/lffd1998110100c.nc 
  else
    cdata_model=$PROJECT/results_clim/lm_c/lffd1993110100c.nc
  fi

  #Convdays 200607
  data=$datadir/wet25-dry25_convdays_200607_lm_f_domain/${LM_MODEL}_diff_convdays_200607_timmean.nc
  plotdir=/project/pr94/davidle/results_soil-moisture_pertubation/analysis/plots_lm_f_domain
  plotname=$plotdir/$LM_MODEL/wet25-dry25_convdays_precip_amount_zoom
  $shdir/sh/pass_args.sh $shdir/wet25-dry25_convdays/diff_precip_amount_twatfluxes_Alps_1.ncl $data $cdata_model $plotname #use ncl script with switched water fluxes, bug in output routine

  #All 200607
  data=$datadir/wet25-dry25_convdays_200607_lm_f_domain/${LM_MODEL}_diff_200607_timmean.nc
  plotdir=/project/pr94/davidle/results_soil-moisture_pertubation/analysis/plots_lm_f_domain
  plotname=$plotdir/$LM_MODEL/wet25-dry25_precip_amount_zoom
  $shdir/sh/pass_args.sh $shdir/wet25-dry25_convdays/diff_precip_amount_twatfluxes_Alps_1.ncl $data $cdata_model $plotname #use ncl script with switched water fluxes, bug in output routine
done


