#Plot diurnal cycle at stations
#Written by David Leutwyler November 2015

import matplotlib.pyplot as plt
import numpy as np
import netCDF4
import sys,os

np.set_printoptions(threshold='nan')

filename_ctrl= sys.argv[1]
filename_dry25= sys.argv[2]
filename_wet25= sys.argv[3]
prudence_region= sys.argv[4]
filename_cfile= sys.argv[5]
plotfile= sys.argv[6]


#Read at stations
ncfile_ctrl = netCDF4.Dataset(filename_ctrl, 'r')
ncfile_dry25 = netCDF4.Dataset(filename_dry25, 'r')
ncfile_wet25 = netCDF4.Dataset(filename_wet25, 'r')

ctrl_d =np.squeeze(ncfile_ctrl.variables['W_SO_'+prudence_region][:])
dry25_d = np.squeeze(ncfile_dry25.variables['W_SO_'+prudence_region][:])
wet25_d = np.squeeze(ncfile_wet25.variables['W_SO_'+prudence_region][:])

cfile = netCDF4.Dataset(filename_cfile, 'r')
soiltype = np.squeeze(cfile.variables['SOILTYP'][:])

#Parameters
porv=np.array([1.E-10, 1.E-10, .364, .445, .455, .475, .507, .863, 1.E-10, 1.E-10]) #pore (void) volume
adp= np.array([0.0   , 0.0   , .012, .030, .035, .060, .065, .098,    0.0,    0.0]) #Air dryness point
soil1 = np.array([0.005, 0.025, 0.07, 0.16, 0.34, 0.70, 1.47, 2.86, 5.74, 11.50], dtype=np.float32) #Thickness of layers 

adp_2D=np.where(soiltype != 9, adp[soiltype.astype(int) - 1], np.nan)
porv_2D=np.where(soiltype != 9, porv[soiltype.astype(int) - 1], np.nan)

print("ADP:", np.nanmean(adp_2D)) 
print("POrv:", np.nanmean(porv_2D)) 

unit_temps = ncfile_ctrl.variables['time'].units
cal_temps = ncfile_ctrl.variables['time'].calendar

time_ctrl = netCDF4.num2date(ncfile_ctrl.variables['time'][:],units = unit_temps,calendar = cal_temps)
time_dry25 = netCDF4.num2date(ncfile_dry25.variables['time'][:],units = unit_temps,calendar = cal_temps)
time_wet25 = netCDF4.num2date(ncfile_wet25.variables['time'][:],units = unit_temps,calendar = cal_temps)

ncfile_ctrl.close()
ncfile_dry25.close()
ncfile_wet25.close()

#SM column / layer thickness
num=6 #number of soil layers
ctrl=np.sum(ctrl_d[:,:num], axis=1)/np.sum(soil1[:num]) 
dry25=np.sum(dry25_d[:,:num],axis=1)/np.sum(soil1[:num])
wet25=np.sum(wet25_d[:, :num],axis=1)/np.sum(soil1[:num])

print("Change:", (wet25[0] + dry25[0]  / ctrl[0]) / 2)

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

#Ticks
#plt.xticks([0,3,6,9,12,15,18,21,24])
#plt.xlabel('Time [UTC]', fontsize='28')

plt.xlim(time_ctrl[0],time_ctrl[-1])
plt.ylim(0,0.45)

# Remove the tick marks; they are unnecessary with the tick lines we just plotted.  
plt.tick_params(axis="both", which="both", bottom="off", top="off",
              labelbottom="on", left="off", right="off", labelleft="on")

plt.grid(True, color=tableau20[15], linestyle='--', linewidth=1, axis='y',zorder=0)


plt.setp(ax.get_xticklabels(), rotation=30, horizontalalignment='right')

#fontsize
for item in ([ax.title, ax.xaxis.label, ax.yaxis.label] +
           ax.get_xticklabels() + ax.get_yticklabels()):

 item.set_fontsize(20)
# item.set_family('Open Sans')

plt.plot(time_dry25,dry25,lw=2.5,color=tableau20[10],label='DRY25',linestyle='-',zorder=3)
plt.plot(time_wet25,wet25,lw=2.5,color=tableau20[0],label='WET25',linestyle='-',zorder=4)
plt.plot(time_ctrl,ctrl,lw=2.5,color='black',label='CTRL',linestyle='-',zorder=2)

plt.legend(loc='upper right',  fontsize='14')

plt.text(0.05, 0.95,prudence_region , transform=ax.transAxes, fontsize=20,
        verticalalignment='bottom')

plt.savefig(plotfile+'.pdf', bbox_inches='tight')

