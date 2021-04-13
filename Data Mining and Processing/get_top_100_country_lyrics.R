# get lyrics data from Genius.com for billboard top 100 songs of the year (2002-2020)

library(geniusr)

# log into Genius Lyrics API
dw <- config::get("datawarehouse_music")
Sys.setenv(GENIUS_API_TOKEN = dw$genius_api)
genius_token()

# read in top 100 dataset, gathered from custom Billboard scraping function (billboard_country_scraper.ipynb)
country <- read.csv('https://raw.githubusercontent.com/dhutexas/spotify/main/Data/billboard_country.csv',
                    stringsAsFactors = F)

complete_df <- read.csv('spotify_billboard.csv', stringsAsFactors = F)

################################################################
# Round One - Use Billboard Artist, Track Title to Pull Lyrics #
################################################################

# function to get lyrics from a dataframe where:
# second column = title, third column = artist name
# returns: track_title, line, lyric, artist, album
f = function(x, output) {
  tryCatch({

    # access element in first column
    title = x[3]
    # access element in second column
    artist_name = x[2]

    genius::genius_lyrics(artist = artist_name, song = title) %>%
      mutate(artist = x[2],
             rank = x[1],
             year = x[4])
  }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
}

# apply function (f) to each row (1) of the dataframe
new_df = apply(country, 1, f)

# bind the lyric rows to single row per song, then write to file
lyrics = do.call(rbind.data.frame, new_df)
write.csv(lyrics, 'lyrics_country.csv', row.names = F)


#######################################################################
# Round Two - Use Spotify Data with Cleaned Artist, Track Title Names #
#######################################################################

# use track_name from spotify to find lyric data
f = function(x, output) {
  tryCatch({
    
    # access element in first column
    title = x[4]
    # access element in second column
    artist_name = x[3]

    genius::genius_lyrics(artist = artist_name, song = title) %>%
      mutate(artist_names = x[3],
             rank = x[1],
             year = x[2])
  }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
}

# pull artist name and track name
complete_df %>%
  select(artist_name, track_name) -> lyrics_search_df

# apply function (f) to each row (1) of the dataframe
lyrics_df = apply(lyrics_search_df, 1, f)
# bind the lyric rows to single row per song, then write to file
lyrics = do.call(rbind.data.frame, lyrics_df)
write.csv(lyrics, 'lyrics_country_2.csv', row.names = F)

###########################################
# Merge Lyric Data into Composite Dataset #
###########################################

# read in lyrics data from genius lyrics and concatenate lyrics by song
lyrics_billboard <- read.csv('lyrics_country.csv', stringsAsFactors = FALSE) %>%
  mutate(year = as.character(year),
         rank = as.character(rank)) %>%
  group_by(track_title, artist, rank, year) %>% 
  mutate(track_lyrics = paste0(lyric, collapse = " ")) %>%
  select(rank, year, artist, track_title, track_lyrics) %>%
  mutate(artist = tolower(artist),
         track_title = tolower(track_title),
         track_lyrics = tolower(track_lyrics)) %>%
  ungroup() %>%
  distinct()

lyrics_spotify <- read.csv('lyrics_country_2.csv', stringsAsFactors = FALSE) %>%
  mutate(year = as.character(year),
         rank = as.character(rank)) %>%
  group_by(track_title, artist_names, rank, year) %>% 
  mutate(track_lyrics = paste0(lyric, collapse = " ")) %>%
  select(rank, year, artist_names, track_title, track_lyrics) %>%
  mutate(artist_names = tolower(artist_names),
         track_title = tolower(track_title),
         track_lyrics = tolower(track_lyrics)) %>%
  rename(artist = artist_names) %>%
  ungroup() %>%
  distinct()

# did we add anything new with the spotify search?
# yep, now almost a complete set of lyrics 1504 of 1537 songs
lyrics_df <- bind_rows(lyrics_billboard, lyrics_spotify) %>%
  distinct() 

# write official lyrics dataframe to file
write.csv(lyrics_df, 'country_lyrics.csv', row.names = FALSE)


################################
# Join All Three Datasets #
################################

# join the data we have thus far
country_df <- complete_df %>%
  mutate(Year = as.character(Year),
         Rank = as.character(Rank)) %>%
  left_join(lyrics_df, by = c('Rank' = 'rank',
                              'Year' = 'year')) %>%
  select(-c(artist, track_title)) %>%
  distinct()

# missing only 71 song lyrics
country_df %>%
  filter(is.na(track_lyrics)) %>%
  select(Artist, artist_name, Track, album_name) -> missing_lyrics

missing_lyrics %>%
  select(artist_name, Track) -> missing_lyrics_search

# fill in missing artist info in search df
missing_lyrics_search %>%
  filter(is.na(artist_name)) %>%
  left_join(missing_lyrics) %>%
  select(-c(artist_name, album_name)) %>%
  rename(artist_name = Artist) %>%
  select(Rank, Year, artist_name, Track) -> little_search_df

# fix names to aid in matching
missing_lyrics_search %>%
  filter(!is.na(artist_name)) %>%
  rbind(little_search_df) %>%
  mutate(artist_name = gsub('dan and shay', 'dan-shay', artist_name)) %>%
  mutate(artist_name = gsub(' featuring.*', '', artist_name)) %>%
  mutate(artist_name = gsub(' presents.*', '', artist_name)) %>%
  mutate(artist_name = gsub('  .*', '', artist_name)) -> big_search_df


# apply lyrics search function again to modified list of missing songs
missing_lyrics_df_2 = apply(big_search_df, 1, f)

# bind the lyric rows to single row per song, then write to file
lyrics_missing = do.call(rbind.data.frame, missing_lyrics_df_2)

# read in lyrics data from genius lyrics and concatenate lyrics by song
lyrics_missing %<>%
  mutate(year = as.character(year),
         rank = as.character(rank)) %>%
  group_by(track_title, artist_names, rank, year) %>% 
  mutate(track_lyrics = paste0(lyric, collapse = " ")) %>%
  select(rank, year, artist_names, track_title, track_lyrics) %>%
  mutate(artist_names = tolower(artist_names),
         track_title = tolower(track_title),
         track_lyrics = tolower(track_lyrics)) %>%
  rename(artist = artist_names) %>%
  ungroup() %>%
  distinct() %>%
  select(-c(artist, track_title))

# join the data we have thus far
country_df %<>%
  left_join(lyrics_missing, by = c('Rank' = 'rank',
                                   'Year' = 'year'
  )) %>%
  # join lyrics separately, then coalesce the columns together as assured each are unique
  mutate(lyrics = coalesce(track_lyrics.x, track_lyrics.y)) %>%
  select(-c(track_lyrics.x, track_lyrics.y)) %>%
  janitor::clean_names() %>%
  rename(first_artist = artist_name,
         track_billboard = track,
         track_spotify = track_name)

# remove last of the duplicate songs
country_df %<>%
  group_by(rank, year) %>%
  # choose first observation (lowest row value) as this has best match on song
  slice_min(rank, n=1, with_ties=FALSE)

# ensure no duplicates
country_df %>%
  group_by(rank, year) %>%
  summarise(count = n()) %>%
  filter(count > 1)


# what is missing in lyrics? - only 12
country_df %>%
  filter(is.na(lyrics)) %>%
  select(artist, first_artist, track_billboard) 

# what is missing in spotify? - only 29
country_df %>%
  filter(is.na(danceability)) %>%
  select(artist, first_artist, track_billboard) 

# write final dataset to file
#write.csv(country_df, 'country_top_100.csv', row.names = FALSE)

