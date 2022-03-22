library(tidyverse)
library(glmnet)
library(elasticnet)
library(tictoc)
library(caret)
library(progressr)

gamesdf_original = read_csv('./data/raw/MRegularSeasonDetailedResults.csv')

gamesdf = gamesdf_original %>%
  mutate(WPossessions = WFGA - WOR + WTO + 0.475*WFTA,
         LPossessions = LFGA - LOR + LTO + 0.475*LFTA,
         Poss = ceiling((WPossessions + LPossessions) / 2),
         Lloc = ifelse(WLoc == "H", "A", 
                       ifelse(WLoc == "N", "N", "H")),
         game_id = paste0(Season, DayNum, WTeamID, LTeamID))

dfWin = gamesdf %>%
  select(Season, DayNum, game_id, OppID = LTeamID, starts_with("W"), Poss) %>%
  select(-WPossessions) %>%
  rename_with(~ gsub("W", "", .x))

colOrder = names(dfWin)

dfLose = gamesdf %>%
  select(Season, DayNum, game_id, OppID = WTeamID, starts_with("L"), Poss) %>%
  select(-LPossessions) %>%
  rename_with(~ gsub("L", "", .x)) %>%
  rename(Loc = loc) %>%
  select(all_of(colOrder))

dfCombo = rbind(dfWin, dfLose) %>%
  arrange(Season, DayNum, game_id)

statdf = dfCombo %>% 
  arrange(Season, DayNum, game_id) %>%
  left_join(dfCombo %>% select(game_id, OppID, Poss, FGA, OR, DR),
            by=c("game_id", "TeamID" = "OppID"),
            suffix=c("", "_opp")) %>% 
  mutate(oRating_game = Score / Poss * 100,
         toRating_game = TO / Poss * 100,
         threeRate_game = FGA3 / FGA * 100,
         foulRate_game = PF / Poss_opp * 100,
         blockRate_game = Blk / FGA_opp * 100,
         stealRate_game = Stl / Poss_opp * 100,
         ftRate_game = FTM / FGA * 100,
         assistRate_game = Ast / FGM * 100,
         ORRate_game = OR / (OR + DR_opp) * 100,
         DRRate_game = DR / (DR + OR_opp) * 100,
         TRRate_game = (OR + DR) / (OR + DR + OR_opp + DR_opp) * 100,
         eFGPct_game = (FGM + 0.5*FGM3) / FGA * 100) %>%
  select(Season, DayNum, TeamID, OppID, Loc, tempo_game = Poss,
         contains("_game"))

save(statdf, file='./data/raw/FullRawStats.Rdata')

rm(statdf)