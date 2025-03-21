import requests
from model.llm_wrapper.services.meteoblue_model import MeteoblueQuery
from datetime import datetime, timedelta
import os


def fetch_soil_data(latitude, longitude):
    """
    Input arguments: latitude, longitude
    Output dictionary: {
        "soil_moisture": float,
        "soil_ph": float,
        "soil_nitrogen_content": float
    }
    """
    query = MeteoblueQuery()
    query.set_coordinates(latitude=latitude, longitude=longitude)
    query.set_time_interval(
        start=datetime.now() - timedelta(days=1), end=datetime.now()
    )
    query.add_query(
        domain="SOILGRIDS1000",
        gap_fill_domain="NEMSGLOBAL",
        time_resolution="static",
        code_dict={"code": 800, "level": "0 cm"},
    )
    query.add_query(
        domain="SOILGRIDS",
        gap_fill_domain="NEMSGLOBAL",
        time_resolution="static",
        code_dict={
            "code": 812,
            "level": "aggregated",
            "startDepth": 0,
            "endDepth": 150,
        },
    )
    query.add_query(
        domain="SOILGRIDS2",
        gap_fill_domain="SOILGRIDS2_1000",
        time_resolution="static",
        code_dict={
            "code": 817,
            "level": "aggregated",
            "startDepth": 0,
            "endDepth": 150,
        },
    )
    response = get_query(query)
    parsed = {
        "soil_moisture": response[0]["codes"][0]["dataPerTimeInterval"][0]["data"][0][
            0
        ],
        "soil_ph": response[1]["codes"][0]["dataPerTimeInterval"][0]["data"][0][0],
        "soil_nitrogen_content": response[2]["codes"][0]["dataPerTimeInterval"][0][
            "data"
        ][0][0],
    }
    return parsed


def get_query(query):
    response = requests.post(
        url=f"https://my.meteoblue.com/dataset/query?apikey={os.getenv('HISTORICAL_API_KEY')}",
        json=query.body,
        headers={"Content-Type": "application/json"},
    )
    return response.json()
