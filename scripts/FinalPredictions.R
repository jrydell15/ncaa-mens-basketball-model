library(tidyverse)
library(caret)

wlModel = readRDS('./models/RegularSeasonWL.rda')
scoreModel = readRDS('./models/RegularSeasonScoreRegression.rda')
oppScoreModel = readRDS('./models/RegularSeasonScoreRegressionOpponent.rda')
totalModel = readRDS('./models/RegularSeasonScoreRegressionTotalScore.rda')
spreadModel = readRDS('./models/SpreadModel.rda')

tourneySpread = readRDS('./models/TourneySpreadModel.rda')
tourneyTotalPoints = readRDS('./models/TourneyTotalPointsModel.rda')

load('./data/input/Tourney2022CenteredScaledDF.Rdata')

# WL Model
Xfull = CenteredScaledDF %>%
  select(-c(Season, gameid, TeamID, OppID, Loc))
wl = predict(wlModel, Xfull, type='prob')$"1"

# Spread Model
Xfull = CenteredScaledDF %>%
  select(-c(Season, gameid, TeamID, OppID, Loc))
spreads = predict(spreadModel, Xfull)

# Total Points Model
Xfull = CenteredScaledDF %>%
  select(-c(Season, gameid, TeamID, OppID, Loc))
Xfull$totalPred = predict(totalModel, Xfull)
totals = predict(tourneyTotalPoints, Xfull %>% select(totalPred))

# combine all
Xfull = CenteredScaledDF %>%
  select(-c(Season, gameid, TeamID, OppID, Loc))

finalOut = CenteredScaledDF %>%
            select(TeamID, OppID)
finalOut$Win = wl
finalOut$Loss = 1-finalOut$Win
finalOut$TeamPoints = predict(scoreModel, Xfull)
finalOut$OppPoints = predict(oppScoreModel, Xfull)
finalOut$Spread = spreads
finalOut$TotalPoints = totals

write.csv(finalOut, file='./finalOut.csv')

kaggle = finalOut %>% select(TeamID, OppID, Win) %>%
          mutate(Season = 2022,
                 ID = paste0(Season, "_", TeamID, "_", OppID)) %>%
          select(ID, Pred = Win)

write.csv(kaggle, file='./KaggleSubmission.csv')
