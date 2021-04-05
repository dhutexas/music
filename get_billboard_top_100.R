################### Billboard Top Songs of the Year ####################
#' Get the song rank, artist, and title for end-of-year Billboard rankings
#' Pulls data from Wikipedia (so subject to change)
#' 
#' For 1959+ there are 100 top songs; from 1946-1958 this number is smaller
#' The function below accounts for the changing sizes by choosing the correct url
#' 1959+ -> https://en.wikipedia.org/wiki/Billboard_Year-End_Hot_100_singles_of_
#  1956-1958 -> https://en.wikipedia.org/wiki/Billboard_year-end_top_50_singles_of_
#  1949-1955 -> https://en.wikipedia.org/wiki/Billboard_year-end_top_30_singles_of_
#  1946-1948 -> https://en.wikipedia.org/wiki/Billboard_year-end_top_singles_of_
#'
#'
#' @import tidyverse magrittr lubridate rvest
#'
#' @param year (int) The four digit year for end-of-year chart data
#' 
#' @return A dataframe with final song rank (number), artists (artist), 
#' song title (title), year (year), and lead artist (artist_clean)
#'
#' @example get_top_100(2014)
#' 

get_top_100 <- function(year) {
  
  library(tidyverse)
  library(magrittr)
  library(lubridate)
  library(rvest)
  
  # make simple table of all years possible, with their corresponding urls
  years <- seq(from = 1946, to = year(lubridate::today()), by = 1) %>% as_tibble() %>% rename(year_end = value) %>%
    mutate(link = ifelse(year >= 1959, paste0('https://en.wikipedia.org/wiki/Billboard_Year-End_Hot_100_singles_of_',year),
                         ifelse((year < 1959 & year >= 1956), paste0('https://en.wikipedia.org/wiki/Billboard_year-end_top_50_singles_of_',year),
                                ifelse((year < 1956 & year > 1948), paste0('https://en.wikipedia.org/wiki/Billboard_year-end_top_30_singles_of_',year),
                                       paste0('https://en.wikipedia.org/wiki/Billboard_year-end_top_singles_of_',year)))))
  
  # pull link for the requested year
  link <- years %>%
    filter(year_end == year) %>%
    select(link) %>%
    pull()
  
  # get table
  yearly <- read_html(glue::glue(toString(link)))
  
  # clean it up
  tables <- yearly %>% 
    html_table(header = TRUE, fill = TRUE)
  
  # deal with table differences in years 2012 and 2013 to ensure uniformity of results
  if (year == 2012 | year == 2013) {
    songs <- tables[[2]] %>%
      rename(number = 1, # use location because sometimes issue with name on Wikipedia
             title = 2,
             artist = 3) %>%
      mutate(year = year,
             title = gsub('"', "", title)) %>%
      mutate(artist_clean = sub(' feat.*','', artist)) %>% # remove all featuring artists
      mutate(artist_clean = sub(',.*', '', artist_clean)) %>% # remove all collaborators
      mutate(artist_clean = sub(' &.*', '', artist_clean)) %>%
      mutate(artist_clean = sub(' with.*', '', artist_clean)) %>%
      mutate(artist_clean = sub(' and.*', '', artist_clean)) -> songs
  } else {
    songs <- tables[[1]] %>%
      rename(number = 1, # use location because sometimes issue with name on Wikipedia
             title = 2,
             artist = 3) %>%
      mutate(year = year,
             title = gsub('"', "", title)) %>%
      mutate(artist_clean = sub(' feat.*','', artist)) %>% # remove all featuring artists
      mutate(artist_clean = sub(',.*', '', artist_clean)) %>% # remove all collaborators
      mutate(artist_clean = sub(' &.*', '', artist_clean)) %>%
      mutate(artist_clean = sub(' with.*', '', artist_clean)) %>%
      mutate(artist_clean = sub(' and.*', '', artist_clean)) -> songs
  }
  
  return(songs)
  
}




############### Billboard Top Songs of the Year - All Years ####################
#' Get the song rank, artist, and title for all end-of-year Billboard rankings
#' Pulls data from Wikipedia (so subject to change)
#'
#' @param from_year (int) The four digit desired beginning year of data (1946 earliest)
#' @param to_year (int) The four digit desired ending year of data
#' 
#' @return A dataframe with final song rank (number), artists (artist), 
#' song title (title), year (year), and lead artist (artist_clean)
#'
#' @example get_all_top_100(from_year=1946, to_year=2020)
#' 

get_all_top_100 <- function(from=from_year, to=to_year) {
  
  # create empty list to hold incoming data
  dfList <- list()
  
  # run get_top_100 function for every year in a range of years
  for (i in seq(from=from_year, to=to_year, by=1)) {
    get_top_100(i) -> top_100
    dfList[[i]] = top_100
    Sys.sleep(.5)
  }
  
  # bind the rows of the gathered list into a tidy dataframe
  top_100_df = do.call(rbind, c(dfList, make.row.names = FALSE))
  
  return(top_100_df)
  
}


