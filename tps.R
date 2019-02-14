library(fields)
library(raster)
library(dplyr)

truth = readRDS("true_surface.rds")
obs = readRDS("obs_rast.rds")
d = readRDS("obs_d.rds")

fit = fastTps(select(d,x,y), d$z, theta=1, lambda=0.1)

s = predictSurface(fit, nx = 200, ny=200)

par(mfrow=c(1,2))
plot(truth, main="Truth")
plot(raster(s), main="TPS")


d$z_pred = predict(fit)
plot(d$z, d$z_pred)

system.time({fit = fastTps(select(d,x,y), d$z, theta=1, lambda=0.1)})
