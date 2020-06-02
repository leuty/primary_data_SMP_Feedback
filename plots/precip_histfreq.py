#Plot diurnal cycle at stations
#Written by David Leutwyler November 2015

import matplotlib.pyplot as plt
import matplotlib.ticker as mtick
import numpy as np
import pandas as pd                #time series analysis
import netCDF4
from math import pi
from numpy import cos, sin
from scipy.spatial import cKDTree
import sys,os

#np.set_printoptions(threshold='nan')

#Remove stations that contain spurious Data

try:
  filename_ctrl= sys.argv[1]
  filename_wet= sys.argv[2]
  filename_dry= sys.argv[3]
  plotfile= sys.argv[4]
except:
  print(os.path.basename(__file__) + ': I/O bug')
  sys.exit(2)


ncfile_ctrl = netCDF4.Dataset(filename_ctrl, 'r',maskandscale=True)
ncfile_wet= netCDF4.Dataset(filename_wet, 'r',maskandscale=True)
ncfile_dry   = netCDF4.Dataset(filename_dry, 'r',maskandscale=True)

#Read histograms
phist_ctrl = ncfile_ctrl.variables['histfreq_ANALYSIS'][:]
phist_wet = ncfile_wet.variables['histfreq_ANALYSIS'][:]
phist_dry = ncfile_dry.variables['histfreq_ANALYSIS'][:]

bin_bnds = ncfile_ctrl.variables['bin_bnds'][:]
bins = np.mean(bin_bnds,axis=1)

#Mean frequency in a bin and multiply by bin center
# -> amount of precip a bin contributes to the total

phist_ctrl=np.squeeze(phist_ctrl)[100:]
phist_wet=np.squeeze(phist_wet)[100:]
phist_dry=np.squeeze(phist_dry)[100:]
bins=np.squeeze(bins)[100:]

#Reverse cumulative sum
phist_ctrl=np.cumsum(phist_ctrl[::-1])[::-1]
phist_wet=np.cumsum(phist_wet[::-1])[::-1]
phist_dry=np.cumsum(phist_dry[::-1])[::-1]

#Relative to wet day frequency
phist_ctrl/=phist_ctrl[0]
phist_wet/=phist_wet[0]
phist_dry/=phist_dry[0]

#Create Plot
#-----------------------------------------

# These are the "Tableau 20" colors as RGB.
tableau20 = [(31, 119, 180), (174, 199, 232), (255, 127, 14), (255, 187, 120),
             (44, 160, 44), (152, 223, 138), (214, 39, 40), (255, 152, 150),
             (148, 103, 189), (197, 176, 213), (140, 86, 75), (196, 156, 148),
             (227, 119, 194), (247, 182, 210), (127, 127, 127), (199, 199, 199),
             (188, 189, 34), (219, 219, 141), (23, 190, 207), (158, 218, 229)]

# Scale the RGB values to the [0, 1] range, which is the format matplotlib accepts.
for i in range(len(tableau20)):
    r, g, b = tableau20[i]
    tableau20[i] = (r / 255., g / 255., b / 255.)


#make Plots

plt.figure(figsize=(12, 9))

ax = plt.subplot(111)

# Remove the plot frame lines. They are unnecessary chartjunk.  
ax.spines["top"].set_visible(False)
ax.spines["bottom"].set_visible(False)  
ax.spines["right"].set_visible(False)
ax.spines["left"].set_visible(False)

ax.set_xscale('log')
ax.set_yscale('log')

#Ticks
ax.set_xlim(0.1,6)
ax.set_ylim(0.005,1.1)

#ax.set_xticks([0.1, 0.2, 0.5,1,2,5])
ax.set_xticks([0.1, 0.2, 0.5,1,2,5,10, 20])
ax.set_yticks([0.005, 0.01, 0.02, 0.05, 0.1, 0.2, 0.5,1])

ax.get_xaxis().set_major_formatter(mtick.ScalarFormatter())
ax.get_yaxis().set_major_formatter(mtick.ScalarFormatter())

#plt.ylim(0.01,40)

# Remove the tick marks; they are unnecessary with the tick lines we just plotted.  
plt.tick_params(axis="both", which="both", bottom=True, top=False,
                labelbottom=True, left=False, right=False, labelleft=True)

plt.grid(True, color=tableau20[15], linestyle='--', linewidth=1, axis='y',zorder=0)

#fontsize
for item in ([ax.title, ax.xaxis.label, ax.yaxis.label] +
           ax.get_xticklabels() + ax.get_yticklabels()):
 item.set_fontsize(24)
# item.set_family('Open Sans')

plt.plot(bins,phist_ctrl,lw=2.5,color='black',label='CTRL',linestyle='-',zorder=3)
plt.plot(bins,phist_wet,lw=2.5,color=tableau20[0],label='WET',linestyle='-',zorder=4)
plt.plot(bins,phist_dry, lw=2.5,color=tableau20[10],label='DRY',linestyle='-',zorder=2)

plt.savefig(plotfile+'.pdf', bbox_inches='tight')

