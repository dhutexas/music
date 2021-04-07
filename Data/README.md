
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

| Column Name | Data Type | Description | Range |
|-------------|-----------|-----------|-------------|
| `artist_name` | String | Name of artist (first name on a track) |  a thousand horses to zac brown band |
| `track_name` | String | Name of song |  a thousand horses to zac brown band |
| `track_number` | Integer | Position of song on album |  a thousand horses to zac brown band |
| `disc_number` | Integer | Position of disc in album |  a thousand horses to zac brown band |
| `album_name` | String | Name of album |  a thousand horses to zac brown band |
| `album_type` | String | Format of the track |  album, compilation, single |
| `artist_id` | String | Unique id of artist |  a thousand horses to zac brown band |
| `track_id` | String | Unique id of track |  a thousand horses to zac brown band |
| `album_release_date` | Date | Release date of album (YYYY-MM-DD) or (YYYY) |  a thousand horses to zac brown band |
| `album_release_year` | Integer | Release year of album (YYYY) |  a thousand horses to zac brown band |
| `duration_ms` | Numeric | Length of song, in milliseconds |  a thousand horses to zac brown band |
| `danceability` | Numeric | -- |  a thousand horses to zac brown band |
| `energy` | Numeric | -- ) |  a thousand horses to zac brown band |
| `key` | Integer | Numeric code for key song is performed in |  a thousand horses to zac brown band |
| `key_name` | String | Character value of key song is performed in |  a thousand horses to zac brown band |
| `key_mode` | String | Character value of key mode song is performed in |  a thousand horses to zac brown band |
| `mode` | Integer | Numeric code for mode song is performed in |  a thousand horses to zac brown band |
| `mode_name` | String | Character value of mode song is performed in |  a thousand horses to zac brown band |
| `time_signature` | Integer | Interval of time song is performed in |  a thousand horses to zac brown band |
| `loudness` | Numeric | -- |  a thousand horses to zac brown band |
| `speechiness` | Numeric | -- |  a thousand horses to zac brown band |
| `acousticness` | Numeric | -- |  a thousand horses to zac brown band |
| `instrumentalness` | Numeric | -- |  a thousand horses to zac brown band |
| `liveness` | Numeric | -- |  a thousand horses to zac brown band |
| `valence` | Numeric | -- |  a thousand horses to zac brown band |
| `tempo` | Numeric | -- |  a thousand horses to zac brown band |
