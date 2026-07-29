#add time for each PFT. ave applies seq_along to each pft group
library(ggplot2)
library(tidyr)
library(dplyr)
#spinupALL_kd$time <- unlist(tapply(seq_len(nrow(spinupALL_kd)), spinupALL_kd$pft, seq_along))#deconstruct df along time


plot_spinup <- function(data) {
  ggplot(data, aes(x = time, y = Ca, color = pft)) +
    geom_line() +
    labs(x = "time", y = "Ca", color = "PFT")
}
plot_spinup(spinupALL_kd)

plot_data <- spinupALL_kd %>%
  filter(pft=="EGNE")

egne_long <- spinupALL_kd %>%
  pivot_longer(
  cols = c(Ca, Ci, Alg),
  names_to = "Pool",
  values_to = "Value"
  )
ggplot(egne_long,aes(x=time,y=Value,color=Pool))+
  geom_line()+
  labs(title="Aquatic Carbon Pools ", y="Carbon(gC)",x="time(days)",color="Pool")+
  scale_color_manual(values = c("Ca"="blue", Ci="grey", "Alg"="olivedrab3"))

  


#ggplot(plot_data, aes(x=time))+
 #        geom_line(aes(y=Ci), color = "lightblue4")+
 #        geom_line(aes(y=Ca), color = "blue")+
 #        geom_line(aes(y=Alg),color= 'olivedrab3')+
 #        labs(x = "time", y = "Carbon")

#ggplot(spinupALL_kd,aes(x=time,y=Ca/Ci))+geom_line()
ggplot(spinupALL_kd,aes(x=time,y=Alg))+geom_line(aes(color="spinupALL_kd"))+
  geom_line(data=spinupALL_kd,aes(x=time,y=Alg,color="spinupALL_kd_kd"))+
  labs(color="Legend")


