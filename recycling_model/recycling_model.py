#!/usr/bin/python
# -*- coding: UTF-8  -*-
import numpy as np
from netCDF4 import *
import sys,os
from scipy.spatial import cKDTree
from math import pi
from numpy import cos, sin
from libarea import area

def tunnel_fast(latvar,lonvar,lat0,lon0):
    '''
    Find closest point in a set of (lat,lon) points to specified point
    latvar - 2D latitude variable from an open netCDF dataset
    lonvar - 2D longitude variable from an open netCDF dataset
    lat0,lon0 - query point
    Returns iy,ix such that the square of the tunnel distance
    between (latval[it,ix],lonval[iy,ix]) and (lat0,lon0)
    is minimum.
    '''
    # Read latitude and longitude from file into numpy arrays
    latvals = np.radians(latvar)
    lonvals = np.radians(lonvar)
    ny,nx = latvals.shape
    lat0_rad = np.radians(lat0)
    lon0_rad = np.radians(lon0)
    # Compute numpy arrays for all values
    clat,clon = cos(latvals),cos(lonvals)
    slat,slon = sin(latvals),sin(lonvals)
    delX = cos(lat0_rad)*cos(lon0_rad) - clat*clon
    delY = cos(lat0_rad)*sin(lon0_rad) - clat*slon
    delZ = sin(lat0_rad) - slat;
    dist_sq = delX**2 + delY**2 + delZ**2
    minindex_1d = dist_sq.argmin()  # 1D index of minimum element
    iy_min,ix_min = np.unravel_index(minindex_1d, latvals.shape)
    return iy_min,ix_min


def haversine(lat1,lon1,lat2, lon2):
    """ Calculate the great-circle distance bewteen two points on the Earth surface.
    input: lon and lat of points
    :output: Returns the distance bewteen the two points. The default unit in meters.

    """
    # convert decimal degrees to radians 
    lon1, lat1, lon2, lat2 = map(np.radians, [lon1, lat1, lon2, lat2])    

    # calculate haversine
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    d = np.sin(dlat / 2.) ** 2 + np.cos(lat1) * np.cos(lat2) * np.sin(dlon / 2. ) ** 2
    return 2 * r_earth * np.arcsin(np.sqrt(d))  # in meters


try:
  ifilename1h_mean = sys.argv[1]  #Mean water fluxes
  twater_begin = sys.argv[2]
  twater_end = sys.argv[3]
  ifilename1h_mean_wet = sys.argv[4]  #Mean water fluxes
  twater_begin_wet = sys.argv[5]
  twater_end_wet = sys.argv[6]
  ifilename_cord = sys.argv[7]
  WestBound = float(sys.argv[8])
  EastBound = float(sys.argv[9])
  SouthBound = float(sys.argv[10])
  NorthBound = float(sys.argv[11])
except:
  print('Problems with Input')
  sys.exit(2)

ncfile1h_mean = Dataset(ifilename1h_mean,mode='r')   #Mean Water Fluxex
ncfile_twater_begin = Dataset(twater_begin,mode='r') #Total vertically integrated water at beginning
ncfile_twater_end = Dataset(twater_end,mode='r')     #Total vertically integrated water at end

ncfile1h_mean_wet = Dataset(ifilename1h_mean_wet,mode='r')   #Mean Water Fluxex,
ncfile_twater_begin_wet = Dataset(twater_begin_wet,mode='r') #Total vertically integrated water at beginning
ncfile_twater_end_wet = Dataset(twater_end_wet,mode='r')     #otal vertically integrated water at end

ncfile_coord = Dataset(ifilename_cord,mode='r')

#Find corresponidng indices of exact points
lon2D = ncfile_coord.variables["lon"][:]
lat2D = ncfile_coord.variables["lat"][:]
latS,lonW = tunnel_fast(lon2D, lat2D, WestBound, SouthBound)
latN,lonE = tunnel_fast(lon2D, lat2D, EastBound, NorthBound)

#Constants
lh_v=2.501*10**6 #Specific latenent heat of vaporization [ J / kg ] 
r_earth=6371000. + 23588.50 / 2 #Radius of the Earth [m] + 1/2 of domain height

#Compute Distances of Edges and domain area, using the haversine formula
dlon_S = haversine(lat2D[latS, lonW-1], lon2D[latS, lonW-1] , lat2D[latS,lonE], lon2D[latS,lonE])
dlon_N = haversine(lat2D[latN, lonW-1], lon2D[latN, lonW-1] , lat2D[latN,lonE], lon2D[latN,lonE])
dlat_W = haversine(lat2D[latS-1,lonW],  lon2D[latS-1,lonW],   lat2D[latN,lonW], lon2D[latN,lonW])
dlat_E = haversine(lat2D[latS-1,lonE],  lon2D[latS-1,lonE],   lat2D[latN,lonE], lon2D[latN,lonE])



#Create Polygon for area
lat_SW = lat2D[latS,lonW]
lon_SW = lon2D[latS,lonW]
lat_SE = lat2D[latS,lonE]
lon_SE = lon2D[latS,lonE]
lat_NW = lat2D[latN,lonW]
lon_NW = lon2D[latN,lonW]
lat_NE = lat2D[latN,lonE]
lon_NE = lon2D[latN,lonE]

S = {'type':'Polygon','coordinates':[[[lon_SW,lat_SW],[lon_SE,lat_SE],[lon_NW,lat_NW],[lon_NE,lat_NE],[lon_SW,lat_SW]]]}
A = area(S)


#Read Data
#--------

#The fluxes are shifted by 1 grid point (staggering)
TwatfluxUa = ncfile1h_mean.variables["TWATFLXU_A"][0, latS:latN, lonW-1:lonE] #kg / m / s
TwatfluxVa = ncfile1h_mean.variables["TWATFLXV_A"][0, latS-1:latN, lonW:lonE] #kg / m / s

TwatfluxUa_wet = ncfile1h_mean_wet.variables["TWATFLXU_A"][0, latS:latN, lonW-1:lonE] #kg / m / s
TwatfluxVa_wet = ncfile1h_mean_wet.variables["TWATFLXV_A"][0, latS-1:latN, lonW:lonE] #kg / m / s

#Water Storage
dW  = ncfile_twater_end.variables["TWATER"][0, latS:latN, lonW:lonE] - ncfile_twater_begin.variables["TWATER"][0, latS:latN, lonW:lonE] #kg / m2 -> kg / m2 / s 
dW = dW.mean() / (3600.* 24. * 92.) #kg / m2 -> kg / m2 / s 

dW_wet  = ncfile_twater_end_wet.variables["TWATER"][0, latS:latN, lonW:lonE] - ncfile_twater_begin_wet.variables["TWATER"][0, latS:latN, lonW:lonE] #kg / m2 -> kg / m2 / s 
dW_wet = dW_wet.mean() / (3600.* 24. * 92.) #kg / m2 -> kg / m2 / s 

#Latent heat Flux
lhfl=ncfile1h_mean.variables["ALHFL_S"][0, latS:latN, lonW:lonE]
ET=lhfl.mean() / lh_v  * (-1) # Latent Heatflux [W/m2] -> Evapotranspiration [ kg / s / m2 ] | (-1) because Flux is defined the other way

lhfl_wet=ncfile1h_mean_wet.variables["ALHFL_S"][0, latS:latN, lonW:lonE]
ET_wet=lhfl_wet.mean() / lh_v  * (-1) # Latent Heatflux [W/m2] -> Evapotranspiration [ kg / s / m2 ] | (-1) because Flux is defined the other way

#Precipitation
P=ncfile1h_mean.variables["TOT_PREC"][0, latS:latN, lonW:lonE]
P=P.mean() / 3600. # [kg / m / h ] -> [kg / m2 / s] 

P_wet=ncfile1h_mean_wet.variables["TOT_PREC"][0, latS:latN, lonW:lonE]
P_wet=P_wet.mean() / 3600. # [kg / m / h ] -> [kg / m2 / s] 

#Compute divergence using Gauss'Theorem
#------------------------------------------------

# Fluxes at boundaries
WFlx=TwatfluxUa[ : , 0 ]
EFlx=TwatfluxUa[ : , -1]
SFlx=TwatfluxVa[ 0 , : ]
NFlx=TwatfluxVa[ -1, : ]

WFlx_wet=TwatfluxUa_wet[ : , 0 ]
EFlx_wet=TwatfluxUa_wet[ : , -1]
SFlx_wet=TwatfluxVa_wet[ 0 , : ]
NFlx_wet=TwatfluxVa_wet[ -1, : ]


# Surface Integral
IN  =  (  np.maximum(0., WFlx).mean() * dlat_W - np.minimum(0., EFlx).mean() * dlat_E + np.maximum(0., SFlx).mean() * dlon_S - np.minimum(0., NFlx).mean() * dlon_N) / A
OUT =  (- np.minimum(0., WFlx).mean() * dlat_W + np.maximum(0., EFlx).mean() * dlat_E - np.minimum(0., SFlx).mean() * dlon_S + np.maximum(0., NFlx).mean() * dlon_N) / A

IN_wet  = (   np.maximum(0., WFlx_wet).mean() * dlat_W - np.minimum(0., EFlx_wet).mean() * dlat_E + np.maximum(0., SFlx_wet).mean() * dlon_S - np.minimum(0., NFlx_wet).mean() * dlon_N) / A
OUT_wet = ( - np.minimum(0., WFlx_wet).mean() * dlat_W + np.maximum(0., EFlx_wet).mean() * dlat_E - np.minimum(0., SFlx_wet).mean() * dlon_S + np.maximum(0., NFlx_wet).mean() * dlon_N) / A

#Split residual equally onto IN and OUT
epsilon  = ET - P + IN - OUT - dW
IN_corr  = IN - epsilon / 2.
OUT_corr = OUT + epsilon / 2.

epsilon_wet  = ET_wet - P_wet + IN_wet - OUT_wet - dW_wet
IN_corr_wet  = IN_wet - epsilon_wet / 2.
OUT_corr_wet = OUT_wet + epsilon_wet / 2.

#For debugging
#print('dW  =', "{:.2e}".format(dW))
#print('ET  =',"{:.2e}".format(ET))
#print('P   =',"{:.2e}".format(P))
#print('IN  =',"{:.2e}".format(IN))
#print('OUT =',"{:.2e}".format(OUT))
#print('INcorr  =', "{:.2e}".format(IN_corr))
#print('OUTcorr =',"{:.2e}".format(OUT_corr))
#print('epsilon = ', "{:.2e}".format(epsilon))
#
#print('dW_wet  =', "{:.2e}".format(dW_wet))
#print('ET_wet  =',"{:.2e}".format(ET_wet))
#print('P_wet   =',"{:.2e}".format(P_wet))
#print('IN_wet  =',"{:.2e}".format(IN_wet))
#print('OUT_wet =',"{:.2e}".format(OUT_wet))
#print('INcorr_wet  =', "{:.2e}".format(IN_corr_wet))
#print('OUTcorr_wet =',"{:.2e}".format(OUT_corr_wet))
#print('epsilon_wet = ', "{:.2e}".format(epsilon_wet))

R= ET / (IN_corr + ET)
CHI= P / (IN_corr + ET)

R_wet= ET_wet / (IN_corr_wet + ET_wet)
CHI_wet= P_wet / (IN_corr_wet + ET_wet)

#Change in water availability
dP_dWtot = CHI_wet * (ET_wet - ET + IN_corr_wet - IN_corr ) * 24 * 3600
#print(dP_dWtot)

#Change in surface effect
dP_surf = CHI_wet * (ET_wet - ET) * 24 * 3600
#print(dP_surf)

#Change in remote effect 
dP_remote = CHI_wet * (IN_corr_wet - IN_corr ) * 24 * 3600
print(dP_remote)

#Change in Precipitation efficiency
dP_CHI = (CHI_wet- CHI) * (ET + IN_corr) * 24 * 3600
#print(dP_CHI)

#delta P
#print((P_wet - P) * 24 * 3600)

#Pmean
#print(0.5 * (P_wet + P) * 24 * 3600)

#If you want to output this, set IN  = IN_corr and OUT = OUT_corr above
error = ((((P_wet - P) *  24 * 3600)/(dP_dWtot + dP_CHI))-1.0) * 100.
#print('error dP   =',"{:.8f}".format(error))


#
#print('R = ', R, '%') 
#print(CHI_wet)

