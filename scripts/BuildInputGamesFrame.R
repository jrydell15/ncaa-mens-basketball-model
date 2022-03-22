library(tidyverse)

#games = read_csv('./data/raw/MRegularSeasonDetailedResults.csv')

games = read_csv('./data/raw/MNCAATourneyDetailedResults.csv')

gamesdf = games %>%
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

dfInput = rbind(dfWin, dfLose) %>%
  select(Season, DayNum, game_id, TeamID, OppID, Loc) %>%
  arrange(Season, DayNum, game_id, TeamID) %>%
  group_by(game_id) %>%
  slice(1) %>%
  ungroup() %>%
  arrange(Season, DayNum, game_id) %>%
  left_join(gamesdf %>% select(game_id, WTeamID, WScore, LScore), by="game_id") %>%
  mutate(win = ifelse(WTeamID == TeamID, 1, 0),
         score = ifelse(WTeamID == TeamID, WScore, LScore),
         score_opp = ifelse(WTeamID == TeamID, LScore, WScore),
         totalScore = score + score_opp) %>%
  select(-c(game_id, WTeamID, WScore, LScore))
   

#save(dfInput, file='./data/raw/InputGames.Rdata')
save(dfInput, file='./data/raw/TourneyInputGames.Rdata')
