library(data.table)
library(prophet)
library(ggplot2)
options(scipen=999)

data <- fread("~/Downloads/owid-covid-data_Oct23.csv")
# data <- fread("~/Downloads/owid-covid-data.csv")
countries <-c("United States","India","United Kingdom")
# countries <- unique(data$locatio,"Unin)

for (i in 1:length(countries)){
  
  country <- countries[i]
  country_data <- data[data$location==country,]
  country_data_sub <- country_data[,c(4,5,6,7,8)]
  # country_data_sub <- country_data[,c(3,4)]
  country_data_sub$date<- as.Date(country_data_sub$date)
  #The next 2 lines plots the cumulative cases of covid and the third line to close the window
  pdf(paste0(country," cumulative.pdf"),width=16)
  plot(as.Date(country_data_sub$date),country_data_sub$total_cases,main=paste0(country),ylab = "Total Cases",xlab = "Date")
  dev.off()

  country_data_sub<-country_data_sub[country_data_sub$date<="2020-08-30",]
  
  ds <- country_data_sub$date  
  y<- country_data_sub$total_cases
  #The next 2 lines are for doing the same for new cases and total death
  # y1 <- country_data_sub$new_cases
  # y2 <-country_data_sub$total_deaths
  
  #create a data frame with date stamps and total cases
  df <- data.frame(ds,y) # total case
  #df2 <- data.frame(ds,y1) # new case
  # df3 <- data.frame(ds,y2) # death

  

  # usinng prohet to create prediction periods=30 while creating 30 as we are trying to predict the next 30 days
  m<- prophet(df)
  future <- make_future_dataframe(m,periods=110)
  #forecast is created using the predict function of prophet on the prophet model as an argument followed by future data frame of 30 days
  # you can play around with the periods value, might affect, efficiency of the model
  forecast <- predict(m,future)
  
  #Saving the plots as pdg with width 16 which pretty much covers my computer window without distortion
  # print (paste0("~/Desktop/covid/",country,".pdf"))
  setwd("~/Desktop/covid/")
  pdf(paste0(country,".pdf"),width=16)
  print(plot(m,forecast)+theme_classic()+ggtitle(paste0(country," COVID 19 case prediction")) + xlab("Dates") + ylab("Total Cases"))
  dev.off()

  # Test model predicitions
  actual <- m$history$y
  predict <- forecast$yhat[1:length(actual)]
  pdf(paste0(country," model predict.pdf"),width=16)
  plot(actual,predict,main=paste0(country," model predict"))
  abline(lm(predict~actual),col="red")
  
  print (summary(lm(predict~actual)))
  dev.off()

}