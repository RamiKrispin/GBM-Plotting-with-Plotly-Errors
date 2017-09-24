library(h2o)
data(iris)
h2o.init(nthreads=-1)
df.h <- as.h2o(iris)

y <- "Species"
x <- setdiff(names(df.h), c(y, "name"))
splits <- h2o.splitFrame(
  data = df.h, 
  ratios = c(0.6,0.2),   
  destination_frames = c("train.hex", "valid.hex", "test.hex"), seed = 1234
)
train <- splits[[1]]
valid <- splits[[2]]
test  <- splits[[3]]


gbm <- h2o.gbm(
  
  x = x, 
  y = y, 
  training_frame = train, 
  validation_frame = valid,
  ntrees = 10000,                                                            
  learn_rate=0.01,                                                         
  stopping_rounds = 5, stopping_tolerance = 1e-4, 
  sample_rate = 0.8,                                                       
  col_sample_rate = 0.8,                                                   
  seed = 1234,                                                             
  score_tree_interval = 10                                                 
)
sh <- h2o.scoreHistory(gbm)
p1 <- plot_ly(data = sh, x = ~number_of_trees, y =  ~ training_rmse, 
              type = "scatter", mode = "lines+markers", name = "RMSE - Training") %>%
  add_trace(x = ~number_of_trees, y =  ~ validation_rmse, 
            type = "scatter", mode = "lines+markers", name = "RMSE - Validation")

p2 <- plot_ly(data = sh, x = ~number_of_trees, y =  ~ training_classification_error, 
              type = "scatter", mode = "lines+markers", name = "Classification Error - Training") %>%
  add_trace(x = ~number_of_trees, y =  ~ validation_classification_error, 
            type = "scatter", mode = "lines+markers", name = "Classification Error - Validation")
