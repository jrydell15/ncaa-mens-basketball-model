# NBA Win-Loss Model

## Project Intro

The purpose of this project was to build a model to predict the pre-game probability that a team in the 2022 NCAA Men's Basketball Tournament would beat another team in the field and a regression model for predicting the final point spread.

### Methods/Techniques Used

- Data Gathering/Cleaning
    - Making opponent adjusted stats using Ridge Regression
    - Centering and scaling in a manner to avoid potential data leakage
- Models Tested
    - Logistic Regression

### R Libraries Used

- tidyverse family of libraries for data manipulation and cleaning
- caret for model building
- ggplot2 for plotting

## Project Description

**Goal:** Build a model which produces a well-calibrated pre-game probability for the chance that one NCAA Men's Basketball team has to beat another team in their next tournament game. Also produce a regression model to predict the final point spread of the game.
- Data Source: Kaggle
- Data Cleaning:
    - Took game-by-game data and transformed it using Ridge Regression to pull out the actual skill of teams, after adjusting for the disparity between team skill.
- Feature Engineering:
    - Built pace-adjusted stats such as Offensive/Defensive Rating, Turnover Percentage, and Assist Percentage.
- Model Building:
    - Data from the 2003-2004 season until the 2020-2021 season were split into a 50%/25%/25% training/testing/validation split for model building
    - Tested a few different models which had the potential to be the best performing model
    - Model hyperparameters were chosen with 10-fold Cross Validation
- Model Evaluation:
    - Since the goal was to build a model which is well-calibrated, the model was evaluated with a Calibration Plot
    - Since this was a quick project, a Logistic Regression model was output as a Minimum Viable Product
- Final Model Results:
    - The final performance on the 2022 Men's Tournament resulted in a leaderboard placement of 384/930 on Kaggle. Although this is not great, I was impressed by how well the model performed without much fine-tuning or without using more advanced model types.
- Future Improvements:
    - Adjust for injuries and players who are sitting out
    - Adjust for how well/poor the team has been playing recently
    - Try XGBoost and Neural Networks

**Lessons Learned:** With data like this, it is very easy to accidentally introduce data leakage. Being cognizant of this issue while producing the model input dataframes paid dividends while model building, it allowed our models to be optimized based on the data at any given point in time and not accidentally on future information.

**Why is this useful?**

Learning how to build well-calibrated models is very useful for a wide range of problems and can easily be applied to business decisions. They have the added benefit of being easily understood and can be applied by decision makers as an unbiased data point.

## Contributors

- Justin Rydell
    - Email: jrydell15@gmail.com
    - GitHub: jrydell15


