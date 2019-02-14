library(fields)
library(raster)
library(dplyr)
library(purrr)
library(furrr)

plan(multicore, workers = 8)

truth = readRDS("true_surface.rds")
obs = readRDS("obs_rast.rds")
d = readRDS("obs_d.rds")

kfold = 10

set.seed(101)
d_cv = modelr::crossv_kfold(d, kfold)

fold = commandArgs(trailingOnly = TRUE) %>% as.integer()

lambdas = c(0, 10^seq(-4,-1, length.out = 100))
train = as_tibble(d_cv$train[[fold]])
test  = as_tibble(d_cv$test[[fold]])

res = future_map_dfr(
  lambdas,
  function(lambda) {
    fit = fastTps(select(train ,x,y), train$z, theta=1, lambda=lambda)
    p = predict(fit, xnew = select(test, x, y))
    rmse = sqrt( mean( (p - test$z)^2 ) )
    
    tibble(fold = fold, lambda = lambda, rmse = rmse)
  },
  .progress = TRUE
)

saveRDS(res, paste0("fold_",fold,".rds"))
