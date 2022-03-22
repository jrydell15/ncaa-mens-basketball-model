library(tidyverse)
library(caret)

load('./data/adjusted/AllAdjustedBetas.Rdata')
load('./data/raw/FullRawStats.Rdata')
#load('./data/raw/InputGames.Rdata')
#load('./data/raw/TourneyInputGames.Rdata')

#tourney2022 = read_csv('./data/raw/MSampleSubmissionStage2.csv')
tourney2022 = read_csv('./data/raw/NITMatchups.csv')
#tourney2022 = tourney2022 %>%
#                separate(ID, "_", into=c("Season", "TeamID", "OppID")) %>%
#                select(-Pred)

#tourney2022 = tourney2022 %>%
#                mutate(DayNum = 140, Loc = "N")

GetStatTable = function(inputGames, BetaDF=betaDF, Statdf=statdf) {
  # inputGames is a df of Season, DayNum, TeamID, OppID, Loc
  
  seasons = unique(inputGames$Season)
  earliestSeason = min(BetaDF$Season)
  holdingStats = tibble()
  
  for (s in seasons) {
    betaMatrix = BetaDF %>% 
      pivot_wider(id_cols = c(Season, stattype),
                  names_from = stat,
                  values_from = betas) %>%
      filter(Season == s) %>%
      select(stattype, "(Intercept)",
             contains("ID"), contains("Loc")) 
    
    statNames = betaMatrix$stattype
    
    betaMatrix = betaMatrix[,-1]
    betaMatrix[is.na(betaMatrix)] = 0
    
    holding = inputGames %>%
      filter(Season == s) %>%
      select(Season, DayNum, TeamID:Loc) %>%
      mutate(gameid = paste0(Season, DayNum, TeamID, OppID)) %>%
      select(-DayNum)
    
    rawX = holding %>%
      rbind(holding %>%
              select(Season, TeamID.n = OppID, OppID = TeamID, Loc, gameid) %>%
              rename(TeamID = TeamID.n) %>%
              mutate(Loc = as.factor(case_when(Loc == "H" ~ "A",
                                               Loc == "A" ~ "H",
                                               TRUE ~ "N")))) %>%
      arrange(Season, gameid)
    
    gameids = rawX$gameid
    rawX = rawX %>% select(TeamID:Loc) %>% mutate_all(as.factor)
    teams = rawX$TeamID
    
    Xfull = Statdf %>%
      filter(Season >= earliestSeason) %>%
      mutate(across(TeamID:Loc, as.factor)) %>%
      select(TeamID:Loc)
    
    Xfull$Loc = relevel(Xfull$Loc, ref="N")
    
    fullDummyModel = dummyVars(~., data=Xfull, sparse=TRUE)
    XDummy = predict(fullDummyModel, rawX)
    XDummy = XDummy[, -(ncol(XDummy)-2)]
    
    # was having issues with betaMatrix columns not aligning with dummy matrix
    betaMatrix = betaMatrix %>%
      select("(Intercept)", all_of(names(as_tibble(XDummy))))
    
    XDummy = cbind(rep(1, nrow(XDummy)), XDummy)
    
    statOut = XDummy %*% t(as.matrix(betaMatrix))
    statOut = as_tibble(statOut)
    names(statOut) = statNames
    
    statOut$TeamID = teams
    statOut$gameid = gameids
    rawX$gameid = gameids
    
    fullStatOut = rawX %>%
      left_join(statOut, by=c("gameid", "TeamID")) %>%
      mutate(Season = s)
    
    holdingStats = rbind(holdingStats, fullStatOut)
  }
  
  combinedOut = holdingStats %>%
    left_join(holdingStats %>% select(-c(Loc, TeamID, Season)),
              by=c('gameid', "TeamID" = "OppID"),
              suffix=c("", "_opp")) %>%
    filter(as.numeric(TeamID) < as.numeric(OppID))
  
  temp = combinedOut %>%
    select(-c(Season, gameid, TeamID, OppID, Loc)) %>%
    names
  
  return(combinedOut %>%
           select(Season, gameid, TeamID, OppID, Loc, all_of(temp)))
}


#gamesForInput = dfInput %>%
#  select(Season:Loc) 

#AllAdjustedStatsDF = GetStatTable(gamesForInput) %>%
#                      left_join(dfInput %>%
#                                  mutate(gameid = paste0(Season, DayNum, TeamID, OppID)) %>%
#                                  select(gameid, win, score, score_opp, totalScore), by="gameid")

AllAdjustedStatsDF = GetStatTable(tourney2022)

#save(AllAdjustedStatsDF, file='./data/adjusted/Tourney2022AllAdjustedStatsDF.Rdata')
save(AllAdjustedStatsDF, file='./data/adjusted/NIT2022AllAdjustedStatsDF.Rdata')
