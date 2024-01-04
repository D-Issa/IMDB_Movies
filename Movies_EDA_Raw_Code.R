# Setup
## Load Libraries

library("tidyverse")

## Load data
movie_data <- read.csv("C:/Users/issad/Desktop/Personal Projects/IMDB Movies/Data/archive (1)/imdb_movie_data.csv")

## View Data
str(movie_data)
head(movie_data)

## Clean Data
movie_data$year <- gsub('-','',movie_data$year) %>% as.integer(movie_data$year)
movie_data[movie_data == "'-"] <- NA
movie_data$metascore <- as.integer(movie_data$metascore) 
movie_data$time_minute <- gsub(' min','',movie_data$time_minute) %>% 
  as.integer(movie_data$time_minute) 
movie_data$gross_earning <- substring(movie_data$gross_earning, 2,5) %>% 
  as.double(movie_data$gross_earning)

### Duplicate Rows
sum(duplicated(movie_data))

### Null & NA Values
null <- numeric()
empty <- numeric()
for (i in 1:length(movie_data)) {
  
  null[i] <- sum(is.na(movie_data[i]))
  empty[i] <- sum(movie_data[i] == "")
}

colnames(movie_data)
null
empty

## Year
movie_data %>% filter(is.na(year))

missing_years = c(2017,2013,2009,2011,2015,2004,2019,2014,2010,2013,
                  2022,2021,2020,2016,2022,2015,2007,1995,2017,2015,
                  2004,2011,2017,2018,2015,2018,2010,2010,2020,2016,
                  2004,2021,2016)

movie_data$year[is.na(movie_data$year)] <- missing_years

## Certificate
movie_data$certificate[is.na(movie_data$certificate)] <- "Unknown"
movie_data$certificate[movie_data$certificate == "UA" ] <- "U/A"
movie_data$certificate[movie_data$certificate == "UA 13+" ] <- "U/A"
movie_data$certificate[movie_data$certificate == "UA" ] <- "U/A"
movie_data$certificate[movie_data$certificate == "Unrated" ] <- "Unknown"
movie_data$certificate[movie_data$certificate == "Not Rated" ] <- "Unknown"
movie_data$certificate[movie_data$certificate == "M/PG" ] <- "PG"


## Genre 2 & 3
movie_data$genre.2[is.na(movie_data$genre.2)] <- "None"
movie_data$genre.3[is.na(movie_data$genre.3)] <- "None"

## Metascore
median_metascores <- 
  movie_data %>% group_by(genre.1) %>% drop_na() %>% 
  summarize(med_metascore = median(metascore))

movie_data <- left_join(movie_data, median_metascores, by = "genre.1")

movie_data <- movie_data %>% 
  mutate(metascore = ifelse(is.na(metascore), med_metascore, metascore)) %>%
  select(-med_metascore)

movie_data$metascore <- as.numeric(movie_data$metascore)

## Gross Earnings (in millions)
median_earnings <- 
  movie_data %>% group_by(genre.1) %>% drop_na() %>% 
  summarize(med_earnings = median(gross_earning))

movie_data <- left_join(movie_data, median_earnings, by = "genre.1")

movie_data <- movie_data %>% 
  mutate(gross_earning = ifelse(is.na(gross_earning), med_earnings, gross_earning)) %>%
  select(-med_earnings)

movie_data$gross_earning <- as.numeric(movie_data$gross_earning)

