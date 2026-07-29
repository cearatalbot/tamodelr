#create a temperature profile based on the daily Temp, PAR, and Evaporation 
#eventually we can create Dtemp_bar and a Val between 0-1 to limit PP
setwd("/Users/nicodavis/Desktop/R/TERC/tamodelr")
source("/Users/nicodavis/Desktop/R/TERC/tamodelr/Examples/R/tprofile_helpers.R")
site_forcings <- read.csv("Examples/Data/OSBS_neonForcings_ex.csv")
# needs to start on a January 1st
site_forcings$mon_day<-paste(substr(site_forcings$TIMESTAMP, 5,6), substr(site_forcings$TIMESTAMP, 7,8), sep="-")
if(site_forcings$mon_day[1] != "01-01"){
  site_forcings<-site_forcings[which(site_forcings$mon_day== "01-01")[1]:nrow(site_forcings), ]#ensuring we span from J1 to the end. J1 must be first
}
site_forcings$runDay <- 1:nrow(site_forcings)
total_days <- nrow(site_forcings)

#define forcing approx functions #interpolate smoothly through time for ode
PARapprox<<-approxfun(x=as.numeric(site_forcings$runDay), y = as.numeric(site_forcings$PAR_e))
Tair_approx<<-approxfun(x=as.numeric(site_forcings$runDay), y = as.numeric(site_forcings$TA_F))
SW_IN_approx <- approxfun(x = as.numeric(site_forcings$runDay), y = as.numeric(site_forcings$SW_IN_F))
Evap_approx<<-approxfun(x=as.numeric(site_forcings$runDay), y= as.numeric(site_forcings$aqEvap))
LW_IN_approx <- approxfun(x = as.numeric(site_forcings$runDay), y = as.numeric(site_forcings$LW_IN_F))
#---------------------------------------------------------------------------
zbar <- 50  #(m)
dz<-0.5
z_levs <- seq(0,zbar,dz)
num_levels<-length(z_levs)

cw<-4184#[J/kg*C] heat capacity
rho <-1000#[kg/M^3] density
dt_sec <- 86400 #seconds in a day
Kz_vec <- rep(0.00001, num_levels) #base diffusion rate all levels
Kz_vec[1:3]<-0.0005;
sb <- 5.67e-8 #stephen boltz 
ewtr <- 0.97 #emmesivity of water
eair <- 0.75 #emmesivity of air (roughly- consider clouds)
total_days <- nrow(site_forcings)

#---------------------------------------------------------------------------
depths = seq(0,50,10)
mega_hist <- vector("list",length(alphas))
for(i in seq_along(depths)){
  Tz <- rep(Tair_approx(1),num_levels)#initial temp profile (all air temps)
  #Tz <- therm_hist[nrow(therm_hist),]
  therm_hist <- matrix(0,nrow=total_days,ncol=num_levels)
  for(t in 1:total_days){
    PAR<- PARapprox(t)
    PARJ<- PARapprox(t)*219000#convert to J
    Tair<- Tair_approx(t)
    LW_IN <- LW_IN_approx(t)
    SW_IN<- SW_IN_approx(t)*dt_sec * (1-0.06)#convert to J, +albedo
    SW_non_PAR <- max(SW_IN-PARJ,0)
    Evap=Evap_approx(t)
    
    #first get the light attenution as you have in TAMstep
    
    DOC_conc = 5 #instead of Ca/(Aa*zbar) #[gC/m^-3]
    kd= 0.321*exp(.13*DOC_conc)#Kd according to DOC. (Seekell=.13,0.321)<small lake relation
    Iz = PARJ*exp(-kd*z_levs)#light at each level
    
    #subsurface layers
    energy_absorbed = numeric(num_levels)
    for(z in 1:(num_levels-1)){   #for every level save top
      energy_absorbed[z]<-Iz[z]-Iz[z+1]
    }
    
    #diffusion_flux <-numeric(num_levels)
    #for(z in 2:(num_levels-1)){
    # diffusion_flux[z] <- Kz*(Tz[z-1]-2*Tz[z]+Tz[z+1])/(dz^2)#heats eq 2nd deriv
    # }
    
    Tz_new <- Tz
    #alpha<-alphas[i]
    latent_heat_evap <- 2.45e7#[J / cm / m^2]
    evap_loss <- Evap*latent_heat_evap*dt_sec
    lw_out <- sb*ewtr*(Tz[1]+273.15)^4
    lw_net <- (lw_out)*dt_sec
    Tz_new[1]<- Tz[1]
    #+0.15*(Tair-Tz[1])#old air-sea term
    +energy_absorbed[1]/(cw*rho*dz)#vis light energy
    +SW_non_PAR/(cw*rho*dz)#non vis light energy
    +lw_net/(cw*rho*dz)# net longwave
    -evap_loss/(cw*rho*dz)#evaporative loss in energy
    
    
    for(z in 2:(num_levels-1)){
      dt_solar <- energy_absorbed[z]/(cw*rho*dz)
      #dt_diffusion <- diffusion_flux[z] *dt_sec
      Tz_new[z] <- Tz[z]+dt_solar#+dt_diffusion
    }
    Tz_new[num_levels] <-Tz_new[num_levels-1]
    Tz_new <- implicit_diffuse(Tz_new,Kz_vec,dz,dt_sec)
    Tz<-Tz_new
    
    #convective mixing keep sorting until no wamer water is below cold water
    tol =1e-4
    repeat{
      inversion_found <- FALSE
      for(z in 1:(num_levels-1)){
        if((Tz[z+1] - Tz[z])>tol){
          avg <- (Tz[z]+Tz[z+1])/2
          Tz[z+1] <- avg
          Tz[z] <- avg
          inversion_found <- TRUE
        }
      }
      if(inversion_found==FALSE)break
    }
    therm_hist[t,] <-Tz
  }
  mega_hist[[i]] <- therm_hist
}
reticulate::py_run_file('/Users/nicodavis/Desktop/R/TERC/tamodelr/Examples/R/temp_plotter.py')

