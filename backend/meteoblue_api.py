import requests
from meteoblue_model import MeteoblueQuery
from datetime import datetime, timedelta
from config import config


# Maximum temperature from yesterday
def get_max_day_temperature(latitude, longitude):
    query = MeteoblueQuery()git
    query.set_coordinates(latitude=latitude, longitude=longitude)
    query.set_time_interval(
        start=datetime.now() - timedelta(days=1), end=datetime.now()
    )
    query.set_code(
        domain="NEMSGLOBAL",
        time_resolution="daily",
        code=11,
        level="2 m above gnd",
        aggregation="max",
    )
    response = get_query(query)
    return response


def get_query(query):
    print(query.body)
    response = requests.post(
        url=f"{config.meteoblue_api_host}/query?apikey={config.meteoblue_api_key}",
        json=query.body,
        headers={"Content-Type": "application/json"},
    )
    return response.json()
