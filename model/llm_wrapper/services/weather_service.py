import requests
import datetime

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

def get_short_range_forecast(latitude, longitude):
    """
    Calls /api/Forecast/ShortRangeForecastDaily 
    Returns daily forecast data for the next ~7-14 days
    """
    # parse, transform, return structured data
    pass

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