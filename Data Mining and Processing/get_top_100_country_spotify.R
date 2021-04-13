# get spotify data for billboard top 100 songs of the year (2002-2020)

library(tidyverse)
library(magrittr)

#################################
# Get List of Songs and Artists #
#################################

# read in top 100 dataset, gathered from custom Billboard scraping function (billboard_country_scraper.ipynb)
country <- read.csv('https://raw.githubusercontent.com/dhutexas/spotify/main/Data/billboard_country.csv',
                    stringsAsFactors = F)

# what songs do we need data for? (1323 tracks)
country %>%
  select(Track) %>%
  unique() %>%
  pull() -> tracks

# what artists do we need data for? (229 artists) - tidy names for searching
country %>%
  select(Artist) %>%
  mutate(artist_clean = sub(' & .*', '', Artist)) %>%
  mutate(artist_clean = sub(' featuring.*', '', artist_clean)) %>%
  mutate(artist_clean = sub(' with.*', '', artist_clean)) %>%
  mutate(artist_clean = sub(' x .*', '', artist_clean)) %>%
  mutate(artist_clean = sub(' and .*', '', artist_clean)) %>%
  mutate(artist_clean = sub(' duet.*', '', artist_clean)) %>%
  mutate(artist_clean = sub(' presents.*', '', artist_clean)) %>%
  mutate(artist_clean = sub(' \\+ lindsay ell', '', artist_clean)) %>%
  mutate(artist_clean = gsub('^big$', 'big & rich', artist_clean)) %>%
  mutate(artist_clean = gsub('^maddie$', 'maddie & tae', artist_clean)) %>%
  mutate(artist_clean = gsub('^brooks$', 'garth brooks', artist_clean)) %>%
  select(artist_clean) %>%
  unique() %>%
  pull() -> artists


################################
# Get Artist Info from Spotify #
################################

library(spotifyr)

# log into spotify API
dw <- config::get("datawarehouse_music")
Sys.setenv(SPOTIFY_CLIENT_ID = dw$spotify_id)
Sys.setenv(SPOTIFY_CLIENT_SECRET = dw$spotify_secret)
access_token <- get_spotify_access_token()

# custom function to grab all song data for each artist
get_artist_data <- function(artist_list) {
  
  dfList <- list()
  for (i in artist_list) {
    tryCatch({
      get_artist_audio_features(toString(i), 
                                include_groups = c('album','single','compilation'),
                                dedupe_albums = FALSE) -> artist_info
      dfList[[i]] = artist_info
      Sys.sleep(1)
    }, error=function(e){
      message(paste("No data available for artist: ", i))
    })
  }
  
  artist_df = do.call(rbind, c(dfList, make.row.names = FALSE))
  return(artist_df)
  
}

# run function over list of unique artists, save to file
artists_spotify = get_artist_data(artists)

# two common artists not found in original search, added now
search_spotify(q='niko moon', type = 'artist')

# artist ids for common, but missing, artists to add to dataframe
cam = '5WRElKaZsn1tGnrgmJVAeO'
niko = '6Rw7DRa1dzChBvxGPCpOxU'

cam = get_artist_audio_features(cam, 
                                include_groups = c('album','single','compilation'),
                                dedupe_albums = FALSE)

niko = get_artist_audio_features(niko, 
                                 include_groups = c('album','single','compilation'),
                                 dedupe_albums = FALSE)

# bind dataframes, save to file
spotify = bind_rows(artists_spotify, cam, niko)
save(spotify, file = 'spotify_country_artists.Rda')

# load saved file (if already ran previously)
load('spotify_country_artists.Rda')


##################################
# Examine and Clean Spotify Data #
##################################

# remove all singles and compilations so start with just album releases
# and force to lowercase artist names and track names
spotify_clean <- spotify %>%
  #filter(album_type == 'album') %>%
  mutate(artist_name = tolower(artist_name),
         track_name = tolower(track_name)) 

# remove all live versions of songs and commentary versions
spotify_clean %<>%
  filter(!str_detect(track_name, ' - live')) %>%
  filter(!str_detect(track_name, ' - commentary')) %>%
  filter(!str_detect(track_name, ' - with intro')) %>%
  filter(!str_detect(track_name, ' - spotify interview')) %>%
  filter(!str_detect(track_name, 'spotify commentary'))

# when duplicate song and artist, use earliest date of release to keep
spotify_clean %<>%
  group_by(track_name, artist_name) %>%
  slice_min(album_release_date, n = 1)

# when still duplicates, match on artist, track, and release year, choose smallest id value
spotify_clean %<>%
  group_by(artist_name, track_name, album_release_year) %>%
  slice_min(track_id)

# remove any duplicates, in general
spotify_clean %<>%
  distinct()

# trim to rows of interest
spotify_variables = c('artist_name','track_name','track_number','disc_number','album_name','album_type',
                      'artist_id','track_id','album_release_date','album_release_year','duration_ms',
                      'danceability','energy','key','key_name','key_mode','mode','mode_name','time_signature',
                      'loudness','speechiness','acousticness','instrumentalness','liveness','valence','tempo')

spotify_clean %<>%
  select(all_of(spotify_variables))

# what artists are represented in the complete spotify dataset?
spotify_clean %>%
  ungroup() %>%
  select(artist_name) %>%
  unique() %>%
  pull() -> spotify_artists

# check for differences between artist lists
# really only missing Garth Brooks (who is not on Spotify anyway)
setdiff(artists, spotify_artists)

# write clean dataframe to file
#write.csv(spotify_clean, 'spotify_country.csv', row.names = F)


################################
# Merge Spotify with Billboard #
################################

# remove punctuation from track names in both datasets to ease string matching
spotify_clean %<>%
  mutate(track_name = str_replace_all(track_name, "[[:punct:]]", ""),
         artist_name = str_replace_all(artist_name, "[[:punct:]]", ""),
         artist_name = str_replace_all(artist_name, '\\+', 'and')) # for dan + shay

country %<>%
  mutate(Track = str_replace_all(Track, "[[:punct:]]", ""),
         Artist = str_replace_all(Artist, "[[:punct:]]", ""),
         Artist = str_replace_all(Artist, '\\+', 'and'))

# match part of song title string from billboard in spotify song name (often longer)
spotify_clean %>% 
  fuzzyjoin::regex_right_join(country, by = c(track_name = 'Track')) %>%
  select(Rank, Year, Artist, artist_name, Track, track_name, everything())-> spot_regex_first

# match some/all of artist_name within Artist column (to remove non-matching artists, but keep compilations)
spot_regex_first %>%
  rowwise() %>% 
  filter(grepl(artist_name, Artist)) -> spot_regex_second

# keep shortest track name
spot_regex_second %>%
  mutate(name_length = nchar(track_name)) %>%
  group_by(artist_name, Track) %>%
  # keep the shortest track length (by number of characters)
  slice(which.min(name_length)) %>%
  select(-name_length) -> nodupes

# make df of missing tracks and artists
country %>%
  left_join(nodupes) %>%
  filter(is.na(artist_name)) %>%
  select(Rank, Artist, Track, Year) -> missing_spotify


# are the missing songs in the larger dataset, but got dropped along the way?
# try a fuzzy join of track names against original clean spotify data
missing_spotify %>%
  fuzzyjoin::regex_left_join(spotify_clean, by = c(Track = 'track_name')) %>%
  filter(!is.na(artist_id)) %>%
  # drop non-matching artists
  rowwise() %>% 
  filter(grepl(artist_name, Artist)) -> rejoin_df_fuzzy

# add these tracks to the ongoing dataframe
complete_df <- bind_rows(nodupes, rejoin_df_fuzzy)

# some multi-artist songs have both of them, can just keep first one (lower row value)
complete_df %<>%
  group_by(Rank, Year) %>%
  slice_min(artist_name)

# what is still missing in the end? Hopefully just Garth Brooks ;P
# only 29 still missing out of 1537
country %>%
  left_join(complete_df) %>%
  filter(is.na(artist_id)) -> still_missing_df

complete_df %<>%
  right_join(country)

write.csv(complete_df, 'spotify_billboard.csv', row.names=FALSE)
