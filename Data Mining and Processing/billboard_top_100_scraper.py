"""Billboard Top 100 Scraper

This script allows the user to download a tidy dataframe of the top 100
country songs according to Billboard.com at the end of a single year.

"""

import lxml
from bs4 import BeautifulSoup
import pandas as pd
import requests as rq 

import re
import time

def get_top_country_songs(start_year, end_year):
    """Gets and prints the spreadsheet's header columns

    Parameters
    ----------
    year : int
        The four digit year of interest

    Returns
    -------
    df_top100
        a pandas dataframe of the Rank, Artist, Track, and Year
    """
    
    artists = []
    tracks = []
    rank = []
    chart_year = []
    
    for year in range(start_year, end_year+1):
        
        url = 'https://www.billboard.com/charts/year-end/' + str(year) + '/hot-country-songs'
        page = rq.get(url, timeout = 5).text
        soup = BeautifulSoup(page, 'lxml')

        for i in soup.find_all('div', {'class': 'ye-chart-item__artist'}):
            artists.append(i.text.strip())

        for i in soup.find_all('div', {'class': 'ye-chart-item__title'}):
            tracks.append(i.text.strip())

        for i in soup.find_all('div', {'class': 'ye-chart-item__rank'}):
            rank.append(i.text.strip())
            
        # use object counter to append year to ongoing list
        for i in soup.find_all('div', {'class': 'ye-chart-item__rank'}):
            chart_year.append(year)
        

    df_top100 = pd.DataFrame(list(zip(rank, artists, tracks, chart_year)), 
                       columns =['Rank', 'Artist', 'Track','Year'])

    return df_top100