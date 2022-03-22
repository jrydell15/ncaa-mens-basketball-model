library(tidyverse)
library(glmnet)
library(elasticnet)
library(tictoc)
library(caret)
library(progressr)

load('./data/raw/FullRawStats.Rdata')

cols = statdf %>% select(contains("_game")) %>% names

handlers(global=TRUE)

GetBetas = function(years, cols, statdf) {
  tic("Overall Training Time")
  betaDF = tibble()
  
  for (s in years) {
    p = progressor(along=cols)
    p(sprintf("Season: %s", s), class = 'sticky')
    tic(paste("Season:", s))
    lastSeason = statdf %>% filter(Season == s) %>% mutate(across(TeamID:Loc, as.factor))
    X = lastSeason %>% select(TeamID:Loc)
    
    X$Loc = relevel(X$Loc, ref="N")
    
    dummyModel = dummyVars(~., data=X, sparse=TRUE)
    XDummy = predict(dummyModel, X)
    XDummy = Matrix(XDummy[, -(ncol(XDummy)-2)], sparse=TRUE)
    
    set.seed(1)
    K = 10
    trControl = trainControl(method='cv', number=K, returnResamp = "all")
    x = 1
    
    for (c in cols) {
      Y = lastSeason %>% select(all_of(c)) %>% unlist()
      ridgeOut = train(x = XDummy, y = Y, method='glmnet',
                       tuneGrid = expand.grid(alpha=0,
                                              lambda=10^(seq(log10(0.0001), log10(500), length=100))),
                       trControl=trControl)
      
      optLambda = ridgeOut$bestTune$lambda
      set.seed(1)
      glmnetOut = glmnet(x = XDummy, y = Y, alpha=0, lambda = optLambda)
      betas = tibble('team' = row.names(coef(glmnetOut)),
                     'betas' = coef(glmnetOut)[1:length(coef(glmnetOut))])
      betaDF = rbind(betaDF, betas %>%
                       mutate(Season = s, stattype = c) %>%
                       select(Season, stat=team, stattype, betas))
      x = x + 1
      p(sprintf("x=%g", x))
    }
    toc()
  }
  toc()
  return(betaDF)
}

seasons = statdf %>% distinct(Season) %>% pull()

betaDF = GetBetas(seasons, cols, statdf)

save(betaDF, file='./data/adjusted/AllAdjustedBetas.Rdata')

rm(list=ls())
