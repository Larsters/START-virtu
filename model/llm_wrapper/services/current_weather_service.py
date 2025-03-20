import requests
import json
from datetime import datetime, timedelta
import os

session = requests.Session()
headers = {"Accept": "application/json"}
url = "https://services.cehub.syngenta-ais.com/api"
api_key = os.getenv('HISTORICAL_API_KEY')


def get_current_weather(latitude, longitude):
    current_time = datetime.now()
    end_time = current_time + timedelta(minutes=15)

    response = session.get(
        f"{url}/Forecast/Nowcast"
        f"?latitude={latitude}"
        f"&longitude={longitude}"
        f"&startDate={current_time}"
        f"&endDate={end_time}"
        f"&apikey={api_key}"
        f"&supplier=Meteoblue",
        headers=headers,
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
