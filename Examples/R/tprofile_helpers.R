backwards_solve <- function(a, b, c, d) {
  n <- length(d)
  cp <- numeric(n); dp <- numeric(n)
  cp[1] <- c[1]/b[1]; dp[1] <- d[1]/b[1]
  for(i in 2:n){
    m <- b[i] - a[i]*cp[i-1]
    cp[i] <- c[i]/m
    dp[i] <- (d[i] - a[i]*dp[i-1])/m
  }
  x <- numeric(n)
  x[n] <- dp[n]
  for(i in (n-1):1) x[i] <- dp[i] - cp[i]*x[i+1]
  x
}

implicit_diffuse <- function(Tz, Kz_vec, dz, dt){
  n <- length(Tz)
  # Use interface-averaged Kz so flux is symmetric between adjacent layers.
  # Without this, discontinuous Kz values could create extra heat.
  Kz_up  <- c((Kz_vec[-n] + Kz_vec[-1]) / 2, 0)  #avg between each adjacent cell + a 0 to cap top
  Kz_dn  <- c(0, (Kz_vec[-n] + Kz_vec[-1]) / 2)  # cap 0 bottom + avg between each adjacent cell
  r_up   <- Kz_up * dt / dz^2
  r_dn   <- Kz_dn * dt / dz^2
  a <- -r_dn; b <- 1 + r_up + r_dn; c <- -r_up# a is sub diag, b is diag, c is super diag: tridiagonal
  # with only one neighbor at top and bottom no heat can escape from either top or bottom
  b[1] <- 1 + r_up[1]; a[1] <- 0
  b[n] <- 1 + r_dn[n]; c[n] <- 0
  backwards_solve(a, b, c, Tz)
}

winter = seq(0,80,1)
spring = seq(81,171,1)
summer = seq(172,263,1)
fall = seq(264,365,1)

t_to_season <- function(t){
  doy <- t%%365
  if(doy %in% winter){
    return("winter")
  }else if(doy %in% spring){
    return("spring")
  }else if(doy %in% summer){
    return("summer")
  }else{
    return("fall")
  }
}






