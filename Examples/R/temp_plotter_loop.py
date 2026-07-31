#py_require("matplotlib") 
#py_require("numpy") 
#py_require("pandas") 
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

therm_hist = r.therm_hist
mega_hist = r.mega_hist

levs = np.arange(0,len(therm_hist[1]),1)
t_steps = np.arange(0,len(therm_hist),100)

cols = ["red","orange","green","blue","purple","pink","k"]
fig,ax = plt.subplots(figsize=(20,10))
for i,m in enumerate(mega_hist):
  for t in t_steps:
    ax.plot(m[t],-levs,color=cols[i])
ax.grid()
ax.set_xlabel('time')
#ax.legend()
plt.show()
