import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from matplotlib.colors import LogNorm
from matplotlib.ticker import LogFormatterMathtext
import numpy as np
import pandas as pd




Tz_hist = r.Tz_hist
Tz_df = pd.DataFrame(Tz_hist)
APP_hist = r.APP_hist
APP_df = pd.DataFrame(APP_hist)
Iz_hist = r.Iz_hist
Iz_df = pd.DataFrame(Iz_hist)
levs = np.arange(0,len(Tz_hist[1]),1)
dz = r.dz

forcings = r.forcings
start_date= str(forcings['TIMESTAMP'][0])
year = start_date[:4]; month=start_date[4:6]; day=start_date[6:8]
start_date = year+"-"+month+"-"+day
dates = pd.date_range(start=start_date, periods=len(Tz_hist), freq="D")



plt.show()
def three():
    fig = plt.figure(figsize=(18,36), constrained_layout = False)
    spec = gridspec.GridSpec(ncols=1, nrows=3, figure=fig)
    ax0=fig.add_subplot(spec[0,0])
    ax1=fig.add_subplot(spec[1,0])
    ax2=fig.add_subplot(spec[2,0])
    return(ax0,ax1,ax2)

def doyfillplot(ax,dat,clevs,cmap,cb_lab,title):
  #create a doy veradge
  dat=dat.copy()
  dat['date'] = pd.date_range(start=start_date,periods=len(dat),freq="D")
  dat = dat.set_index('date')
  dat = dat.groupby(dat.index.dayofyear).mean()
  levs =  np.arange(0,dat.shape[1],1)
  
  #plot
  x=dat.index
  y= -1*levs* dz
  z = dat[levs].values.T
  contourf = ax.contourf(
    x,y,z,
    levels=clevs,
    cmap=cmap,
    extend='both'
  )
  ax.figure.colorbar(contourf,ax=ax,label= cb_lab)
  ax.set_xlabel("Day Of year")
  ax.set_ylabel("Depth(m)")
  ax.set_title(title)
  

def doyfillplot_log(ax, dat, cmap, cb_lab, title, n_levels=20, vmin=None, vmax=None):
    dat = dat.copy()
    dat['date'] = pd.date_range(start=start_date, periods=len(dat), freq="D")
    dat = dat.set_index('date')
    dat = dat.groupby(dat.index.dayofyear).mean(numeric_only=True)

    levs = np.arange(0, dat.shape[1], 1)
    x = dat.index
    y = -1 * levs * dz
    z = dat[levs].values.T

    z_masked = np.where(z <= 0, np.nan, z)  # zeros -> blank, can't log(0)

    if vmin is None:
        vmin = np.nanmin(z_masked)
    if vmax is None:
        vmax = np.nanmax(z_masked)

    log_levels = np.logspace(np.log10(vmin), np.log10(vmax), n_levels)

    contourf = ax.contourf(
        x, y, z_masked,
        levels=log_levels,
        cmap=cmap,
        norm=LogNorm(vmin=vmin, vmax=vmax),
        extend='both'
    )
    cbar = ax.figure.colorbar(contourf, ax=ax, label=cb_lab, format=LogFormatterMathtext())
    ax.set_xlabel("Day of Year")
    ax.set_ylabel("Depth (m)")
    ax.set_title(title)
    #plt.show()
    
ax0,ax1,ax2= three()
tzlevs = np.arange(15,30,.5)
doyfillplot(ax0,Tz_df,tzlevs,'plasma','Temperature (C$^o$)',"Temperature Profile")
doyfillplot_log(ax2, APP_df, 'GnBu_r', 'APP', "APP Profile")
doyfillplot_log(ax1, Iz_df, 'PuBu_r', 'Light', "Light Profile")


#Day of year temp contour with epilimnion depth. 
epi_depth=np.array(r.epilimnion_depth,dtype=float)
epi_depth[(epi_depth > 100) | (epi_depth < 0)] = np.nan
epi_df  = pd.DataFrame({'epi_depth':epi_depth},index=dates)
epi_df['doy'] = epi_df.index.dayofyear
epi_doy = epi_df.groupby('doy')['epi_depth'].mean()

tzlevs = np.arange(-10,10,.5)
fig,ax=plt.subplots(layout="constrained")
doyfillplot(ax,Tz_df.iloc[:, :10],tzlevs,'plasma','Temperature (C$^o$)',"Temperature Profile")
#ax.plot(epi_doy.index,-1*epi_doy.values,linewidth=.6,color="k")
plt.show()



#3d
from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm
from matplotlib.colors import Normalize

def doy_average(dat):
    dat = dat.copy()
    dat['date'] = pd.date_range(start=start_date, periods=len(dat), freq="D")
    dat = dat.set_index('date')
    dat = dat.groupby(dat.index.dayofyear).mean(numeric_only=True)
    return dat


def app_temp_3d(Tz_df, APP_df, cmap='plasma', app_log=True):
    Tz_doy = doy_average(Tz_df)
    APP_doy = doy_average(APP_df)

    depth_levs = np.arange(0, Tz_doy.shape[1], 1)
    days = Tz_doy.index.values

    X, Y = np.meshgrid(days, -1 * depth_levs)
    Temp = Tz_doy[depth_levs].values.T
    APP = APP_doy[depth_levs].values.T

    if app_log:
        Z = np.where(APP <= 0, 0, np.log10(APP))
    else:
        Z = APP

    norm = Normalize(vmin=np.nanmin(Temp), vmax=np.nanmax(Temp))
    colors = mpl.colormaps[cmap](norm(Temp))  # ← fixed

    fig = plt.figure(figsize=(12, 8))
    ax = fig.add_subplot(111, projection='3d')
    surf = ax.plot_surface(
        X, Y, Z,
        facecolors=colors,
        rstride=1, cstride=1,
        linewidth=0, antialiased=True, shade=False
    )

    ax.set_xlabel("Day of Year")
    ax.set_ylabel("Depth (m)")
    ax.set_zlabel("log10(APP)" if app_log else "APP")
    ax.set_title("APP Surface Colored by Temperature")

    m = cm.ScalarMappable(cmap=cmap, norm=norm)  # ScalarMappable still exists, just get_cmap is gone
    m.set_array(Temp)
    #fig.colorbar(m, ax=ax, shrink=0.6, label="Temperature (°C)")

    plt.show()



app_temp_3d(Tz_df,APP_df)

spin = r.spinupALL
fig,ax=plt.subplots(layout="constrained")
ax.scatter(spin['Ca'],spin["Alg"],s=1,color='k',alpha=.5)
ax.set_xlabel("DOC")
ax.set_ylabel("PP (Biomass)")
ax.grid()
plt.show()




