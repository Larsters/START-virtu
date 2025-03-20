import requests
import datetime
from dotenv import load_dotenv
import os

API_KEY = os.getenv('WEATHER_API_KEY', 'd4f087c7-7efc-41b4-9292-0f22b6199215')
API_BASE_URL = "https://services.cehub.syngenta-ais.com"

load_dotenv()

def fetch_weather_data(latitude, longitude, request_type, start_date=None, end_date=None):
    """
    request_type can be 'short_range_forecast', 'historical', 'heat_stress', etc.
    Agent decides which endpoint(s) to call based on user request or LLM function call.
    """
    if request_type == "short_range_forecast":
        return get_short_range_forecast(latitude, longitude)
    elif request_type == "historical":
        return get_historical_data_meteoblue(latitude, longitude, start_date, end_date)
    elif request_type == "heat_stress":
        return get_heat_stress_index(latitude, longitude, start_date, end_date)
    else:
        raise ValueError(f"Unknown request_type: {request_type}")

def get_short_range_forecast(latitude, longitude, days=3):
    """
    Fetch short range daily forecast from the API.
    
    Args:
        latitude (float): Location latitude
        longitude (float): Location longitude
        days (int): Number of forecast days (default: 3)
    
    Returns:
        list: Daily forecast data for the specified period
    """
    # Prepare dates for the API request
    today = datetime.datetime.now()
    end_date = today + datetime.timedelta(days=days)
    
    # Format dates as strings
    start_date_str = today.strftime('%Y-%m-%d')
    end_date_str = end_date.strftime('%Y-%m-%d')
    
    # API endpoint
    endpoint = f"{API_BASE_URL}/api/Forecast/ShortRangeForecastDaily"
    
    # Request parameters
    params = {
        "latitude": latitude,
        "longitude": longitude,
        "startDate": start_date_str,
        "endDate": end_date_str,
        "unit": "SI"  # Standard International units
    }
    
    # Headers with API key
    headers = {
        "ApiKey": API_KEY,
        "accept": "*/*"
    }
    
    try:
        response = requests.get(endpoint, params=params, headers=headers)
        response.raise_for_status()  # Raise exception for HTTP errors
        
        data = response.json()
        
        # Transform data into a more usable format
        daily_forecast = []
        
        if "data" in data and isinstance(data["data"], list):
            for day_data in data["data"]:
                # Extract relevant data for each day
                daily_record = {
                    "date": day_data.get("date"),
                    "tmax": day_data.get("tmax"),
                    "tmin": day_data.get("tmin"),
                    "tavg": day_data.get("tavg"),
                    "precipitation": day_data.get("precip_sum"),
                    "humidity": day_data.get("rh_avg"),
                    "wind_speed": day_data.get("wind_speed"),
                    "wind_direction": day_data.get("wind_direction")
                }
                daily_forecast.append(daily_record)
        
        return daily_forecast
        
    except requests.exceptions.RequestException as e:
        print(f"Error fetching short range forecast: {e}")
        return []

def get_heat_stress_index(latitude, longitude, start_date, end_date):
    """
    Calls /api/QuantisV2/GetHeatStress
    Possibly a specialized endpoint returning a daily heat stress score
    """
    pass

def get_historical_data_meteoblue(latitude, longitude, start_date, end_date):
    """
    Calls the meteoblue History API to retrieve historical weather 
    (TMAX, TMIN, rainfall, etc.) for the specified date range
    """
    pass

def calculate_gdd_from_weather(daily_data, base_temp):
    """
      - daily_data is a list of { date, TMAX, TMIN, ... }
      - base_temp is the threshold for that crop
    """
    total_gdd = 0
    for day in daily_data:
        avg_temp = (day["TMAX"] + day["TMIN"]) / 2
        daily_gdd = avg_temp - base_temp
        if daily_gdd < 0:
            daily_gdd = 0
        total_gdd += daily_gdd
    return round(total_gdd, 2)