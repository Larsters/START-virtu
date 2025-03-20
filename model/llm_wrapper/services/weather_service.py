import requests
import datetime

"""
SHould return a list of daily records  { 'tmax', 'tmin', 'date' }
"""

def fetch_historical_weather(latitude, longitude, start_date, end_date):

    results = []
    return results