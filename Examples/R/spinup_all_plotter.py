import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

df = r.spinupALL_kd
forcings = r.forcings

fix,ax = plt.subplots(layout="constrained")
ax1 = ax.twinx()
time = df['time']
ax.plot(time,df["Ca"],color='blue',label="Organic")
ax.plot(time,df["Ci"],color="grey",label="Inorganic")
ax.plot(time,df["Alg"],color='green',label="Biomass")
#ax1.plot(time,forcings["TA_F"],color='red',label="temp",linewidth = .3)
ax.legend()
ax.grid()
ax.set_title("Carbon Pools Spinup Period")
ax.set_ylabel("gC")
ax.set_xlabel("Time (days)")
plt.show()

#print(df["Alg"]/(730000*25))
#adn red is air temperaprint(df["Ca"]/(730000*25))
