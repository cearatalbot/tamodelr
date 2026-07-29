#Data from Seekell
#mg/l = g/M^3
data <- data.frame(
  DOC = c(3.12, 4.02, 2.81, 2.4, 7.07, 13.11, 1.8, 2.43, 9.4, 4.48, 6.11, 8.07, 8.53, 6.43, 4.42, 16.8, 15.1, 15.91, 9.5, 10.12, 11.11, 7.99, 3.81, 4.05, 17, 21),
  kd  = c(0.46, 0.51, 0.44, 0.44, 0.65, 1.62, 0.32, 0.41, 0.18, 1.1, 2.5, 1.3, 0.8, 0.7, 0.5, 3.77, 3.2, 2.97, 1.89, 1.14, 1.9, 1.08, 0.42, 0.56, 3.2, 4.2)
)
data_big <- data.frame(
  DOC=c(7.07,1.8,2.43),
  kd = c(0.65,.32,0.41)
)
dat <- data.frame(
  DOC=c(1,2,3,4,5,6),
  kd = c(1e-4,1e-5,1e-5,1e-6,1e-6,1e-6)
)

#lm does log-linear least squares regresison 
#log(kd) for dependent, DOC for independent
model <- lm(log(kd) ~ DOC, data = dat)

intercept_log_a <- coef(model)["(Intercept)"]
k <- coef(model)["DOC"]
# Calculate the correct initial condition
a <- exp(intercept_log_a) #e^intercept to undo the log

# Print values
cat("a =", a, "\n")
cat("k =", k, "\n")