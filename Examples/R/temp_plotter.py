#py_require("matplotlib") 
#py_require("numpy") 
#py_require("pandas") 
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

Tz_hist = r.Tz_hist
APP_hist = r.APP_hist
Iz_hist = r.Iz_hist

levs = np.arange(0,len(Tz_hist[1]),1)
t_steps = np.arange(0,len(Tz_hist),(len(Tz_hist)/10))

fig,ax = plt.subplots(figsize=(20,10))
for t in t_steps:
  ax.plot(Tz_hist[round(t)],-levs)
ax.plot(Tz_hist[-1],-levs,color='k')
ax.grid()
ax.set_xlabel('time')
#plt.show()

Tz_df = pd.DataFrame(Tz_hist)
APP_df = pd.DataFrame(APP_hist)
Iz_df = pd.DataFrame(Iz_hist)

forcings = r.forcings
start_date= str(forcings['TIMESTAMP'][0])
year = start_date[:4]; month=start_date[4:6]; day=start_date[6:8]
start_date = year+"-"+month+"-"+day
Tz_df['date'] = pd.date_range(start=start_date,periods=len(Tz_df),freq="D")
APP_df['date'] = pd.date_range(start=start_date,periods=len(APP_df),freq="D")
Iz_df['date'] = pd.date_range(start=start_date,periods=len(Iz_df),freq="D")

winter = Tz_df[Tz_df['date'].dt.month.isin([1,2,3])].drop(columns='date').mean()
spring = Tz_df[Tz_df['date'].dt.month.isin([4,5,6])].drop(columns='date').mean()
summer = Tz_df[Tz_df['date'].dt.month.isin([7,8,9])].drop(columns='date').mean()
fall =   Tz_df[Tz_df['date'].dt.month.isin([10,11,12])].drop(columns='date').mean()

APP_winter = APP_df[APP_df['date'].dt.month.isin([1,2,3])].drop(columns='date').mean()
APP_spring = APP_df[APP_df['date'].dt.month.isin([4,5,6])].drop(columns='date').mean()
APP_summer = APP_df[APP_df['date'].dt.month.isin([7,8,9])].drop(columns='date').mean()
APP_fall =   APP_df[APP_df['date'].dt.month.isin([10,11,12])].drop(columns='date').mean()

Iz_winter = Iz_df[Iz_df['date'].dt.month.isin([1,2,3])].drop(columns='date').mean()
Iz_spring = Iz_df[Iz_df['date'].dt.month.isin([4,5,6])].drop(columns='date').mean()
Iz_summer = Iz_df[Iz_df['date'].dt.month.isin([7,8,9])].drop(columns='date').mean()
Iz_fall =   Iz_df[Iz_df['date'].dt.month.isin([10,11,12])].drop(columns='date').mean()

fig,ax = plt.subplots(figsize=(20,15),layout="constrained")

ax.plot(APP_winter.values,-1*(winter.index),color="blue",label="winter",linestyle = "--")
ax.plot(APP_spring.values,-1*(spring.index),color="green",label="spring",linestyle = "--")
ax.plot(APP_summer.values,-1*(summer.index),color="orange",label="summer",linestyle = "--")
ax.plot(APP_fall.values,-1*(fall.index),color="red",label="fall",linestyle = "--")
ax1 = ax.twiny()
ax1.plot(winter.values,-1*(winter.index),color="blue",label="winter")
ax1.plot(spring.values,-1*(spring.index),color="green",label="spring")
ax1.plot(summer.values,-1*(summer.index),color="orange",label="summer")
ax1.plot(fall.values,-1*(fall.index),color="red",label="fall")

ax2 = ax.twiny()
ax2.plot(Iz_winter.values,-1*(winter.index),color="pink",label="winter")
ax2.plot(Iz_spring.values,-1*(spring.index),color="pink",label="spring")
ax2.plot(Iz_summer.values,-1*(summer.index),color="pink",label="summer")
ax2.plot(Iz_fall.values,-1*(fall.index),color="pink",label="fall")


ax.legend()
ax.grid()
ax.set_ylabel("depth(M)")
ax1.set_xlabel("Temperature(C)(—)")
ax.set_xlabel("Biomass(gC/M^3)(--)")
ax.set_title("Suggs Lake 25M Depth Profiles")
plt.show()



