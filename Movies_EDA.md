Movies_EDA
================
Dillon Issa
2023-03-19

# 1. Introduction

In this project I will complete an exploratory data analysis, EDA, on
the top 1,000 rated movies according to IMDB to find trends in consumer
preferences that led to higher gross earnings. I will then use the
findings I obtained from the analysis to provide recommendations to
business strategy for movie directors to better tailor the movie to
audience interests. <br />

# 2. Setup

## 2.1 Load Libraries

``` r
library("tidyverse")
```

    ## ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
    ## ✔ dplyr     1.1.0     ✔ readr     2.1.4
    ## ✔ forcats   1.0.0     ✔ stringr   1.5.0
    ## ✔ ggplot2   3.4.1     ✔ tibble    3.2.0
    ## ✔ lubridate 1.9.2     ✔ tidyr     1.3.0
    ## ✔ purrr     1.0.1     
    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()
    ## ℹ Use the ]8;;http://conflicted.r-lib.org/conflicted package]8;; to force all conflicts to become errors

<br />

## 2.2 Load data

``` r
movie_data <- read.csv("C:/Users/issad/Desktop/Personal Projects/IMDB Movies/Data/archive (1)/imdb_movie_data.csv")
```

<br /> Data obtained from: SHREYA JAGANI. “imdb movies data”, Version 3.
Retrieved 03/19/2023 from
<https://www.kaggle.com/datasets/shreyajagani13/imdb-movies-data>.
<br />

# 3. Process Data

In this section I will review and clean the data to ensure the data was
imported correctly, has no missing values, and no duplicate rows.

## 3.1 Review Data

First, I will review the data to ensure it was imported properly into R.
<br />

``` r
str(movie_data)
```

    ## 'data.frame':    1000 obs. of  11 variables:
    ##  $ movie        : chr  "Aguirre, der Zorn Gottes" "The General" "Kakushi-toride no san-akunin" "The Magnificent Seven" ...
    ##  $ year         : chr  "-1972" "-1926" "-1958" "-1960" ...
    ##  $ certificate  : chr  "'-" "'-" "'-" "'-" ...
    ##  $ genre.1      : chr  "Action" "Action" "Action" "Action" ...
    ##  $ genre.2      : chr  " Adventure" " Adventure" " Adventure" " Adventure" ...
    ##  $ genre.3      : chr  " Biography" " Comedy" " Drama" " Drama" ...
    ##  $ imdb_rating  : num  7.8 8.1 8.1 7.7 8.2 7.8 7.7 7.7 7.7 7.8 ...
    ##  $ metascore    : chr  "'-" "'-" "89" "74" ...
    ##  $ time_minute  : chr  "95 min" "67 min" "139 min" "128 min" ...
    ##  $ vote         : int  58519 92992 40060 97247 51515 31665 41963 28811 74643 68350 ...
    ##  $ gross_earning: chr  "'-" "$1.03M" "'-" "$4.91M" ...

``` r
head(movie_data)
```

    ##                          movie  year certificate genre.1    genre.2    genre.3
    ## 1     Aguirre, der Zorn Gottes -1972          '-  Action  Adventure  Biography
    ## 2                  The General -1926          '-  Action  Adventure     Comedy
    ## 3 Kakushi-toride no san-akunin -1958          '-  Action  Adventure      Drama
    ## 4        The Magnificent Seven -1960          '-  Action  Adventure      Drama
    ## 5                 Sherlock Jr. -1924          '-  Action     Comedy    Romance
    ## 6    Knockin' on Heaven's Door -1997          '-  Action      Crime     Comedy
    ##   imdb_rating metascore time_minute  vote gross_earning
    ## 1         7.8        '-      95 min 58519            '-
    ## 2         8.1        '-      67 min 92992        $1.03M
    ## 3         8.1        89     139 min 40060            '-
    ## 4         7.7        74     128 min 97247        $4.91M
    ## 5         8.2        '-      45 min 51515        $0.98M
    ## 6         7.8        '-      87 min 31665        $0.00M

<br /> The data was imported correctly, however due to the apostrophes
and negative signs some data types are labeled as characters when they
shouldn’t be. I will clean these issues now. <br />

``` r
movie_data$year <- gsub('-','',movie_data$year) %>% as.integer(movie_data$year)
```

    ## Warning in gsub("-", "", movie_data$year) %>% as.integer(movie_data$year): NAs
    ## introduced by coercion

``` r
movie_data[movie_data == "'-"] <- NA
movie_data$metascore <- as.integer(movie_data$metascore) 
movie_data$time_minute <- gsub(' min','',movie_data$time_minute) %>% 
  as.integer(movie_data$time_minute) 
movie_data$gross_earning <- substring(movie_data$gross_earning, 2,5) %>% 
  as.double(movie_data$gross_earning)
```

<br />

The data types are now corrected, and I filled in NA values for the
appropriate cells. Next I will check for the number of null values and
duplicate rows. <br />

Duplicate rows: <br />

``` r
sum(duplicated(movie_data))
```

    ## [1] 0

<br />

Null values: <br />

``` r
null <- numeric()
empty <- numeric()
for (i in 1:length(movie_data)) {
  
  null[i] <- sum(is.na(movie_data[i]))
  empty[i] <- sum(movie_data[i] == "")
}

colnames(movie_data)
```

    ##  [1] "movie"         "year"          "certificate"   "genre.1"      
    ##  [5] "genre.2"       "genre.3"       "imdb_rating"   "metascore"    
    ##  [9] "time_minute"   "vote"          "gross_earning"

``` r
null
```

    ##  [1]   0  33 159   0 111 365   0 157   0   0 158

``` r
empty
```

    ##  [1]  0 NA NA  0 NA NA  0 NA  0  0 NA

<br /> There are no duplicate rows, but there are some null values. I
will use a few approaches to clean this based on the column I am working
with.

- Year: I will find the year the movie was made and manually input them.
- Certificate: I will fill in “unknown” as I would also have to manually
  find this information, and it’s too much for the scope of this
  project. I also noticed some certifications were the same but listed
  differently, so I will correct that.
- Genre 2 & 3: These will be changed to “none” as most likely these
  movies are single genres.
- Metascore: I will input the median based on the main genre.
- Gross_earning: I will input the median based on the main genre. <br />

## 3.2 Filling Null Values

<br />

``` r
## Year
movie_data %>% filter(is.na(year))
```

    ##                 movie year certificate   genre.1    genre.2   genre.3
    ## 1             Get Out   NA         15+    Horror    Mystery  Thriller
    ## 2          About Time   NA          16    Comedy      Drama   Fantasy
    ## 3               Taken   NA           A    Action      Crime  Thriller
    ## 4               Drive   NA           A    Action      Drama      <NA>
    ## 5           Spotlight   NA           A Biography      Crime     Drama
    ## 6                 Ray   NA           A Biography      Drama     Music
    ## 7               Joker   NA           A     Crime      Drama  Thriller
    ## 8             Boyhood   NA           A     Drama       <NA>      <NA>
    ## 9             Flipped   NA          PG    Comedy      Drama   Romance
    ## 10               Rush   NA           R    Action  Biography     Drama
    ## 11           The Fall   NA           R Adventure      Drama   Fantasy
    ## 12              Pride   NA           R Biography     Comedy     Drama
    ## 13      No Man's Land   NA           R    Comedy      Drama       War
    ## 14 Hell or High Water   NA           R     Crime      Drama  Thriller
    ## 15           Aftersun   NA           R     Drama       <NA>      <NA>
    ## 16              Mommy   NA           R     Drama       <NA>      <NA>
    ## 17               Once   NA           R     Drama      Music   Romance
    ## 18          Apollo 13   NA           U Adventure      Drama   History
    ## 19               Coco   NA           U Animation  Adventure    Comedy
    ## 20         Inside Out   NA           U Animation  Adventure    Comedy
    ## 21        Mar adentro   NA           U Biography      Drama      <NA>
    ## 22         The Artist   NA           U    Comedy      Drama   Romance
    ## 23             Wonder   NA           U     Drama     Family      <NA>
    ## 24                 96   NA           U     Drama    Romance      <NA>
    ## 25               Room   NA           U     Drama   Thriller      <NA>
    ## 26          Searching   NA         U/A     Drama    Mystery  Thriller
    ## 27        The Fighter   NA          UA    Action  Biography     Drama
    ## 28               Baby   NA          UA    Action      Crime  Thriller
    ## 29        After Hours   NA          UA    Comedy      Crime     Drama
    ## 30               Pink   NA          UA     Crime      Drama  Thriller
    ## 31              Crash   NA          UA     Crime      Drama  Thriller
    ## 32         The Father   NA          UA     Drama    Mystery      <NA>
    ## 33            Arrival   NA          UA     Drama    Mystery    Sci-Fi
    ##    imdb_rating metascore time_minute    vote gross_earning
    ## 1          7.7        85         104  629026        176.00
    ## 2          7.8        55         123  360084         15.30
    ## 3          7.8        51          90  610444        145.00
    ## 4          7.8        78         100  655090         35.00
    ## 5          8.1        93         129  477150         45.00
    ## 6          7.7        73         152  150661         75.30
    ## 7          8.4        59         122 1323429        335.00
    ## 8          7.9       100         165  358224         25.30
    ## 9          7.7        45          90   92383          1.75
    ## 10         8.1        74         123  486611         26.90
    ## 11         7.8        64         117  113735          2.28
    ## 12         7.8        79         119   58824            NA
    ## 13         7.9        84          98   47722          1.06
    ## 14         7.6        88         102  236459         26.80
    ## 15         7.7        95         102   49097            NA
    ## 16         8.0        74         139   58591          3.49
    ## 17         7.8        89          86  118149          9.44
    ## 18         7.7        77         140  300553        173.00
    ## 19         8.4        81         105  522493        209.00
    ## 20         8.1        94          95  726277        356.00
    ## 21         8.0        74         126   82944          2.09
    ## 22         7.9        89         100  243629         44.60
    ## 23         7.9        66         113  168346        132.00
    ## 24         8.5        NA         158   32545            NA
    ## 25         8.1        86         118  427409         14.60
    ## 26         7.6        71         102  168375         26.00
    ## 27         7.8        79         116  374135         93.60
    ## 28         7.9        NA         159   58577            NA
    ## 29         7.6        90          97   72079         10.60
    ## 30         8.1        NA         136   46128          1.24
    ## 31         7.7        66         112  440241         54.50
    ## 32         8.2        88          97  162206        130.00
    ## 33         7.9        81         116  709209        100.00

``` r
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
```

<br /> Now I will double check that the data has no null values. <br />

``` r
null <- numeric()
empty <- numeric()
for (i in 1:length(movie_data)) {
  
  null[i] <- sum(is.na(movie_data[i]))
  empty[i] <- sum(movie_data[i] == "")
}

colnames(movie_data)
```

    ##  [1] "movie"         "year"          "certificate"   "genre.1"      
    ##  [5] "genre.2"       "genre.3"       "imdb_rating"   "metascore"    
    ##  [9] "time_minute"   "vote"          "gross_earning"

``` r
null
```

    ##  [1] 0 0 0 0 0 0 0 0 0 0 0

``` r
empty
```

    ##  [1] 0 0 0 0 0 0 0 0 0 0 0

<br /> The data is fully clean, and we are ready for analysis! Right
before we do so, we can get rid of the unnecessary variables we used in
the cleaning process. <br />

``` r
rm(empty, i, missing_years,null,median_earnings, median_metascores)
```

<br />

# 4. EDA

<br /> In this section I will be analyzing the data to identify trends
in consumers behaviors. I will also provide recommendations to business
strategy based on these analyses. <br />

## 4.1 Year

<br />

``` r
movie_data %>% 
  group_by(year) %>% 
  summarize(ttl_count = n(),
            min_earnings = min(gross_earning),
            avg_earnings = mean(gross_earning),
            max_earnings = max(gross_earning),
            ttl_earnings = sum(gross_earning)
            )
```

    ## # A tibble: 101 × 6
    ##     year ttl_count min_earnings avg_earnings max_earnings ttl_earnings
    ##    <dbl>     <int>        <dbl>        <dbl>        <dbl>        <dbl>
    ##  1  1920         1        47           47           47           47   
    ##  2  1921         1         5.45         5.45         5.45         5.45
    ##  3  1922         1       258          258          258          258   
    ##  4  1924         1         0.98         0.98         0.98         0.98
    ##  5  1925         2         0.05         2.75         5.45         5.5 
    ##  6  1926         1         1.03         1.03         1.03         1.03
    ##  7  1927         2         0.54         0.89         1.24         1.78
    ##  8  1928         2         0.02         5.66        11.3         11.3 
    ##  9  1930         1         3.27         3.27         3.27         3.27
    ## 10  1931         3         0.02         3.11         9.28         9.33
    ## # … with 91 more rows

``` r
movie_data %>% 
  ggplot(mapping=aes(x=year)) +
  geom_bar(fill = "red") +
  theme(axis.text.x = element_text(angle=50,vjust=.5,hjust=1)) +
  scale_color_gradient(low = "blue",high = "green") + 
  labs(title="Number of Movies by Year Released",
       subtitle="Sample of 1,000 Movies Ordered by Age Restrictions",
       caption="Data Obtained From: https://www.kaggle.com/datasets/shreyajagani13/imdb-movies-data.")
```

![](Movies_EDA_files/figure-gfm/Year%20Distribution-1.png)<!-- -->
<br />

``` r
movie_data %>% 
  ggplot(mapping = aes(x=year,y=gross_earning)) + 
  geom_point(color = "cyan4") + geom_smooth(color = "red1") + 
  labs(title="Movie Gross Earnings by Year",
       subtitle="Sample of 1,000 Movies",
       caption="Data Obtained From: https://www.kaggle.com/datasets/shreyajagani13/imdb-movies-data.")
```

    ## `geom_smooth()` using method = 'gam' and formula = 'y ~ s(x, bs = "cs")'

![](Movies_EDA_files/figure-gfm/Year%20Scatter%20Plot-1.png)<!-- -->
<br /> We see in that the bar chart is skewed left, meaning that movies
made more recently are more likely to be rated in the top 1,000. This
could be indicative of a growing popularity for movies made in recent
years. This could also indicate that there may be a higher number of
movies released compared to previous years, meaning the market is more
competitive now than before.

In the scatter plot, we can also see an upward trend for movie revenues
as the years have progressed.This reinforces the idea that movies are
becoming more popular as movies made recently are making more money on
average.

My business recommendation is that it would be better to create movies
sooner rather than later as you can enter the market before competition
increases and still capitalize on future movie popularity growth from
consumers. <br />

## 4.2 Certificate

<br />

``` r
movie_data %>% 
  group_by(certificate) %>% 
  summarize(ttl_count = n(),
            min_earnings = min(gross_earning),
            avg_earnings = mean(gross_earning),
            max_earnings = max(gross_earning),
            ttl_earnings = sum(gross_earning)
            )
```

    ## # A tibble: 16 × 6
    ##    certificate ttl_count min_earnings avg_earnings max_earnings ttl_earnings
    ##    <chr>           <int>        <dbl>        <dbl>        <dbl>        <dbl>
    ##  1 (Banned)            1       102          102          102          102   
    ##  2 12+                 1       107          107          107          107   
    ##  3 13                  5        10.4         58.0         96.5        290.  
    ##  4 15+                 2         2.83        89.4        176          179.  
    ##  5 16                  8         5.54        38.1        171          305.  
    ##  6 18                 12         3.11        32.7         88.5        392.  
    ##  7 7                   5         0.01        37.5        178          187.  
    ##  8 A                 213         0.01        60.6        335        12909.  
    ##  9 G                   2         0.02         4.42         8.82         8.84
    ## 10 PG                 11         0.08        17.8         75.1        195.  
    ## 11 PG-13              20         0.29        11.9         56.8        238.  
    ## 12 R                  73         0           27.4        363         1997.  
    ## 13 U                 270         0.06        82.5        936        22282.  
    ## 14 U/A               202         0.01       125.         858        25213.  
    ## 15 UA 16+              1        77.9         77.9         77.9         77.9 
    ## 16 Unknown           174         0           19.7        258         3432.

<br />

``` r
cert_order <- c("G","U","7","PG","U/A","12+","13","PG-13","15+",
                "16","UA 16+","18","A","R","(Banned)","Unknown")

movie_data %>% 
  ggplot(mapping=aes(x=certificate)) +
  geom_bar(fill = "red") + 
  labs(title="Number of Certifications",
       subtitle="Sample of 1,000 Movies Ordered by Age Restrictions",
       caption="Data Obtained From: https://www.kaggle.com/datasets/shreyajagani13/imdb-movies-data.") +
  theme(axis.text.x = element_text(angle=50,vjust=.5,hjust=1)) +
  scale_x_discrete(limits = cert_order)
```

![](Movies_EDA_files/figure-gfm/Certificate%20Distribution-1.png)<!-- -->
<br />

``` r
movie_data %>% 
  ggplot(mapping=aes(x=certificate,y=gross_earning)) +
  geom_point(mapping = aes(color=gross_earning)) +
  theme(axis.text.x = element_text(angle=50,vjust=.5,hjust=1)) +
  scale_color_gradient(low = "blue",high = "green") + 
  labs(title="Gross Income by Certifications",
       subtitle="Sample of 1,000 Movies Ordered by Age Restrictions",
       caption="Data Obtained From: https://www.kaggle.com/datasets/shreyajagani13/imdb-movies-data.")  +
  scale_x_discrete(limits = cert_order)
```

![](Movies_EDA_files/figure-gfm/Certificate%20Scatter%20Plot-1.png)<!-- -->
<br /> Looking at the data, there are some certificates that have very
few total counts. It would be best to get more data on those specific
categories or to group them using dummy variables, however since the
main purpose of this project is not to run regressions it is fine to
leave them as is. We see that the movies with the highest average and
total gross_earnings are the ones with a “U/A” certification. We also
see they have a relatively large count, meaning that there may be a lot
of competition for that target audience.

My business strategy recommendation would be to, although competitive,
create movies with the certification of “U”, “U/A”, or “A”. This is
because there are a lot of movies available to use as reference when
building our movie. These also seem to be the age groups with the best
chance to break out and have a highly popular film, as shown with the
max earnings. <br />

## 4.3 Genre.1

<br />

``` r
movie_data %>% 
  group_by(genre.1) %>% 
  summarize(ttl_count = n(),
            min_earnings = min(gross_earning),
            avg_earnings = mean(gross_earning),
            max_earnings = max(gross_earning),
            ttl_earnings = sum(gross_earning)
            )
```

    ## # A tibble: 14 × 6
    ##    genre.1   ttl_count min_earnings avg_earnings max_earnings ttl_earnings
    ##    <chr>         <int>        <dbl>        <dbl>        <dbl>        <dbl>
    ##  1 Action          185         0          140.         936         25934. 
    ##  2 Adventure        62         0.06        94.9        435          5885. 
    ##  3 Animation        83         0.13       115.         434          9582. 
    ##  4 Biography        86         0.02        62.3        255          5360. 
    ##  5 Comedy          150         0           31.3        285          4700. 
    ##  6 Crime           109         0.01        35.5        335          3870. 
    ##  7 Drama           292         0           36.1        659         10538. 
    ##  8 Family            1         4            4            4             4  
    ##  9 Fantasy           4        14.3        208.         303           833. 
    ## 10 Film-Noir         2         0.45         0.45         0.45          0.9
    ## 11 Horror           13         0.09        64.1        232           834. 
    ## 12 Mystery           9         1.04        34.1        128           307. 
    ## 13 Thriller          1        17.5         17.5         17.5          17.5
    ## 14 Western           3         5.32        17.4         31.8          52.1

<br />

``` r
movie_data %>% 
  ggplot(mapping=aes(x=genre.1)) +
  geom_bar(fill = "red") +
  theme(axis.text.x = element_text(angle=50,vjust=.5,hjust=1)) +
  scale_color_gradient(low = "blue",high = "green") + 
  labs(title="Number of Movies by Main Genre",
       subtitle="Sample of 1,000 Movies Ordered by Age Restrictions",
       caption="Data Obtained From: https://www.kaggle.com/datasets/shreyajagani13/imdb-movies-data.")
```

![](Movies_EDA_files/figure-gfm/Genre.1%20Distribution-1.png)<!-- -->

``` r
movie_data %>% 
  ggplot(mapping=aes(x=genre.1,y=gross_earning)) +
  geom_point(mapping = aes(color=gross_earning)) +
  theme(axis.text.x = element_text(angle=50,vjust=.5,hjust=1)) +
  scale_color_gradient(low = "blue",high = "green") + 
  labs(title="Gross Income by Main Genre",
       subtitle="Sample of 1,000 Movies Ordered by Age Restrictions",
       caption="Data Obtained From: https://www.kaggle.com/datasets/shreyajagani13/imdb-movies-data.")
```

![](Movies_EDA_files/figure-gfm/Genre.1%20Scatter%20Plot-1.png)<!-- -->
<br /> Once again we see the same issue with few data points for certain
genres, so more data should be found on those specific genres. Thus I
will give analysis both including and not including genres with low
counts.

- Including low count genres:
  - We see that the fantasy genre makes the most on average while being
    a not too competitive market. Meanwhile, the action has the highest
    total earnings and the highest grossing individual movie but is a
    competitive market.
  - Business strategy recommendation would be to create a movie where
    the main genre is “Fantasy” as it is a high grossing market with low
    competition.
- Not including low count genres:
  - We see that the action genre makes the most on average, has the
    highest total earnings, and the highest grossing individual movie.
    It is however still a competitive market.
  - Business strategy could either follow their competitors and enter a
    competitive but high earnings market like “Action”, or they could
    forgo some profits in order to build reputation in a less
    competitive but still high earning market such as “Animation” or
    “Adventure”. <br />

## 4.4 Genre.2

<br />

``` r
movie_data %>% 
  group_by(genre.2) %>% 
  summarize(ttl_count = n(),
            min_earnings = min(gross_earning),
            avg_earnings = mean(gross_earning),
            max_earnings = max(gross_earning),
            ttl_earnings = sum(gross_earning)
            ) 
```

    ## # A tibble: 21 × 6
    ##    genre.2      ttl_count min_earnings avg_earnings max_earnings ttl_earnings
    ##    <chr>            <int>        <dbl>        <dbl>        <dbl>        <dbl>
    ##  1 " Action"           18         0.52        105.         261          1893.
    ##  2 " Adventure"       111         0.13        196.         936         21761.
    ##  3 " Biography"        18         0.04         57.2        246          1030.
    ##  4 " Comedy"           39         0.29         62.4        363          2434.
    ##  5 " Crime"            79         0            60.2        534          4754.
    ##  6 " Drama"           331         0.01         48.9        718         16193.
    ##  7 " Family"           25         0.93        137.         435          3418.
    ##  8 " Fantasy"          17         0            32.5        200           552.
    ##  9 " Film-Noir"        11         2.11         11.7         59           129.
    ## 10 " History"          12         0.05         19.6         70.6         235.
    ## # … with 11 more rows

<br />

``` r
movie_data %>% 
  ggplot(mapping=aes(x=genre.2)) +
  geom_bar(fill = "red") +
  theme(axis.text.x = element_text(angle=50,vjust=.5,hjust=1)) +
  scale_color_gradient(low = "blue",high = "green") + 
  labs(title="Number of Movies by Secondary Genre",
       subtitle="Sample of 1,000 Movies Ordered by Age Restrictions",
       caption="Data Obtained From: https://www.kaggle.com/datasets/shreyajagani13/imdb-movies-data.")
```

![](Movies_EDA_files/figure-gfm/Genre.2%20Distribution-1.png)<!-- -->
<br />

``` r
movie_data %>% 
  ggplot(mapping=aes(x=genre.2,y=gross_earning)) +
  geom_point(mapping = aes(color=gross_earning)) +
  theme(axis.text.x = element_text(angle=50,vjust=.5,hjust=1)) +
  scale_color_gradient(low = "blue",high = "green") + 
  labs(title="Gross Income by Secondary Genre",
       subtitle="Sample of 1,000 Movies Ordered by Age Restrictions",
       caption="Data Obtained From: https://www.kaggle.com/datasets/shreyajagani13/imdb-movies-data.")
```

![](Movies_EDA_files/figure-gfm/Genre.2%20Scatter%20Plot-1.png)<!-- -->
<br /> In terms of the secondary genre, drama is the most used while
adventure has the highest average and total earnings. I also noticed
that action, adventure, family, and sci-fi movies made quite a bit more
on average compared to other genres.

My business strategy recommendation would be to pick action, adventure,
family, or sci-fi as the secondary genre as these are the highest
earning on average. If the goal is securing market share, I would
suggest the secondary genre be either action, family, or sci-fi as there
is far less competition. If the goal is maximizing gross earnings, I
would suggest choosing adventure. It’s also important that the secondary
genre works well with the main genre. For example, if the main genre is
action then adventure or sci-fi may be a better fit to the story than
family. <br />

## 4.5 Genre.3

<br />

``` r
movie_data %>% 
  group_by(genre.3) %>% 
  summarize(ttl_count = n(),
            min_earnings = min(gross_earning),
            avg_earnings = mean(gross_earning),
            max_earnings = max(gross_earning),
            ttl_earnings = sum(gross_earning)
            ) 
```

    ## # A tibble: 20 × 6
    ##    genre.3      ttl_count min_earnings avg_earnings max_earnings ttl_earnings
    ##    <chr>            <int>        <dbl>        <dbl>        <dbl>        <dbl>
    ##  1 " Adventure"        14         2.38        130.         261         1816  
    ##  2 " Biography"         2        77.9          77.9         77.9        156. 
    ##  3 " Comedy"           41         0           179.         434         7328. 
    ##  4 " Crime"            16         0.04         53.0        116          848. 
    ##  5 " Drama"           110         0            80.9        858         8895. 
    ##  6 " Family"           27         0.31         60.0        232         1621. 
    ##  7 " Fantasy"          41         0.06        166.         804         6814. 
    ##  8 " Film-Noir"         9         0.65         12.2         52.2        110. 
    ##  9 " History"          35         0.02         59.3        188         2075. 
    ## 10 " Horror"            5         1.09         17.4         59.7         87.2
    ## 11 " Music"            15         0.87         48.6        216          729. 
    ## 12 " Musical"          10         1.79         25.2         80.5        252. 
    ## 13 " Mystery"          49         0.01         35.4        234         1734. 
    ## 14 " Romance"          70         0            29.1        233         2039. 
    ## 15 " Sci-Fi"           45         0.37        148.         936         6645. 
    ## 16 " Sport"            11         0.07         44.8        255          493. 
    ## 17 " Thriller"         98         0.03         64.2        448         6296. 
    ## 18 " War"              30         0.29         55.9        227         1676. 
    ## 19 " Western"           7         5.01         47.1        184          329. 
    ## 20 "None"             365         0.01         49.2        718        17973.

<br />

``` r
movie_data %>% 
  ggplot(mapping=aes(x=genre.3)) +
  geom_bar(fill = "red") +
  theme(axis.text.x = element_text(angle=50,vjust=.5,hjust=1)) +
  scale_color_gradient(low = "blue",high = "green") + 
  labs(title="Number of Movies by Secondary Genre",
       subtitle="Sample of 1,000 Movies Ordered by Age Restrictions",
       caption="Data Obtained From: https://www.kaggle.com/datasets/shreyajagani13/imdb-movies-data.")
```

![](Movies_EDA_files/figure-gfm/Genre.3%20Distribution-1.png)<!-- -->
<br />

``` r
movie_data %>% 
  ggplot(mapping=aes(x=genre.3,y=gross_earning)) +
  geom_point(mapping = aes(color=gross_earning)) +
  theme(axis.text.x = element_text(angle=45,vjust=.65, hjust=1)) +
  scale_color_gradient(low = "blue",high = "green") + 
  labs(title="Gross Income by Tertiary Genre",
       subtitle="Sample of 1,000 Movies Ordered by Age Restrictions",
       caption="Data Obtained From: https://www.kaggle.com/datasets/shreyajagani13/imdb-movies-data.")
```

![](Movies_EDA_files/figure-gfm/Genre.3%20Scatter%20Plot-1.png)<!-- -->
<br /> The highest grossing tertiary genres on average are adventure,
comedy, fantasy, and sci-fi. Adventure is the least competitive market,
while the other three genres seem to be around the same level of
competitiveness. There also seems to be a large number of movies that do
not have a third genre.

My business recommendation would be to make the third genre either
adventure, comedy, fantasy, or sci-fi. All these third genres are
significantly higher than the other options while maintaining nearly the
same level of market competition. The reason I am not specifically
choosing one over the other is because it would be wise to ensure the
third genre works well with the main and secondary genres as well. By
narrowing it down to 4 options instead of 1 or 2, we maintain some
flexibility for the structure of the movie. <br />

## 4.6 IMDB Rating

<br />

``` r
movie_data %>% 
  group_by(imdb_rating) %>% 
  summarize(ttl_count = n(),
            min_earnings = min(gross_earning),
            avg_earnings = mean(gross_earning),
            max_earnings = max(gross_earning),
            ttl_earnings = sum(gross_earning)
            ) 
```

    ## # A tibble: 17 × 6
    ##    imdb_rating ttl_count min_earnings avg_earnings max_earnings ttl_earnings
    ##          <dbl>     <int>        <dbl>        <dbl>        <dbl>        <dbl>
    ##  1         7.6        77         0.05         74.2        389         5717. 
    ##  2         7.7       171         0            53.6        434         9161. 
    ##  3         7.8       155         0            66.0        936        10222. 
    ##  4         7.9       129         0.01         57.6        760         7425. 
    ##  5         8         127         0.01         55.5        623         7051  
    ##  6         8.1       131         0.01         58.7        381         7686. 
    ##  7         8.2        71         0.01         86.7        804         6153. 
    ##  8         8.3        46         0.03         72.2        718         3322. 
    ##  9         8.4        33         0.28        134.         858         4426. 
    ## 10         8.5        24         0.02         64.4        422         1546. 
    ## 11         8.6        14         0.27        108.         322         1515. 
    ## 12         8.7         5        46.8         140.         290          698. 
    ## 13         8.8         9         6.1         184.         342         1656. 
    ## 14         8.9         1       107           107          107          107  
    ## 15         9           5         4.36        214.         534         1070. 
    ## 16         9.2         1       134           134          134          134  
    ## 17         9.3         1        28.3          28.3         28.3         28.3

<br />

``` r
movie_data %>% 
  ggplot(mapping=aes(x=imdb_rating)) +
  geom_bar(fill = "red") +
  theme(axis.text.x = element_text(angle=50,vjust=.5,hjust=1)) +
  scale_color_gradient(low = "blue",high = "green") + 
  labs(title="Number of Movies by IMDB Rating",
       subtitle="Sample of 1,000 Movies Ordered by IMDB Rating",
       caption="Data Obtained From: https://www.kaggle.com/datasets/shreyajagani13/imdb-movies-data.")
```

![](Movies_EDA_files/figure-gfm/IMDB_Rating%20Distribution-1.png)<!-- -->
<br />

``` r
movie_data %>% 
  ggplot(mapping=aes(x=imdb_rating,y=gross_earning)) +
  geom_point(mapping = aes(color=gross_earning)) +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  theme(axis.text.x = element_text(angle=45,vjust=.65, hjust=1)) +
  scale_color_gradient(low = "blue",high = "green") + 
  labs(title="Gross Income by IMDB Rating",
       subtitle="Sample of 1,000 Movies Ordered by IMDB Rating",
       caption="Data Obtained From: https://www.kaggle.com/datasets/shreyajagani13/imdb-movies-data.")
```

    ## `geom_smooth()` using formula = 'y ~ x'

![](Movies_EDA_files/figure-gfm/IMDB_Rating%20Scatter%20Plot-1.png)<!-- -->
<br /> As seen from the bar chart’s skew to the right, most of the
movies are rated between 7.6 and 8.5 on IMDB. More notably, the scores
between the range of 7.7 and 8.1 are much more frequent compared to
other scores. Looking at the scatter plot, we see a positive correlation
between IMDB rating and gross earnings. This means that as the IMDB
rating increases, we should expect more earnings.

My business strategy recommendation would be to keep a minimum target
rating of 7.7 on IMDB. This way we at the least are matching with most
competitors in the market. Targeting a higher score would most likely
yield higher gross earnings, but it may also come with higher costs when
making the movie. Since this data set does not contain the budgets for
each movie, I decided to choose the minimum score to maintain to ensure
entering the top 1,000 movies on IMDB. <br />

## 4.7 Metascore

Due to there being many metascore values, I felt it would be better to
put them into groups of 10 and get an idea of a general range to aim
for. <br />

``` r
metascore_grouping <- 
  movie_data %>% 
  mutate(metascore_groups = 
           case_when(metascore <= 40 ~ '0 - 40 metascore',
                     metascore > 40 & metascore <= 50 ~ '40 - 50 metascore',
                     metascore > 50 & metascore <= 60 ~ '50 - 60 metascore',
                     metascore > 60 & metascore <= 70 ~ '60 - 70 metascore',
                     metascore > 70 & metascore <= 80 ~ '70 - 80 metascore',
                     metascore > 80 & metascore <= 90 ~ '80 - 90 metascore',
                     metascore > 90 ~ '90+ metascore')
         )

metascore_grouping %>% 
  group_by(metascore_groups) %>% 
  summarize(ttl_count = n(),
            min_earnings = min(gross_earning),
            avg_earnings = mean(gross_earning),
            max_earnings = max(gross_earning),
            ttl_earnings = sum(gross_earning)
            )
```

    ## # A tibble: 7 × 6
    ##   metascore_groups  ttl_count min_earnings avg_earnings max_earnings ttl_earni…¹
    ##   <chr>                 <int>        <dbl>        <dbl>        <dbl>       <dbl>
    ## 1 0 - 40 metascore          4         0.01         42.0         69.9        168.
    ## 2 40 - 50 metascore        13         0.03         51.5        216          670.
    ## 3 50 - 60 metascore        41         0            77.4        335         3173.
    ## 4 60 - 70 metascore       137         0            94.9        678        12997.
    ## 5 70 - 80 metascore       340         0            68.6        936        23309.
    ## 6 80 - 90 metascore       319         0.01         64.4        760        20554.
    ## 7 90+ metascore           146         0.01         48.3        435         7047.
    ## # … with abbreviated variable name ¹​ttl_earnings

<br />

``` r
metascore_grouping %>% 
  ggplot(mapping=aes(x=metascore_groups)) +
  geom_bar(fill = "red") +
  theme(axis.text.x = element_text(angle=50,vjust=.5,hjust=.5)) +
  scale_color_gradient(low = "blue",high = "green") + 
  labs(title="Number of Movies by Metascore",
       subtitle="Sample of 1,000 Movies Ordered by Metascore",
       caption="Data Obtained From: https://www.kaggle.com/datasets/shreyajagani13/imdb-movies-data.")
```

![](Movies_EDA_files/figure-gfm/Metascore%20Distribution-1.png)<!-- -->
<br />

``` r
movie_data %>% 
  ggplot(mapping=aes(x=metascore,y=gross_earning)) +
  geom_point(mapping = aes(color=gross_earning)) +
  geom_smooth(method = "gam", se = FALSE, color = "red") +
  theme(axis.text.x = element_text(angle=45,vjust=.65, hjust=.5)) +
  scale_color_gradient(low = "blue",high = "green") + 
  labs(title="Gross Income by Metascore",
       subtitle="Sample of 1,000 Movies Ordered by Metascore",
       caption="Data Obtained From: https://www.kaggle.com/datasets/shreyajagani13/imdb-movies-data.")
```

    ## `geom_smooth()` using formula = 'y ~ s(x, bs = "cs")'

![](Movies_EDA_files/figure-gfm/Metascore%20Scatter%20Plot-1.png)<!-- -->
<br />

``` r
metascore_grouping %>% 
  ggplot(mapping=aes(x=metascore_groups,y=gross_earning)) +
  geom_point(mapping = aes(color=gross_earning)) +
  geom_smooth(method = "glm", se = FALSE, color = "red") +
  theme(axis.text.x = element_text(angle=45,vjust=.65, hjust=.5)) +
  scale_color_gradient(low = "blue",high = "green") + 
  labs(title="Gross Income by Metascore",
       subtitle="Sample of 1,000 Movies Ordered by Metascore",
       caption="Data Obtained From: https://www.kaggle.com/datasets/shreyajagani13/imdb-movies-data.")
```

    ## `geom_smooth()` using formula = 'y ~ x'

![](Movies_EDA_files/figure-gfm/Metascore%20(Grouped)%20Scatter%20Plot-1.png)<!-- -->
<br /> From the tibble we see that movies with a metascore between 60-70
have the highest average earnings while being moderately competitive. We
also see that the bar chart is skewed left, meaning most of these movies
have higher metascores.

For the scatter plot, I want to elaborate on why I used a GAM model
instead of a linear model (LM) like in previous graphs.

When using a LM we see that the higher the metascore the lower the gross
earnings, even though according to IMDB a higher metascore means a
“better” film. Due to this, I thought perhaps there could be outliers in
the metascore that skewed the results and tried three more approaches:

- Filtered out metascore values less than 40 as there were very few of
  them.
- Used a GAM model instead of a standard linear regression model to see
  if there may be a non-linear relationship between metascore and
  gross_earnings.
- Used the metascore grouping like with the bar chart.

The filter approach led to the same results as the linear regression
model, but the GAM model yielded a regression that was curved upwards
for a short period of time. This curvature proves there indeed is a
non-linear relationship between the variables, and that the “sweet spot”
for metascore is where the regression transitions from positive to
negative.The range this lies between is about 55 and 62. The grouping
method seemed to show an upward trend on the scatter plot, but I could
not run a regression on it as instead of comparing two numeric data
types I was comparing a numeric and a character. I decided to opt for
the GAM model.

My business strategy recommendation is to target a metascore between 60
and 70. According the tibble, this was the range that yielded the
highest average earnings. It also is near the inflection point of the
GAM model, so even if we do exceed a little bit it shouldn’t hinder
gross earnings too much. <br />

## 4.8 Time

I will separate the movie times into categories similar to metascore.
<br />

``` r
time_grouping <- 
  movie_data %>% 
  mutate(time_groups = 
           case_when(time_minute <= 60 ~ '0 - 1 hours',
                     time_minute > 60 & time_minute <= 120 ~ '1 - 2 hours',
                     time_minute > 120 & time_minute <= 160 ~ '1 - 2 hours',
                     time_minute > 160 & time_minute <= 240 ~ '2 - 3 hours',
                     time_minute > 240 ~ '3+ hours')) 

time_grouping %>% 
  group_by(time_groups) %>% 
  summarize(ttl_count = n(),
            min_earnings = min(gross_earning),
            avg_earnings = mean(gross_earning),
            max_earnings = max(gross_earning),
            ttl_earnings = sum(gross_earning)
            )
```

    ## # A tibble: 4 × 6
    ##   time_groups ttl_count min_earnings avg_earnings max_earnings ttl_earnings
    ##   <chr>           <int>        <dbl>        <dbl>        <dbl>        <dbl>
    ## 1 0 - 1 hours         1         0.98         0.98         0.98         0.98
    ## 2 1 - 2 hours       893         0           64.6        936        57694.  
    ## 3 2 - 3 hours       103         0.07        97.7        858        10062.  
    ## 4 3+ hours            3         4.41        53.4         77.9        160.

<br />

``` r
time_grouping %>% 
  ggplot(mapping=aes(x=time_groups)) +
  geom_bar(fill = "red") +
  theme(axis.text.x = element_text(angle=50,vjust=.5,hjust=.5)) +
  scale_color_gradient(low = "blue",high = "green") + 
  labs(title="Gross Income by Time in Minutes",
       subtitle="Sample of 1,000 Movies Ordered by Time in Minutes",
       caption="Data Obtained From: https://www.kaggle.com/datasets/shreyajagani13/imdb-movies-data.")
```

![](Movies_EDA_files/figure-gfm/Time%20Distribution-1.png)<!-- -->
\< br /\>

``` r
movie_data %>% 
  ggplot(mapping=aes(x=time_minute,y=gross_earning)) +
  geom_point(mapping = aes(color=gross_earning)) +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  theme(axis.text.x = element_text(angle=45,vjust=.65, hjust=1)) +
  scale_color_gradient(low = "blue",high = "green") + 
  labs(title="Gross Income by Time in Minutes ",
       subtitle="Sample of 1,000 Movies Ordered by Time in Minutes",
       caption="Data Obtained From: https://www.kaggle.com/datasets/shreyajagani13/imdb-movies-data.")
```

    ## `geom_smooth()` using formula = 'y ~ x'

![](Movies_EDA_files/figure-gfm/Time%20Scatter%20Plot-1.png)<!-- -->
<br /> From the tibble we see that movies between the length of 2 and 3
hours make the most on average while also being significantly less
competitive than movies between 1 and 2 hours. We also see from the
scatter plot that a longer movie time is correlated with higher gross
revenues, which reinforces our findings from the tibble.

My business strategy recommendation would be to make the movie between 2
and 3 hours long as the average earnings are highest and there is
moderate competition. <br />

## 4.9 Votes

Like with metascore and time_minute, I will group the votes. Due to
there being a large disparity in the vote values, ranging from 25,000 to
2.5 million, I decided to use quantiles to divide the dataset into
equally sized groups. <br />

``` r
voting_grouping <- 
  movie_data %>% 
  mutate(voting_groups = cut(vote, breaks = quantile(vote, probs = seq(0, 1, by = 0.2)),
                             include.lowest = TRUE, labels = FALSE)) %>%
  mutate(voting_groups = case_when(
    voting_groups == 1 ~ paste0(min(vote), "-", quantile(vote, probs = 0.2)),
    voting_groups == 2 ~ paste0(quantile(vote, probs = 0.2) + 1, "-", quantile(vote, probs = 0.4)),
    voting_groups == 3 ~ paste0(quantile(vote, probs = 0.4) + 1, "-", quantile(vote, probs = 0.6)),
    voting_groups == 4 ~ paste0(quantile(vote, probs = 0.6) + 1, "-", quantile(vote, probs = 0.8)),
    voting_groups == 5 ~ paste0(quantile(vote, probs = 0.8) + 1, "-", max(vote))
    )
  )

voting_grouping %>% 
  group_by(voting_groups) %>% 
  summarize(ttl_count = n(),
            min_earnings = min(gross_earning),
            avg_earnings = mean(gross_earning),
            max_earnings = max(gross_earning),
            ttl_earnings = sum(gross_earning)
            )
```

    ## # A tibble: 5 × 6
    ##   voting_groups     ttl_count min_earnings avg_earnings max_earnings ttl_earni…¹
    ##   <chr>                 <int>        <dbl>        <dbl>        <dbl>       <dbl>
    ## 1 102379.4-226210.6       200         0.01         36.5          243       7305.
    ## 2 226211.6-547057.6       200         0            78.3          659      15668.
    ## 3 25730-52691.4           200         0            19.0          246       3801.
    ## 4 52692.4-102378.4        200         0.01         27.0          258       5396.
    ## 5 547058.6-2714258        200         0.71        179.           936      35747.
    ## # … with abbreviated variable name ¹​ttl_earnings

<br /> Looking at the results from the tibble, we see that the vote
range that gave the highest earnings in every aspect was between
546,058 - 2,714,258. This may indicate that there doesn’t necessarily
need to be a target for votes, just the more you have the higher
earnings on average. I want to test this further, so I will break down
that quantile even further. \< br /\>

``` r
voting_grouping2 <- 
  movie_data %>% 
  filter(vote >= 547058.6) %>% 
  mutate(voting_groups = cut(vote, breaks = quantile(vote, probs = seq(0, 1, by = 0.2)),
                             include.lowest = TRUE, labels = FALSE)) %>%
  mutate(voting_groups = case_when(
    voting_groups == 1 ~ paste0(min(vote), "-", quantile(vote, probs = 0.2)),
    voting_groups == 2 ~ paste0(quantile(vote, probs = 0.2) + 1, "-", quantile(vote, probs = 0.4)),
    voting_groups == 3 ~ paste0(quantile(vote, probs = 0.4) + 1, "-", quantile(vote, probs = 0.6)),
    voting_groups == 4 ~ paste0(quantile(vote, probs = 0.6) + 1, "-", quantile(vote, probs = 0.8)),
    voting_groups == 5 ~ paste0(quantile(vote, probs = 0.8) + 1, "-", max(vote))
    )
  )

voting_grouping2 %>% 
  group_by(voting_groups) %>% 
  summarize(ttl_count = n(),
            min_earnings = min(gross_earning),
            avg_earnings = mean(gross_earning),
            max_earnings = max(gross_earning),
            ttl_earnings = sum(gross_earning)
            )
```

    ## # A tibble: 5 × 6
    ##   voting_groups      ttl_count min_earnings avg_earnings max_earnings ttl_earn…¹
    ##   <chr>                  <int>        <dbl>        <dbl>        <dbl>      <dbl>
    ## 1 1144910.4-2714258         40        19.5          244.          858      9755.
    ## 2 547564-639940             40         0.71         139.          718      5571.
    ## 3 639941-743830             40        15            147.          532      5861.
    ## 4 743831-861182.4           40         1.48         160.          804      6408.
    ## 5 861183.4-1144909.4        40         2.83         204.          936      8151.
    ## # … with abbreviated variable name ¹​ttl_earnings

<br /> Based on these results, we see that every category has higher
average and total earnings than it’s predecessor. In other words, there
isn’t a specific target range to aim for in terms of number of votes as
the higher the better. This may be because votes could be a good
indicator of viewership. We know movies make a large chunk, if not
majority, of their earnings from viewership. It also makes sense that
movies with higher viewership have more votes. Through these
correlations with viewership, it makes sense why votes and
gross_earnings have a positive correlation with one another with no
specific target range.

Let’s visualize this through both a linear model and a GAM model to see
if the graph matches our findings in the tibble. <br />

``` r
movie_data %>% 
  ggplot(mapping=aes(x=vote,y=gross_earning)) +
  geom_point(mapping = aes(color=gross_earning)) +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  theme(axis.text.x = element_text(angle=45,vjust=.65, hjust=1)) +
  scale_color_gradient(low = "blue",high = "green") + 
  labs(title="Gross Income by Votes",
       subtitle="Sample of 1,000 Movies Ordered by Number of Votes",
       caption="Data Obtained From: https://www.kaggle.com/datasets/shreyajagani13/imdb-movies-data.")
```

    ## `geom_smooth()` using formula = 'y ~ x'

![](Movies_EDA_files/figure-gfm/Vote%20Scatter%20Plot%20Linear%20Model-1.png)<!-- -->
<br />

``` r
movie_data %>% 
  ggplot(mapping=aes(x=vote,y=gross_earning)) +
  geom_point(mapping = aes(color=gross_earning)) +
  geom_smooth(method = "gam", se = FALSE, color = "red") +
  theme(axis.text.x = element_text(angle=45,vjust=.65, hjust=1)) +
  scale_color_gradient(low = "blue",high = "green") + 
  labs(title="Gross Income by Votes",
       subtitle="Sample of 1,000 Movies Ordered by Number of Votes",
       caption="Data Obtained From: https://www.kaggle.com/datasets/shreyajagani13/imdb-movies-data.")
```

    ## `geom_smooth()` using formula = 'y ~ s(x, bs = "cs")'

![](Movies_EDA_files/figure-gfm/Vote%20Scatter%20Plot%20GAM%20Model-1.png)<!-- -->
<br /> The linear model supports the tibble, and the GAM seems to as
well. The GAM does show diminishing earnings as votes increase, but it
still seems to be an overall upward trend. Thus, my conclusion for votes
is that the higher the better.

My business strategy would be to aim for the highest amount of votes
feasible given the budget constraints. <br />

# 5. Conclusion

## 5.1 Business Recommendations

According to the findings, my recommendations for movie business
strategy is the following:

- **Release Year:**
  - Newer movies make more on average and the popularity of movies is
    increasing. It would be wise to make a movie sooner rather than
    later to capture this growth and capitalize on future audience
    growth.
- **Certification:**
  - Create movies with the certification of “U”, “U/A”, or “A” as these,
    although competitive, make the most on average. There are also lot
    of movies available in these categories to use as reference.
- **Main Genre: \[Three potential options\]**
  - Make movie a “Fantasy” as it is highest earning on average with low
    competitiveness, but data may be skewed due to small amount of
    observations.
  - Make movie a “Action” as it is highest earning on average with a lot
    of data to support it, but is a very competitive market.
  - Make move a “Animation” or “Adventure” as these are high earning,
    moderate competition, and has a lot of data to support it.
- **Secondary Genre:**
  - If the goal is securing market share, I would suggest the secondary
    genre be either “Action”, “Family”, or “Sci-Fi” as there is far less
    competition with high earnings.
  - If the goal is maximizing gross earnings, I would suggest choosing
    adventure.
  - Make sure secondary genre works well with main genre.
- **Tertiary Genre:**
  - Make the third genre either “Adventure”, “Comedy”, “Fantasy”, or
    “Sci-Fi”. All these genres are significantly higher than the others
    while maintaining nearly the same level of market competition.
    Keeping all 4 as options also gives flexibility to ensure the genre
    works with the main and secondary genres.
- **IMDB Rating:**
  - Maintain a minimum target of 7.7 on IMDB to match competitors. Could
    go higher for more earnings, but could also lead to higher costs.
- **Metascore:**
  - Target a metascore between 60 and 70 as this range yielded the
    highest average earnings. Metascores higher and lower than this
    range showed lower earnings on average.
- **Movie Run Time:**
  - Make the movie between 2 and 3 hours long as the average earnings
    are highest and there is moderate competition.
- **Votes:**
  - Aim for the highest amount of votes feasible given the budget
    constraints. Higher votes correlated with higher gross earnings.
    <br />

## 5.2 Limitations & Future Works

There are a few limitations to this analysis:

First, I only did an EDA of the variables individually. I believe some
variables could be analyzed together to find different trends that may
provide useful insights that were not found in this project. For
example, making the fill for year as genre.1 instead of gross_earnings
may provide insight as to what movies were most popular per given year.
Going further, you could potentially use regression models to better
understand the correlations between variables or do an optimization
project to find the theoretical ideal movie.

Another limitation is that there were many data points that were low in
observations. Some movies with low counts could have skewed the results,
showing much higher gross earnings. An example of this would be fantasy
in the main genre, which only had 4 observations. I tried to account for
this as best as possible, but there could be some human error.

# 6. Citations

Data obtained from: SHREYA JAGANI. “imdb movies data”, Version 3.
Retrieved 03/19/2023 from
<https://www.kaggle.com/datasets/shreyajagani13/imdb-movies-data>.
