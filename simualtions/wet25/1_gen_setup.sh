#!/bin/bash

#Experiment Name
exp=${PWD##*/}

if [ ! -d output ]; then mkdir output ;fi

#Loop over ensemble memebers
for YYYY in {1999..2008};do

 #ifs2lm -> gen ini files, BD generated by gen_boundaries
 if [ ! -d output/ifs2lm ]; then mkdir output/ifs2lm ;fi
 rm -rf 1_ifs2lm_${YYYY} > /dev/null
 cp -r TMPL_1_ifs2lm 1_ifs2lm_${YYYY}
 sed -i "s/YYYY/${YYYY}/g" 1_ifs2lm_${YYYY}/run

 #lm_c
 if [ ! -d output/lm_c ]; then mkdir output/lm_c ;fi
 rm -rf 2_lm_c_${YYYY} > /dev/null
 cp -r TMPL_2_lm_c 2_lm_c_${YYYY}
 sed -i "s/ydate_ini=.*/ydate_ini='${YYYY}050100',/g" 2_lm_c_${YYYY}/run
 sed -i "s/YYYY/${YYYY}/g" 2_lm_c_${YYYY}/run

 #lm2lm -> gen ini files, BD generated by gen_boundaries
 if [ ! -d output/lm2lm ]; then mkdir output/lm2lm ;fi
 rm -rf 3_lm2lm_${YYYY} > /dev/null
 cp -r TMPL_3_lm2lm 3_lm2lm_${YYYY}
 sed -i "s/YYYY/${YYYY}/g" 3_lm2lm_${YYYY}/run

 #lm_f May
 if [ ! -d output/lm_f ]; then mkdir output/lm_f ;fi
 rm -rf 4_lm_f_${YYYY} > /dev/null
 cp -r TMPL_4_lm_f 4_lm_f_${YYYY}
 sed -i "s/YYYY/${YYYY}/g" 4_lm_f_${YYYY}/run
 sed -i "s/#SBATCH --time=.*/#SBATCH --time=08:00:00/g" 4_lm_f_${YYYY}/run

 #lm_f JJA
 if [ ! -d output/lm_f ]; then mkdir output/lm_f ;fi
 rm -rf 5_lm_f_${YYYY} > /dev/null
 cp -r TMPL_4_lm_f 5_lm_f_${YYYY}
 sed -i "s/hstart=.*/hstart=744,/g" 5_lm_f_${YYYY}/run
 sed -i "s/hstop=.*/hstop=2952,/g" 5_lm_f_${YYYY}/run
 sed -i "s/nhour_restart=.*/nhour_restart=2952,0,2952,,/g" 5_lm_f_${YYYY}/run
 sed -i "s/YYYY/${YYYY}/g" 5_lm_f_${YYYY}/run
 sed -i "s?ydirini='./input/',?ydirini='../4_lm_f_${YYYY}/output',?g" 5_lm_f_${YYYY}/run

 #put data
 archive=$PROJECT/results_soil-moisture_pertubation
 if [ -d 6_put_data_${YYYY} ]; then rm -rf 6_put_data_${YYYY} ;fi
 cp  -rf TMPL_6_put_data 6_put_data_${YYYY}

 if [ ! -d $archive/${exp} ]; then mkdir $archive/${exp} ;fi
 if [ ! -d $archive/${exp}/${YYYY} ]; then mkdir $archive/${exp}/${YYYY} ;fi

 ln -s $archive/${exp}/${YYYY} 6_put_data_${YYYY}/output

 #DEBUG
 ln -s ../2_lm_c_${YYYY}/ 6_put_data_${YYYY}/debug_lm_c
 ln -s ../4_lm_f_${YYYY}/ 6_put_data_${YYYY}/debug_lm_f

 sed -i "s/YYYY/${YYYY}/g" 6_put_data_${YYYY}/run

done


