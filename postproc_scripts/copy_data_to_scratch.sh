#!/bin/bash 
#written by David Leutwyler, April 2015, david.leutwyler@alumni.ethz.ch

#constants fiels
ln -nsf $WDIR/external_data/1h/lffd${YYYY_START}050100c.nc $WDIR/external_data/data/lm_const.nc 

#Copy Files
for YYYY in $(seq ${YYYY_START} ${YYYY_STOP});do
# Comment as data has been move to archive
#    rsync -a --ignore-existing ${ADIR}/${YYYY}/${LM_MODEL}/1h/lffd${YYYY}??????p.nc $WDIR/external_data/1h/
#
#  for stream in 1h 24h; do
#    rsync -a --ignore-existing ${ADIR}/${YYYY}/${LM_MODEL}/${stream}/lffd${YYYY}??????.nc $WDIR/external_data/${stream}/
#    rsync -a --ignore-existing ${ADIR}/${YYYY}/${LM_MODEL}/${stream}/lffd${YYYY}??????c.nc $WDIR/external_data/${stream}/
#  done

  #sync data from store  
  #tar --strip-components=7 -C $WDIR/external_data/ -xvf /store/c2sm/pr04/davidle/results_soil-moisture_pertubation/ctrl/${YYYY}.tar project/pr04/davidle/results_soil-moisture_pertubation/ctrl/${YYYY}/${LM_MODEL}

  rsync -a --ignore-existing $PROJECT/results_clim/diurnal_convection_masks/anticyclone850_anom/mask_anticyclone_jja_????.nc $WDIR/external_data/
  rsync -a --ignore-existing $PROJECT/results_clim/diurnal_convection_masks/hi-pres_lo-grad/lm_c/mask_conv_jja_????.nc $WDIR/external_data/

done

