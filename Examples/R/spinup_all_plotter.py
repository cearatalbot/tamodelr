import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

df = r.spinupALL
forcings = r.forcings

fix,ax = plt.subplots(layout="constrained")
ax1 = ax.twinx()
time = df['time']
ax.plot(time,df["Ca1"],color='blue',label="Organic")
ax.plot(time,df["Ca2"],color="blue",label="Organic2",linestyle="--")

#ax.plot(time,df["Ci1"]+df["Ca2"],color='k',label="Inorganic")
#ax.plot(time,df["Ci2"],color="k",label="Inorganic2",linestyle="--")

#ax.plot(time,df["Alg"],color='green',label="Biomass")
#ax1.plot(time,site_forcings["TA_F"],color='red',label="temp",linewidth = .3)
ax.legend()
ax.grid()
ax.set_title("Carbon Pools Spinup Period")
ax.set_ylabel("gC")
ax.set_xlabel("Time (days)")
plt.show()


dyn = r.dyn_simsAll
fix,ax = plt.subplots(layout="constrained")
ax1 = ax.twinx()
time = dyn['time'][2908:6558]
ax.plot(time,dyn["Ca1"][2908:6558],color='blue',label=" Upper Organic")
#ax.plot(time,dyn["Ca2"],color="blue",label="Lower Organic",linestyle="--")

ax.plot(time,dyn["Ci1"][2908:6558],color='k',linewidth =2, alpha = .7,label="Upper Inorganic")
#ax.plot(time,dyn["Ci2"],color="k",label="Inorganic2",linestyle="--")

ax.plot(time,dyn["Alg"][2908:6558],color='green',linewidth =3,label="Biomass")
ax1.plot(time,forcings["TA_F"][2908:6558],color='red',label="Temp",alpha=.2)
ax.legend(fontsize=8,loc='upper left')
ax1.legend(fontsize=8,loc='upper right')
ax.grid()
ax.set_title("Epilimnion Carbon Pools 2011-2021")
ax.set_ylabel("gC")
ax1.set_ylabel("Temperature C$^o$")
ax.set_xlabel("Time (days)")
plt.show()



