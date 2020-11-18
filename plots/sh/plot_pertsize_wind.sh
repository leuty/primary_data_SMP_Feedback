#!/bin/bash -l

. /etc/bash.bashrc
module load daint-gpu
module load NCL 
 

PROJECT=/project/pr94/davidle
shdir=/users/davidle/primary_data_SMP_Feedback/plots/
if [ ! -d $plotdir ]; then mkdir -p $plotdir; fi

datadir=/project/pr94/davidle/results_soil-moisture_pertubation/analysis

#Precip
#--------------
for LM_MODEL in lm_c lm_f; do


  #lm_f_domain
  #---------------
  if [ $LM_MODEL == lm_c ]; then
    cdata_model=$PROJECT/results_clim/lm_c/lffd1993110100c.nc
  else
    cdata_model=$PROJECT/results_clim/lm_f/lffd1998110100c.nc
  fi

  #Windspeed
  data=$datadir/wet25-dry25_convdays_200607_lm_f_domain/${LM_MODEL}_wet25_convdays_200607p_timmean.nc
  plotdir=/project/pr94/davidle/results_soil-moisture_pertubation/analysis/plots_lm_f_domain
  plotname=$plotdir/$LM_MODEL/windspeed
  $shdir/sh/pass_args.sh $shdir/U_mag.ncl $data $cdata_model $plotname

  #Difference in windspeed
  data=$datadir/wet25-dry25_convdays_200607_lm_f_domain/${LM_MODEL}_diff_convdays_200607p_timmean.nc
  plotdir=/project/pr94/davidle/results_soil-moisture_pertubation/analysis/plots_lm_f_domain
  plotname=$plotdir/$LM_MODEL/diff_windspeed
  $shdir/sh/pass_args.sh $shdir/U_mag.ncl $data $cdata_model $plotname


  #Alps
  #---------------
  if [ $LM_MODEL == lm_c ]; then
    cdata_model=$PROJECT/results_clim/lm_c/lffd1993110100c.nc
  else
    cdata_model=$PROJECT/results_clim/lm_f/lffd1998110100c.nc
  fi

  #Windspeed
  data=$datadir/wet25-dry25_convdays_200607_Alps/${LM_MODEL}_wet25_convdays_200607p_timmean.nc
  plotdir=/project/pr94/davidle/results_soil-moisture_pertubation/analysis/plots_Alps
  plotname=$plotdir/$LM_MODEL/windspeed_zoom
  $shdir/sh/pass_args.sh $shdir/U_mag_zoom.ncl $data $cdata_model $plotname

  #Difference in windspeed
  data=$datadir/wet25-dry25_convdays_200607_Alps/${LM_MODEL}_diff_convdays_200607p_timmean.nc
  plotdir=/project/pr94/davidle/results_soil-moisture_pertubation/analysis/plots_Alps
  plotname=$plotdir/$LM_MODEL/diff_windspeed_zoom
  $shdir/sh/pass_args.sh $shdir/U_mag_zoom.ncl $data $cdata_model $plotname


#  #Cathy lm_f
#  #----------
#
#  #Windspeed
#  cdata_model=$PROJECT/results_soil-moisture_pertubation/wet25_cathy_lm_f/2006/${LM_MODEL}/1h/lffd2006070100c.nc
#  data=$datadir/wet25-dry25_convdays_200607_cathy_lm_f/${LM_MODEL}_dry25_convdays_200607p_timmean.nc
#  plotdir=/project/pr94/davidle/results_soil-moisture_pertubation/analysis/plots_cathy_lm_f
#  plotname=$plotdir/$LM_MODEL/windspeed_zoom
#  $shdir/sh/pass_args.sh $shdir/U_mag_zoom.ncl $data $cdata_model $plotname
#
#  #Difference in Windspeed
#  cdata_model=$PROJECT/results_soil-moisture_pertubation/wet25_cathy_lm_f/2006/${LM_MODEL}/1h/lffd2006070100c.nc
#  data=$datadir/wet25-dry25_convdays_200607_cathy_lm_f/${LM_MODEL}_diff_convdays_200607p_timmean.nc
#  plotdir=/project/pr94/davidle/results_soil-moisture_pertubation/analysis/plots_cathy_lm_f
#  plotname=$plotdir/$LM_MODEL/diff_windspeed_zoom
#  $shdir/sh/pass_args.sh $shdir/U_mag_zoom.ncl $data $cdata_model $plotname

done

