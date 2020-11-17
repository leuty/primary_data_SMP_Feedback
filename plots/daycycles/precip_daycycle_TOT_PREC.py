#Plot diurnal cycle at stations
#Written by David Leutwyler November 2015

import matplotlib.pyplot as plt
import numpy as np
import netCDF4
import sys,os

class Experiment:

  def __init__(self,var):
    self.data  = np.zeros((24,10))
    self.var = var

  def read_data(self, path, region):

    for i in range(10):
      YYYY = i + 1999
      ncfile=netCDF4.Dataset(path + '/prudence_fldmean_daycycle_'+ str(YYYY) +'_'+self.var+'.nc', 'r')
      self.data[:,i]=np.squeeze(ncfile.variables['TOT_PREC_' + region][:])
      ncfile.close()
 
    #Convert to mm/day
    self.data = 24 * self.data

  def apply_periodic(self):
    self.data=np.vstack((self.data,self.data[0,:]))

  def min(self):
    return np.amin(self.data, axis=0)

  def max(self):
    return np.amax(self.data, axis=0)

  def mean(self):
    return np.mean(self.data, axis=1)

  def std(self):
    return np.std(self.data, axis=1)

#Parse command line
try:
  ctrl_path=sys.argv[1]
  dry25_path=sys.argv[2]
  wet25_path=sys.argv[3]
  var=sys.argv[4]
  prudence_region= sys.argv[5]
  plotfile= sys.argv[6]
except:
  print(os.path.basename(__file__) + ': I/O bug')
  sys.exit(2)


#Define Experiments
ctrl = Experiment(var)
wet25 = Experiment(var)
dry25 = Experiment(var)

#Read Data
ctrl.read_data(ctrl_path, prudence_region)
wet25.read_data(wet25_path, prudence_region)
dry25.read_data(dry25_path, prudence_region)

#Make data series periodic
ctrl.apply_periodic()
wet25.apply_periodic()
dry25.apply_periodic()


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
plt.xlim(0,24)
plt.xticks([0,3,6,9,12,15,18,21,24])
plt.xlabel('Time [UTC]', fontsize='28')

if prudence_region == 'ANALYSIS':
  plt.ylim(0.,3.5)
#elif prudence_region == 'AL':
#  plt.ylim(0.,.35)
#elif prudence_region == 'BI':
#  plt.ylim(0.,.2)
#elif prudence_region == 'EA':
#  plt.ylim(0.,.24)
#elif prudence_region == 'FR':
#  plt.ylim(0.,.2)
#elif prudence_region == 'IP':
#  plt.ylim(0.,.1)
#elif prudence_region == 'MD':
#  plt.ylim(0.,.20)
#elif prudence_region == 'ME':
#  plt.ylim(0.,.22)

# Remove the tick marks; they are unnecessary with the tick lines we just plotted.  
plt.tick_params(axis="both", which="both", bottom=False, top=False,
              labelbottom=True, left=False, right=False, labelleft=True)

plt.grid(True, color=tableau20[15], linestyle='--', linewidth=1, axis='y',zorder=0)


#fontsize
for item in ([ax.title, ax.xaxis.label, ax.yaxis.label] +
           ax.get_xticklabels() + ax.get_yticklabels()):

 item.set_fontsize(20)
# item.set_family('Open Sans')

plt.fill_between(np.arange(25), ctrl.mean() + ctrl.std(), ctrl.mean() - ctrl.std(),facecolor='black', alpha=0.3)
plt.fill_between(np.arange(25), dry25.mean() + dry25.std(), dry25.mean() - dry25.std(),facecolor=tableau20[10], alpha=0.15)
plt.fill_between(np.arange(25), wet25.mean() + wet25.std(), wet25.mean() - wet25.std(),facecolor=tableau20[0], alpha=0.15)

plt.plot(ctrl.mean(), lw=4,color='black',label='CTRL',linestyle='-',zorder=2)
plt.plot(dry25.mean(),lw=4,color=tableau20[10],label='DRY25',linestyle='-',zorder=3)
plt.plot(wet25.mean(),lw=4,color=tableau20[0],label='WET25',linestyle='-',zorder=4)

plt.legend(loc='upper right',  fontsize='14')

plt.text(0.05, 0.95,prudence_region , transform=ax.transAxes, fontsize=20,
        verticalalignment='bottom')

plt.savefig(plotfile+'.pdf', bbox_inches='tight')

#Difference in diurnal maxima
dP = np.zeros((100))
for i in range(10):
    for j in range(10):
        dP[i*j] =  wet25.max()[i] - dry25.max()[j]
print("mean" , np.max(wet25.mean()) - np.max(dry25.mean()))
print("std" , np.std(dP))




