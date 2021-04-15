
Available Data
-----------------------

Data dictionaries for the attached datasets are presented below.

### billboard_country.csv

A dataset of the Billboard Top 100 Country songs at the end of the year. Data are scraped from Billboard.com and represent 2002-2020.

| Column Name | Data Type | Description | Range |
|-------------|-----------|-----------|-------------|
| `Rank` | Integer | End-of-year rank out of 100 on Billboard.com Country music charts |  1 to 100 |
| `Artist` | String | Name of artist or artists | a thousand horses to zac brown band featuring jimmy buffett  |
| `Track` | String | Title of song | 'til summer comes around to yours if you want it |
| `Year` | Integer | Four digit integer of the year chart represents | 2002 to 2020 |

### country_top_100.csv

A dataset matching track data from Spotify and lyric data from Genius Lyrics to the Billboard Top 100 Country songs for 2002-2020.

| Column Name | Data Type | Description |
|-------------|-----------|-----------|-------------|
| `rank` | Integer | Rank of song | 
| `year` | Integer | Four digit year of ranking |
| `artist` | String | Name of artist (complete set of listed artists) |
| `first_artist` | String | Name of artist (first name on a track) | 
| `track_billboard` | String | Name of song on Billboard |
| `track_spotify` | String | Name of song on Spotify | 
| `track_number` | Integer | Position of song on album |
| `disc_number` | Integer | Position of disc in album | 
| `album_name` | String | Name of album |  
| `album_type` | String | Format of the track | 
| `artist_id` | String | Unique id of artist |
| `track_id` | String | Unique id of track |  
| `album_release_date` | Date | Release date of album (YYYY-MM-DD) or (YYYY) |  
| `album_release_year` | Integer | Release year of album (YYYY) |  
| `duration_ms` | Numeric | Length of song, in milliseconds | 
| `danceability` | Numeric | -- |  
| `energy` | Numeric | -- ) |  
| `key` | Integer | Numeric code for key song is performed in |  
| `key_name` | String | Character value of key song is performed in | 
| `key_mode` | String | Character value of key mode song is performed in | 
| `mode` | Integer | Numeric code for mode song is performed in | 
| `mode_name` | String | Character value of mode song is performed in |  
| `time_signature` | Integer | Interval of time song is performed in |  
| `loudness` | Numeric | -- |  
| `speechiness` | Numeric | -- |  
| `acousticness` | Numeric | -- | 
| `instrumentalness` | Numeric | -- |  
| `liveness` | Numeric | -- |  
| `valence` | Numeric | -- | 
| `tempo` | Numeric | -- |  
| `lyrics` | String | Full lyrics from Genius Lyrics |  
