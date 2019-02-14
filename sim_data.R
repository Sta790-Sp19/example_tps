library(raster)
library(dplyr)
library(parallelDist)

RhpcBLASctl::blas_set_num_threads(8)

set.seed(101)

sq_exp_cov = function(d, sigma2, l, tau2) {
  d = as.matrix(d)
  sigma2*exp(-(d*l)^2) + diag(tau2, nrow(d), ncol(d))
}

r = raster(nrow=200, ncol=200, xmn=0, xmx=1, ymn=0, ymx=1)

d = parDist(xyFromCell(r, seq_along(r)))

S = sq_exp_cov(d, 3, sqrt(3)/0.25, 1e-6)


r[] = t(chol(S)) %*% rnorm(nrow(S))
plot(r)

saveRDS(r, "true_surface.rds")


set.seed(102)
n = 3000

d = tibble(
  x = runif(n),
  y = runif(n)
) %>%
  mutate(z = raster::extract(r,cbind(x,y)))

obs = r
obs[] = NA

obs[ cellFromXY(obs, select(d, x, y) %>% as.matrix()) ] = d$z
plot(obs)

saveRDS(obs, "obs_rast.rds")
saveRDS(d, "obs_d.rds")


