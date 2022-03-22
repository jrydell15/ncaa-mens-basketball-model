library(tidyverse)
library(caret)

load('./data/adjusted/NIT2022AllAdjustedStatsDF.Rdata')

seasons = AllAdjustedStatsDF %>% distinct(Season) %>% unlist

CenteredScaledDF = tibble()

for (s in seasons) {
  load(paste0('./data/preProcessingSteps/preProc_', s, '.Rdata'))
  holding = AllAdjustedStatsDF %>%
              filter(Season == s) %>%
              predict(preProc, .)
  
  CenteredScaledDF = rbind(CenteredScaledDF, holding)
  
  rm(preProc)
}

save(CenteredScaledDF, file='./data/input/NIT2022CenteredScaledDF.Rdata')
