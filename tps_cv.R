library(fields)
library(raster)
library(dplyr)
library(purrr)
library(furrr)

truth = readRDS("true_surface.rds")
obs = readRDS("obs_rast.rds")
d = readRDS("obs_d.rds")

kfold = 2

d_cv = modelr::crossv_kfold(d, kfold)


res = pmap_dfr(
  list(seq_len(kfold), d_cv$train, d_cv$test),
  function(fold, train, test) {
    lambdas = c(0, 10^seq(-4,-1, length.out = 10))
    train = as_tibble(train)
    test  = as_tibble(test)
    
    map_dfr(
      lambdas,
      function(lambda) {
        fit = fastTps(select(train ,x,y), train$z, theta=1, lambda=lambda)
        p = predict(fit, xnew = select(test, x, y))
        rmse = sqrt( mean( (p - test$z)^2 ) )
        
        tibble(fold = fold, lambda = lambda, rmse = rmse)
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
