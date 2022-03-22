library(tidyverse)
library(caret)

load('./data/adjusted/AllAdjustedStatsDF.Rdata')

seasons = AllAdjustedStatsDF %>% distinct(Season) %>% unlist()

for (s in seasons) {
  preProc = AllAdjustedStatsDF %>% 
    filter(Season == s) %>%
    select(contains("_game")) %>%
    preProcess(method=c("center", "scale"))
  
  save(preProc, file=paste0("./data/preProcessingSteps/preProc_", s, ".Rdata"))
}
