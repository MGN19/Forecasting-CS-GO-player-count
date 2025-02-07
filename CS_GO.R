#library
library(tidyverse)
library(fpp3)
library(readr)

# for the unit root test
library(urca)

setwd("/Users/mariananeto/Desktop/NOVA IMS/2º - 2ND SEMESTER/Forecasting Methods/FM Project")
csgo <- read_csv("CSGO Lifetime Chart.csv")

csgo <- csgo %>% 
  mutate(Players = timeSeries::interpNA(ts(Players), type = "mean"))

View(csgo)


##################################################
#            Creating the data sets              #
##################################################

# creating a monthly tsibble of the csgo dataset
m_csgo <- csgo|>
  # Creating a new column named "new_date" that contains the values 
  # of the "DateTime" column in a date format.
  mutate(new_date = as.Date(DateTime, format = '%d/%m/%Y'))|>
  # Making a new column called "M" that shows the month for each data 
  # point in the time series.
  mutate(M=yearmonth(new_date))|>
  # Grouping the data points by their corresponding month
  group_by(M)|>
  # Summing the amount of players for each month
  summarise(players_total = sum(Players)) |>
  # Converting the data to a tsibble format, with months (M) as the index.
  as_tsibble(index = M)

m_csgo %>% autoplot()

View(m_csgo)



# Creating the training set for quarterly and monthly data
m_csgo_training <- m_csgo |> filter(year(M) < 2022)
# Creating the training set for quarterly and monthly data
m_csgo_test <- m_csgo |> filter(year(M) >= 2022)

m_csgo_training %>% autoplot()



##################################################
#            Testing the variance                #
##################################################


# Plotting the monthly tsibble for the training csgo data
m_csgo_training |> autoplot(players_total)
# Getting the lambda gerrero value
m_csgo_training |> features(players_total, guerrero)

# Plotting using the lambda guerrero value in the boxcox
m_csgo_training |> autoplot(box_cox(players_total,0.481))
# Plotting the data using log
m_csgo_training |> autoplot(log(players_total))


# We choose the original data, after visualizing the plots



##################################################
#            Unit root testing                   #
##################################################


# Plotting ACF and PACF for the monthly training csgo tsibble
m_csgo_training |> gg_tsdisplay(plot_type='partial', lag = 24)


# UNIT ROOT test - Augmented Dickey Fuller test


# perform the dickey fuller test
summary(ur.df(na.omit(m_csgo_training$players_total), 
              type=c("drift"), lags=22))


# We do not reject the null hypothesis for the monthly dataset
# Hence, we will difference the series


# storing the seasonal differences

m_csgo_training <- m_csgo_training |>
  mutate(d_players_total = difference(players_total, 12))



# check the ACF and PACF for the difference data
m_csgo_training |>
  gg_tsdisplay(d_players_total,
               plot_type='partial', lag=36) +
  labs(title="Seasonal Difference", y="")



####################################
# first test for seasonal differences 
####################################

# We need to test once more for the presence of unit root.

# Testing for the second difference for monthly data
summary(ur.df(na.omit(m_csgo_training$d_players_total), type=c('drift'),
              lags=4))


# taking the first non_seasonal difference

m_csgo_training <- m_csgo_training |>
  mutate(d2_players_total = difference(d_players_total, 1))

m_csgo_training |>
  gg_tsdisplay(d2_players_total,
               plot_type='partial', lag=36) +
  labs(title="Difference", y="")


summary(ur.df(na.omit(m_csgo_training$d2_players_total), type=c('drift'),
              lags=4))


##################################################
#           Select candidate models              #
##################################################

# ARIMA(0, 1, 0)(0, 1, 1)
# ARIMA(0, 1, 0)(3, 1, 1)
# ARIMA(0, 1, 0)(3, 1, 0)


fit <- m_csgo_training %>%
  model(
    sarima010011 = ARIMA(players_total ~ 0 + pdq(0, 1, 0) + PDQ(0, 1, 1)),
    sarima010311 = ARIMA(players_total ~ 0 + pdq(0, 1, 0) + PDQ(3, 1, 1)),
    sarima010310 = ARIMA(players_total ~ 0 + pdq(0, 1, 0) + PDQ(3, 1, 0)),
    auto_ARIMA = ARIMA(players_total)
  )

fit %>%
  glance() 

# given the values of information criteria the best models seem sarima010011 and 
# sarima010310


##################################################
#                Check residuals                 #
##################################################

fit %>%
  select(sarima010011) %>%
  gg_tsresiduals()

fit %>%
  select(sarima010311) %>%
  gg_tsresiduals()

fit %>%
  select(sarima010310) %>%
  gg_tsresiduals()


############## ljung_box test ################


fit %>%
  select(sarima010011) %>%
  augment() %>%
  features(.innov, ljung_box, lag = 36)


fit %>%
  select(sarima010311) %>%
  augment() %>%
  features(.innov, ljung_box, lag = 36)

fit %>%
  select(sarima010310) %>%
  augment() %>%
  features(.innov, ljung_box, lag = 36)

# The p-values for these tests are all greater than 5%, so we do not reject 
# the null hypothesis, which means we do not have statistical evidence of the 
# presence of autocorrelation in the residuals. We can move on to the final 
# step: forecasting the series!


##################################################
#             Forecasting accuracy               #
##################################################

m_csgo_training |>
  model(sarima010011 = ARIMA(players_total ~ 0 + pdq(0, 1, 0) + PDQ(0, 1, 1))) |>
  forecast(h=13) |>
  accuracy(m_csgo_test)

m_csgo_training |>
  model(sarima010311 = ARIMA(players_total ~ 0 + pdq(0, 1, 0) + PDQ(3, 1, 1))) |>
  forecast(h=13) |>
  accuracy(m_csgo_test)

m_csgo_training |>
  model(sarima010310 = ARIMA(players_total ~ 0 + pdq(0, 1, 0) + PDQ(3, 1, 0))) |>
  forecast(h=13) |>
  accuracy(m_csgo_test)



# Given the values of MAE, MPE and MAPE the best model seems the sarima010011


##################################################
#                   Forecasts                    #
##################################################

m_csgo_training |>
  model(sarima010011 = ARIMA(players_total ~ 0 + pdq(0, 1, 0) + PDQ(0, 1, 1))) |>
  forecast(h=20) |>
  autoplot(m_csgo)

m_csgo_training |>
  model(sarima010311 = ARIMA(players_total ~ 0 + pdq(0, 1, 0) + PDQ(3, 1, 1))) |>
  forecast(h=24) |>
  autoplot(m_csgo)

m_csgo_training |>
  model(sarima010310 = ARIMA(players_total ~ 0 + pdq(0, 1, 0) + PDQ(3, 1, 0))) |>
  forecast(h=24) |>
  autoplot(m_csgo)


# Forecasting for the next year
m_csgo |>
  model(sarima010011 = ARIMA(players_total ~ 0 + pdq(0, 1, 0) + PDQ(0, 1, 1))) |>
  forecast(h=12) |>
  autoplot(m_csgo)





