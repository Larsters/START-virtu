import requests
import json
from datetime import datetime, timedelta
import os

from .meteoblue_model import MeteoblueQuery

url_cehub = "https://services.cehub.syngenta-ais.com/api"
url_meteoblue = "https://my.meteoblue.com/dataset/query?apikey"

def get_current_weather(latitude, longitude):
    current_time = datetime.now()
    end_time = current_time + timedelta(minutes=120)

    response = requests.get(
        f"{url_cehub}/Forecast/Nowcast"
        f"?latitude={latitude}"
        f"&longitude={longitude}"
        f"&startDate={current_time}"
        f"&endDate={end_time}"
        f"&apikey={os.getenv('WEATHER_API_KEY')}"
        f"&supplier=Meteoblue",
        headers={"Accept": "application/json"},
    )

    parsed = json.loads(response.content)

    data = {"latitude": parsed[0]["latitude"], "longitude": parsed[0]["longitude"]}

    for entry in parsed:
        match entry["measureLabel"]:
            case "Temperature_15Min (C)":
                data["temperature"] = entry["value"]
            case "TempAirFelt_15Min (C)":
                data["temperature_felt"] = entry["value"]
            case "WindSpeed_15Min (m/s)":
                data["wind_speed"] = entry["value"]
            case "WindDirection_15Min":
                data["wind_direction"] = entry["value"]
            case "HumidityRel_15Min (pct)":
                data["humidity"] = entry["value"]
            case "Airpressure_15Min (hPa)":
                data["air_pressure"] = entry["value"]

    return data

def get_historical_weather_year_ago(latitude, longitude):
    """
    Retrieves weather data from one year ago for the given coordinates.
    
    Args:
        latitude (float): Latitude coordinate
        longitude (float): Longitude coordinate
        
    Returns:
        dict: Weather data including temperature, humidity, etc.
    """
    current_time = datetime.now()
    one_year_ago = current_time.replace(year=current_time.year - 1)
    
    # Set time range for one year ago (start and end dates)
    start_time = one_year_ago - timedelta(days=3)
    end_time = one_year_ago + timedelta(days=3)
    
    # Initialize data with coordinates
    data = {"latitude": latitude, "longitude": longitude}
    
    # Get API key from environment variable
    api_key = os.getenv('HISTORICAL_API_KEY')
    if not api_key:
        print("WARNING: Missing HISTORICAL_API_KEY environment variable")
        return data
    
    try:
        # Use the MeteoblueQuery class, similar to soil_service.py
        query = MeteoblueQuery()
        query.set_coordinates(latitude=latitude, longitude=longitude)
        query.set_time_interval(start=start_time, end=end_time)
        
        # Add queries for temperature, humidity, wind, etc.
        # Temperature
        query.add_query(
            domain="NEMSGLOBAL",
            gap_fill_domain=None,
            time_resolution="hourly",
            code_dict={"code": 11, "level": "2 m above gnd"}
        )
        
        # Relative Humidity
        query.add_query(
            domain="NEMSGLOBAL",
            gap_fill_domain=None,
            time_resolution="hourly",
            code_dict={"code": 52, "level": "2 m above gnd"}
        )
        
        # Wind Speed
        query.add_query(
            domain="NEMSGLOBAL",
            gap_fill_domain=None,
            time_resolution="hourly",
            code_dict={"code": 32, "level": "10 m above gnd"}
        )
        
        # Wind Direction
        query.add_query(
            domain="NEMSGLOBAL",
            gap_fill_domain=None,
            time_resolution="hourly",
            code_dict={"code": 31, "level": "10 m above gnd"}
        )
        
        # Precipitation
        query.add_query(
            domain="NEMSGLOBAL",
            gap_fill_domain=None,
            time_resolution="hourly",
            code_dict={"code": 61, "level": "sfc"}
        )
        
        response = requests.post(
            url=f"https://my.meteoblue.com/dataset/query?apikey={api_key}",
            json=query.body,
            headers={"Content-Type": "application/json"},
        )
        
        if response.status_code != 200:
            print(f"API Error: Status code {response.status_code}")
            print(f"Response: {response.text}")
            return data
        
        # Parse the response
        parsed_data = response.json()
        
        if isinstance(parsed_data, list) and len(parsed_data) >= 5:
            try:
                # Temperature (index 0)
                if parsed_data[0]["codes"][0]["dataPerTimeInterval"][0]["data"]:
                    data["temperature"] = parsed_data[0]["codes"][0]["dataPerTimeInterval"][0]["data"][0][0]
                
                # Humidity (index 1)
                if parsed_data[1]["codes"][0]["dataPerTimeInterval"][0]["data"]:
                    data["humidity"] = parsed_data[1]["codes"][0]["dataPerTimeInterval"][0]["data"][0][0]
                
                # Wind Speed (index 2)
                if parsed_data[2]["codes"][0]["dataPerTimeInterval"][0]["data"]:
                    data["wind_speed"] = parsed_data[2]["codes"][0]["dataPerTimeInterval"][0]["data"][0][0]
                
                # Wind Direction (index 3)
                if parsed_data[3]["codes"][0]["dataPerTimeInterval"][0]["data"]:
                    data["wind_direction"] = parsed_data[3]["codes"][0]["dataPerTimeInterval"][0]["data"][0][0]
                
                # Precipitation (index 4)
                if parsed_data[4]["codes"][0]["dataPerTimeInterval"][0]["data"]:
                    data["precipitation"] = parsed_data[4]["codes"][0]["dataPerTimeInterval"][0]["data"][0][0]
            except (IndexError, KeyError) as e:
                print(f"Error extracting data from response: {e}")
                print(f"Response structure: {parsed_data[:100]}...")
        
    except requests.RequestException as e:
        print(f"Request error: {e}")
    except json.JSONDecodeError as e:
        print(f"JSON parsing error: {e}")
    except Exception as e:
        print(f"Unexpected error: {e}")
    
    return data


def get_historical_weather_two_year_ago(latitude, longitude):
    """
    Retrieves weather data from one year ago for the given coordinates.
    
    Args:
        latitude (float): Latitude coordinate
        longitude (float): Longitude coordinate
        
    Returns:
        dict: Weather data including temperature, humidity, etc.
    """
    current_time = datetime.now()
    one_year_ago = current_time.replace(year=current_time.year - 2)
    
    # Set time range for one year ago (start and end dates)
    start_time = one_year_ago - timedelta(days=3)
    end_time = one_year_ago + timedelta(days=3)
    
    # Initialize data with coordinates
    data = {"latitude": latitude, "longitude": longitude}
    
    # Get API key from environment variable
    api_key = os.getenv('HISTORICAL_API_KEY')
    if not api_key:
        print("WARNING: Missing HISTORICAL_API_KEY environment variable")
        return data
    
    try:
        # Use the MeteoblueQuery class, similar to soil_service.py
        query = MeteoblueQuery()
        query.set_coordinates(latitude=latitude, longitude=longitude)
        query.set_time_interval(start=start_time, end=end_time)
        
        # Add queries for temperature, humidity, wind, etc.
        # Temperature
        query.add_query(
            domain="NEMSGLOBAL",
            gap_fill_domain=None,
            time_resolution="hourly",
            code_dict={"code": 11, "level": "2 m above gnd"}
        )
        
        # Relative Humidity
        query.add_query(
            domain="NEMSGLOBAL",
            gap_fill_domain=None,
            time_resolution="hourly",
            code_dict={"code": 52, "level": "2 m above gnd"}
        )
        
        # Wind Speed
        query.add_query(
            domain="NEMSGLOBAL",
            gap_fill_domain=None,
            time_resolution="hourly",
            code_dict={"code": 32, "level": "10 m above gnd"}
        )
        
        # Wind Direction
        query.add_query(
            domain="NEMSGLOBAL",
            gap_fill_domain=None,
            time_resolution="hourly",
            code_dict={"code": 31, "level": "10 m above gnd"}
        )
        
        # Precipitation
        query.add_query(
            domain="NEMSGLOBAL",
            gap_fill_domain=None,
            time_resolution="hourly",
            code_dict={"code": 61, "level": "sfc"}
        )
        
        response = requests.post(
            url=f"https://my.meteoblue.com/dataset/query?apikey={api_key}",
            json=query.body,
            headers={"Content-Type": "application/json"},
        )
        
        if response.status_code != 200:
            print(f"API Error: Status code {response.status_code}")
            print(f"Response: {response.text}")
            return data
        
        # Parse the response
        parsed_data = response.json()
        
        if isinstance(parsed_data, list) and len(parsed_data) >= 5:
            try:
                # Temperature (index 0)
                if parsed_data[0]["codes"][0]["dataPerTimeInterval"][0]["data"]:
                    data["temperature"] = parsed_data[0]["codes"][0]["dataPerTimeInterval"][0]["data"][0][0]
                
                # Humidity (index 1)
                if parsed_data[1]["codes"][0]["dataPerTimeInterval"][0]["data"]:
                    data["humidity"] = parsed_data[1]["codes"][0]["dataPerTimeInterval"][0]["data"][0][0]
                
                # Wind Speed (index 2)
                if parsed_data[2]["codes"][0]["dataPerTimeInterval"][0]["data"]:
                    data["wind_speed"] = parsed_data[2]["codes"][0]["dataPerTimeInterval"][0]["data"][0][0]
                
                # Wind Direction (index 3)
                if parsed_data[3]["codes"][0]["dataPerTimeInterval"][0]["data"]:
                    data["wind_direction"] = parsed_data[3]["codes"][0]["dataPerTimeInterval"][0]["data"][0][0]
                
                # Precipitation (index 4)
                if parsed_data[4]["codes"][0]["dataPerTimeInterval"][0]["data"]:
                    data["precipitation"] = parsed_data[4]["codes"][0]["dataPerTimeInterval"][0]["data"][0][0]
            except (IndexError, KeyError) as e:
                print(f"Error extracting data from response: {e}")
                print(f"Response structure: {parsed_data[:100]}...")
        
    except requests.RequestException as e:
        print(f"Request error: {e}")
    except json.JSONDecodeError as e:
        print(f"JSON parsing error: {e}")
    except Exception as e:
        print(f"Unexpected error: {e}")
    
    return data
