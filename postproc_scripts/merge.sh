#!/bin/bash 
#written by David Leutwyler, April 2015, david.leutwyler@alumni.ethz.ch

#Merge into Seasonal Files
for YYYY in $(seq ${YYYY_START} ${YYYY_STOP});do
  if [ ! -f $WDIR/external_data/1h_${YYYY}_jja.nc ]; then
    ncrcat -h $WDIR/external_data/1h/lffd${YYYY}06????.nc $WDIR/external_data/1h/lffd${YYYY}07????.nc $WDIR/external_data/1h/lffd${YYYY}08????.nc -O $WDIR/external_data/1h_${YYYY}_jja_tmp.nc
    cdo -s -O setgrid,$WDIR/external_data/data/CLM_${LM_MODEL}_grid.txt $WDIR/external_data/1h_${YYYY}_jja_tmp.nc $WDIR/external_data/1h_${YYYY}_jja.nc
    rm $WDIR/external_data/1h_${YYYY}_jja_tmp.nc
  fi

  if [ ! -f $WDIR/external_data/rain_${YYYY}_jja.nc ]; then
    if [ $LM_MODEL == lm_c ]; then
      cdo -s -O selvar,TOT_PREC $WDIR/external_data/1h_${YYYY}_jja.nc $WDIR/external_data/rain_${YYYY}_jja.nc
    elif [ $LM_MODEL == lm_f ]; then
      #Ramap to 12km grid since we take conditional percentiles (wh freq) and to reduce the data volume
      cdo -s -O remap,$WDIR/external_data/data/CLM_lm_c_grid.txt,$WDIR/external_data/data/remapweights_lm_f_to_lm_c_con.nc -setgrid,$WDIR/external_data/data/CLM_lm_f_grid.txt -selvar,TOT_PREC $WDIR/external_data/1h_${YYYY}_jja.nc $WDIR/external_data/rain_${YYYY}_jja.nc
    fi
  fi

  if [ ! -f $WDIR/external_data/1h_p_${YYYY}_jja.nc ]; then
    ncrcat -h $WDIR/external_data/1h/lffd${YYYY}06????p.nc $WDIR/external_data/1h/lffd${YYYY}07????p.nc $WDIR/external_data/1h/lffd${YYYY}08????p.nc -O $WDIR/external_data/1h_${YYYY}_jja_p_tmp.nc
    cdo -s -O setgrid,$WDIR/external_data/data/CLM_${LM_MODEL}_grid.txt $WDIR/external_data/1h_${YYYY}_jja_p_tmp.nc $WDIR/external_data/1h_p_${YYYY}_jja.nc
    rm $WDIR/external_data/1h_${YYYY}_jja_p_tmp.nc
  fi

  if [ ! -f $WDIR/external_data/24h_${YYYY}_jja.nc ]; then
    ncrcat -h $WDIR/external_data/24h/lffd${YYYY}06????.nc $WDIR/external_data/24h/lffd${YYYY}07????.nc $WDIR/external_data/24h/lffd${YYYY}08????.nc -O $WDIR/external_data/24h_${YYYY}_jja_tmp.nc
    cdo -s -O setgrid,$WDIR/external_data/data/CLM_${LM_MODEL}_grid.txt $WDIR/external_data/24h_${YYYY}_jja_tmp.nc $WDIR/external_data/24h_${YYYY}_jja.nc
    rm $WDIR/external_data/24h_${YYYY}_jja_tmp.nc
  fi

  #Full time series for W_SO and TOT_PREC, we
  if [ ! -f $WDIR/external_data/W_SO_${YYYY}_jja.nc ]; then
    ncrcat -h -v W_SO $WDIR/external_data/24h/lffd${YYYY}??????.nc -O $WDIR/external_data/W_SO_${YYYY}_jja_tmp.nc
    cdo -s -O setgrid,$WDIR/external_data/data/CLM_${LM_MODEL}_grid.txt $WDIR/external_data/W_SO_${YYYY}_jja_tmp.nc $WDIR/external_data/W_SO_${YYYY}_jja.nc
    rm $WDIR/external_data/W_SO_${YYYY}_jja_tmp.nc
  fi

  if [ ! -f $WDIR/external_data/TOT_PREC_${YYYY}_jja.nc ]; then
    ncrcat -h -v TOT_PREC $WDIR/external_data/1h/lffd${YYYY}??????.nc -O $WDIR/external_data/TOT_PREC_${YYYY}_jja_tmp.nc
    cdo -s -O setgrid,$WDIR/external_data/data/CLM_${LM_MODEL}_grid.txt -selvar,TOT_PREC $WDIR/external_data/TOT_PREC_${YYYY}_jja_tmp.nc $WDIR/external_data/TOT_PREC_${YYYY}_jja.nc
    rm $WDIR/external_data/TOT_PREC_${YYYY}_jja_tmp.nc
  fi

done
   
for YYYY in $(seq 2000 ${YYYY_STOP});do
    cdo -s -O ifthen -selvar,M_ANTICYCLONE $WDIR/external_data/mask_anticyclone_jja_${YYYY}.nc $WDIR/external_data/rain_${YYYY}_jja.nc $WDIR/external_data/rain_anticyclone_${YYYY}_jja.nc
    cdo -s -O ifthen -selvar,M_HIPLOG_TOT $WDIR/external_data/mask_conv_jja_${YYYY}.nc $WDIR/external_data/rain_${YYYY}_jja.nc $WDIR/external_data/rain_conv_${YYYY}_jja.nc
done


