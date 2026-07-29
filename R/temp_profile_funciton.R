#Function verison of tempprofile creating a temperature gradient everyday of model runtime
#

tprofile<-function(t,Tz,zbar,PAR,Tair,EVAP,LW_IN,SW_IN,Ca){

  #levels of lake by increment dz
  dz<- 1
  z_levs <- seq(0,zbar,dz)
  num_levels<-length(z_levs)

  if(is.null(Tz)){
    Tz <- rep(Tair_approx(1),num_levels)#initial temp profile (all air temps)
  }

  cw<-4184#[J/kg*C] heat capacity
  rho <-1000#[kg/M^3] density
  dt_sec <- 86400 #seconds in a day
  #Kz_vec formulated from neg exp fit(10e-4,10e-5,10e-5,10e-6,10e-6,10e-6)
  Kz_vec <- 0.000117*exp(-.921*z_levs)#set up a diffusion rate gradient
  sb <- 5.67e-8 #stephen boltz for lw out
  ewtr <- 0.97 #emmesivity of water about
  total_days <- nrow(site_forcings)

  #---------------------------------------------------------------------------
  PARJ<- PAR#*219000#convert to J
  SW_IN<- SW_IN*dt_sec * (1-0.06)#convert to J, +albedo
  SW_non_PAR <- max(SW_IN-PARJ,0)
  Evap = max(EVAP, 0)

  #first get the PAR attenution as you have in TAMstep
  DOC_Conc = Ca/(zbar*Aa) #[gC/m^-3] #Ca/(Aa*zbar) on a Dtemp limited run gave 10.40957 g/M^3
  kd= 0.321*exp(.13*DOC_Conc)#Kd according to DOC. (Seekell=.13,0.321)<small lake relation
  Iz = PARJ*exp(-kd*z_levs)#light at each level

  #subsurface layers PAR absorbtions
  energy_absorbed = numeric(num_levels)
  for(z in 1:(num_levels-1)){   #for every level save top
    energy_absorbed[z]<-Iz[z]-Iz[z+1]
  }

  #now do non-PAR radiation attenutaiotn
  kd_sw <- 2.0  #steep
  Iz_sw <- SW_non_PAR * exp(-kd_sw * z_levs)
  sw_absorbed <- numeric(num_levels)
  for(z in 1:(num_levels-1)){
    sw_absorbed[z] <- Iz_sw[z] - Iz_sw[z+1]
  }
  Tz_new <- Tz

  #surface
  alpha<-.15
  latent_heat_evap <- 2.45e7#[J / cm / m^2]
  evap_loss <- Evap*latent_heat_evap
  lw_out <- (sb*ewtr*(Tz[1]+273.15)^4)
  lw_net <- (LW_IN-lw_out)*dt_sec
  Tz_new[1]<- Tz[1]+
    energy_absorbed[1]/(cw*rho*dz)+ #vis light energy
    sw_absorbed[1]/(cw*rho*dz)+#non vis light energy
    lw_net/(cw*rho*dz)-# net longwave
    evap_loss/(cw*rho*dz)+#evaporative loss in energy
    alpha*(Tair-Tz[1])#air-sea term

  #subsurface
  for(z in 2:(num_levels-1)){
    dt_solar <- energy_absorbed[z]/(cw*rho*dz)
    dt_sw <-  sw_absorbed[z]/(cw*rho*dz)

    Tz_new[z] <- Tz[z]+dt_solar +dt_sw
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
  #therm_hist[t,] <-Tz #now if this was a function and you called it instead of adding to a list
  return(Tz)
}

#reticulate::py_run_file('/Users/nicodavis/Desktop/R/TERC/tamodelr/Examples/R/temp_plotter.py')
#sample_tprofile <- therm_hist[nrow(therm_hist),]
