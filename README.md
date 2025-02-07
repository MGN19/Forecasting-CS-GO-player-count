# 🎯 CS:GO Player Count Forecasting Project

## 📌 Overview
This project analyzed and forecasted the player count of *Counter-Strike: Global Offensive (CS:GO)* using historical data from *SteamDB* 📊 and statistical modeling techniques in R 🖥️. The primary focus was to assess the impact of the release of *CS:GO 2* on the *CS:GO* player base and predict future trends.

This was a group project and was done for the **Forecasting Methods** course.

<br>

## 🎯 Motivation
The announcement and beta release of *CS:GO 2* led to fluctuations in player count 📉📈, and this study aimed to quantify and predict the long-term implications of this transition. Understanding these trends was crucial for the gaming community 🎮 to anticipate changes in player engagement.

<br>

## 📂 Data Sources
- 🔹 *SteamDB*: Extracted historical player count data from 2012 to 2023.
- The data used can be found in the csv file: `CSGO Lifetime Chart.csv`.

<br>

## ⚙️ Methodology
### 1️⃣ **Data Preprocessing**
   - Addressed missing values using interpolation with the average of neighboring values.
   - Converted the dataset into a *tsibble* (time series tibble) indexed by month 🗓️.
   - Dividing the data set into training and test for accurate forecasting purposes.

<br>

### 2️⃣ **Exploratory Data Analysis**
   - Identified key trends and anomalies 📊.
   - Noted historical events that impacted player count, such as the free-to-play transition, COVID-19, and the release of *Valorant*.

<br>

### 3️⃣ **Seasonality & Differencing**
   - Conducted variance analysis, unit root testing, and seasonal differencing 🔍.
   - Identified seasonal patterns where player counts increased during holidays and *Steam* sales events 🛍️.

<br>

### 4️⃣ **Model Selection**
   - Considered three candidate SARIMA models:
     - 📌 SARIMA(0,1,0)(0,1,1)[12]
     - 📌 SARIMA(0,1,0)(3,1,1)[12]
     - 📌 SARIMA(0,1,0)(3,1,0)[12]
   - Evaluated models based on information criteria and forecasting accuracy 🎯.
   - Selected **SARIMA(0,1,0)(0,1,1)[12]** as the best-fit model 🏆.

<br>

### 5️⃣ **Forecasting**
   - Applied the selected SARIMA model to predict the *CS:GO* player count from 2023 to 2024 🔮.
   - Generated interval forecasts and visualized results 📉.

<br>

## 📊 Results & Insights
- The forecast indicated a decline in *CS:GO* player count due to the shift of the competitive scene to *CS:GO 2*.
- Seasonal trends remained significant, with peaks expected during major *Steam* promotional events and holidays 🎄.
- The introduction of exclusive features for *CS:GO Prime* members in 2021 negatively impacted player count, a trend that might continue post-*CS:GO 2* release.

<br>

## 🔧 Tools & Libraries Used
- **R**: Statistical computing and modeling 📊
- **tsibble**: Time series data manipulation 📆
- **ggplot2**: Data visualization 🎨
- **forecast**: ARIMA/SARIMA modeling 📈

<br>

## 🚀 How to Run the Project
1. Installed required R packages:
   ```r
   install.packages(c("tsibble", "forecast", "ggplot2"))
   ```

The R script is available in `CS_GO.R`, and the HTML output of the script can be found in `FORECASTING_PROJECT.html`.  
Additionally, the code for the poster is located in `FORECASTING_PROJECT.Rmd`.
