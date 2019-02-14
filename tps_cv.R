library(fields)
library(raster)
library(dplyr)
library(purrr)
library(furrr)

RhpcBLASctl::blas_set_num_threads(1)

plan(multicore, workers = 10)

truth = readRDS("true_surface.rds")
obs = readRDS("obs_rast.rds")
d = readRDS("obs_d.rds")

kfold = 10

d_cv = modelr::crossv_kfold(d, kfold)


res = pmap_dfr(
  d_cv,
  function(train, test, .id) {
    lambdas = c(0, 10^seq(-4,-1, length.out = 100))
    train = as_tibble(train)
    test  = as_tibble(test)
    
    future_map_dfr(
      lambdas,
      function(lambda) {
        fit = fastTps(select(train ,x,y), train$z, theta=1, lambda=lambda)
        p = predict(fit, xnew = select(test, x, y))
        rmse = sqrt( mean( (p - test$z)^2 ) )
        
        tibble(fold = .id, lambda = lambda, rmse = rmse)
      },
      .progress = TRUE
    )
  }
)

res

res %>% 
  group_by(fold) %>%
  arrange(rmse) %>%
  slice(1:3)
