import requests
import json
from config import config
from datetime import datetime, timedelta


session = requests.Session()
headers = {"Accept": "application/json"}
url = config.cehub_api_host


def get_current_weather(latitude, longitude, api_key=config.cehub_api_key):
    current_time = datetime.now()
    end_time = current_time + timedelta(minutes=15)

    response = session.get(
        f"{url}/Forecast/Nowcast"
        f"?latitude={latitude}"
        f"&longitude={longitude}"
        f"&startDate={current_time}"
        f"&endDate={end_time}"
        f"&apikey={config.cehub_api_key}"
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


def get_corn_risk(latitude, longitude):
    start_time = datetime.now()
    end_time = start_time + timedelta(days=1)
    response = session.get(
        f"{config.cehub_api_host}"
        f"/DiseaseRisk/CornRisk"
        f"?modelId=5"
        f"&latitude={latitude}"
        f"&longitude={longitude}"
        f"&startDate={start_time}"
        f"&endDate={end_time}"
        f"&apikey={config.cehub_api_key}"
    )
    parsed = json.loads(response.content)
    return parsed
