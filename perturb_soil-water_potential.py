#!/usr/bin/env python
# -*- coding: utf-8 -*-
#Perturb the soil-moisture potential of COSMO model data.
#
#Input/Output
#
#ifilename:     A NetCDF file containing a soil-moisture field W_SO (for instance a laf-file)
#ofilename:     Output file which will contain the modified soil water content W_SO
#scale_factor:  The factor by which the soil-water potential should be scale
#written by David Leutwyler, March 2016

import numpy as np
from netCDF4 import *
import sys,os

try:
  ifilename    = sys.argv[1] #W_SO
  ofilename    = sys.argv[2] #Output File
  scale_factor = sys.argv[3] #Scale Factor
except:
  print('Synopsis: python perturb_soil-water_potential.py <inputfile.nc> <outputfile.nc> <scale_factor>')
  sys.exit(2)

ncfile = Dataset(ifilename,mode='r')

# Output File
if ".nc" not in ofilename:
  ofilename = ofilename + '.nc'
ofile = Dataset(ofilename,mode='w')

#Read Data
w_so = ncfile.variables["W_SO"][:,:,:,:]
soil1_bnds = ncfile.variables["soil1_bnds"][:,:]
soiltype = np.squeeze(ncfile.variables["SOILTYP"][:])


#Parameters
porv=np.array([1.E-10, 1.E-10, .364, .445, .455, .475, .507, .863, 1.E-10, 1.E-10]) #pore (void) volume
adp= np.array([0.0   , 0.0   , .012, .030, .035, .060, .065, .098,    0.0,    0.0]) #Air dryness point

ldpths=soil1_bnds[:,1]-soil1_bnds[:,0]

#Compute volumetric soil moisture content
vw_so=w_so/ldpths[np.newaxis,:,np.newaxis,np.newaxis]

#Compute soil-water water_potential
swp=(vw_so-adp[soiltype.astype(int)-1])/(porv[soiltype.astype(int)-1]-adp[soiltype.astype(int)-1])

#Modify soil-water potential
swp=swp+float(scale_factor)

#Apply limiter since the soil-water potential can not exceed 1.0
swp=np.clip(swp,0.0,1.0)

#Compute modifed volumetric soil moisture content
vw_so=(porv[soiltype.astype(int)-1]-adp[soiltype.astype(int)-1])*swp + adp[soiltype.astype(int)-1]

#Compute modifed soil water content
w_so=vw_so*ldpths[np.newaxis,:,np.newaxis,np.newaxis]

#Copy dimensions
for dname, the_dim in ncfile.dimensions.items():
  if dname in ncfile.variables["W_SO"].dimensions or ncfile.variables["soil1_bnds"].dimensions:
    ofile.createDimension(dname, len(the_dim) if not the_dim.isunlimited() else None)

for v_name, varin in ncfile.variables.items():
  #Write dimension variables
  if v_name in ncfile.variables["W_SO"].dimensions or v_name == "rotated_pole" or v_name == "soil1_bnds":
    outVar = ofile.createVariable(v_name, varin.datatype, varin.dimensions)

    #Copy variable attributes
    outVar.setncatts({k: varin.getncattr(k) for k in varin.ncattrs()})

    outVar[:] = varin[:]

  #Write modifed soil water content
  if v_name == "W_SO":
    outVar = ofile.createVariable(v_name, varin.datatype, varin.dimensions)

    # Copy variable attributes
    outVar.setncatts({k: varin.getncattr(k) for k in varin.ncattrs()})
    outVar[:] = w_so[:]

#Cleanup
ofile.close()
ncfile.close()
