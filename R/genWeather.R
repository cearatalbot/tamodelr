
###Filling in missing climate drivers with estimates

genWeather<-function(tavg, doys, netrad, relH, elev, soilk=5){
  library(zoo)

  ###soil temperature (surface)###
  #generate daily soil T w/trailing moving average
  #default=5 days

  tsoil<-rollmean(tavg, k=soilk, fill=NA, align="right")
  for(i in 1:(soilk-1)){
    if(i==1){
      tsoil[i]<-tavg[i]
    } else{
      tsoil[i]<-mean(c(tavg[1:i],tavg[soilk]))
    }
  }

  #####VPD####
  #helpful: https://cran.r-project.org/web/packages/humidity/vignettes/humidity-measures.html
  #hPa to kPa=0.1; Pa to kPa = 0.001
  svp<-(6.11*exp((2.5*10^6/461.52)*((1/273.15)-(1/(tavg+273.15)))))*0.1  #kPa; CHECKED
  vp<-relH/100*svp*0.001 #kPa

  vpd<-svp-vp #kPa
  #loop evap calculation over each DOY
  aqEvap<-c() #evap in cm day^-1
  net_sw<-c()
  net_lw<-c()
  for(b in 1:length(tavg)){
    n<-evap_calc(tair=(tavg[b]), vpd=(vpd[b]*1000), vp=(vp[b]*1000), netrad=netrad[b], elev=elev) #convert hPa to Pa for vpd; *100
    aqEvap[b]<-n[,1]
    net_sw[b]<-n[,2]
    net_lw[b]<-n[,3]
  }
  return(data.frame(cbind(tsoil, aqEvap, netrad, vpd, net_lw, net_sw)))
}

