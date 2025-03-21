from model.llm_wrapper.services.meteoblue_model import MeteoblueQuery
import requests
from datetime import datetime, timedelta
from model.llm_wrapper.services.soil_service import fetch_soil_data
from statistics import fmean
import os


def get_daytime_heat_stress_risk(latitude, longitude, crop_type):
    t_max = get_daily_maximum_temperature(latitude, longitude)
    t_max_optimum, t_max_limit = get_daytime_optimum_limit_temperature_by_crop(
        crop_type
    )

    if t_max <= t_max_optimum:
        return 0
    if t_max >= t_max_limit:
        return 9
    return 9 * (t_max - t_max_optimum) / (t_max_limit - t_max_optimum)


def get_nighttime_heat_stress_risk(latitude, longitude, crop_type):
    t_min = get_daily_minimum_temperature(latitude=latitude, longitude=longitude)
    t_min_optimum, t_min_limit = get_nighttime_optimum_limit_temperature_by_crop(
        crop_type
    )

    if t_min < t_min_optimum:
        return 0
    if t_min > t_min_limit:
        return 9
    return 9 * (t_min - t_min_optimum) / (t_min_limit - t_min_optimum)


def get_frost_stress(latitude, longitude, crop_type):
    t_min = get_daily_minimum_temperature(latitude=latitude, longitude=longitude)
    t_min_no_frost, t_min_frost = get_frost_minimum_temperatures_by_crop(crop_type)
    if t_min >= t_min_no_frost:
        return 0
    if t_min <= t_min_frost:
        return 9
    return 9 * abs(t_min - t_min_frost) / abs(t_min_frost - t_min_no_frost)


def get_drought_risk(latitude, longitude):
    start = datetime.now() - timedelta(days=90)
    end = datetime.now()

    cumulative_rainfall = get_cumulative_rainfall(latitude, longitude, start, end)
    cumulative_evaporation = get_cumulative_evaporation(latitude, longitude, start, end)
    soil_moisture = get_soil_moisture(latitude, longitude)
    average_temperature = get_average_temperature(latitude, longitude, start, end)

    drought_index = (
        cumulative_rainfall - cumulative_evaporation
    ) + soil_moisture / average_temperature
    return drought_index


def get_yield_risk(latitude, longitude, crop_type, start=datetime.now() - timedelta(days=90), end=datetime.now()):
    growing_degree_days = get_growing_degree_days(latitude, longitude, start, end)
    cumulative_rainfall = get_cumulative_rainfall(latitude, longitude, start, end)
    soil_ph = get_soil_ph(latitude, longitude)
    soil_nitrogen = get_soil_nitrogen(latitude, longitude)
    (
        optimal_growing_degree_days,
        optimal_rainfall,
        optimal_soil_ph,
        optimal_soil_nitrogen,
    ) = get_yield_risk_optimal_numbers(crop_type=crop_type)

    w1, w2, w3, w4 = 0.3, 0.3, 0.2, 0.2

    yield_risk = abs(
        w1 * (growing_degree_days - optimal_growing_degree_days) * 2
        + w2 * (cumulative_rainfall - optimal_rainfall) * 2
        + w3 * (soil_ph - optimal_soil_ph) * 2
        + w4 * (soil_nitrogen - optimal_soil_nitrogen) * 2
    )
    return yield_risk


def get_frost_minimum_temperatures_by_crop(crop_type):
    """
    Returns touple (t_min_no_frost, t_min_frost
    """
    match crop_type:
        case "soybean":
            return 4, -3
        case "corn":
            return 4, -3
        case "cotton":
            return 4, -3


def get_yield_risk_optimal_numbers(crop_type):
    """
    Returns touple (optimal_growing_degree_days, optimal_rainfall, optimal_soil_ph, optimal_soil_nitrogen)
    """
    match crop_type:
        case "soybean":
            return 2700, 575, 6.4, 0.013
        case "corn":
            return 2900, 650, 6.4, 0.115
        case "cotton":
            return 2400, 1000, 6.3, 0.072


def get_soil_ph(latitude, longitude):
    response = fetch_soil_data(latitude, longitude)
    return response["soil_ph"]


def get_soil_nitrogen(latitude, longitude):
    response = fetch_soil_data(latitude, longitude)
    return response["soil_nitrogen_content"]


def get_growing_degree_days(latitude, longitude, start, end):
    query = MeteoblueQuery()
    query.set_coordinates(latitude=latitude, longitude=longitude)
    query.set_time_interval(start=start, end=end)
    query.add_query(
        domain="ERA5T",
        gap_fill_domain=None,
        time_resolution="daily",
        code_dict={
            "code": 730,
            "level": "2 m above gnd",
            "aggregation": "sum",
            "gddBase": 8,
            "gddLimit": 30,
        },
    )
    response = get_query(query)
    return sum(
        filter(None, response[0]["codes"][0]["dataPerTimeInterval"][0]["data"][0])
    )


def get_average_temperature(latitude, longitude, start, end):
    query = MeteoblueQuery()
    query.set_coordinates(latitude=latitude, longitude=longitude)
    query.set_time_interval(start=start, end=end)
    query.add_query(
        domain="NEMSGLOBAL",
        gap_fill_domain=None,
        time_resolution="daily",
        code_dict={"code": 11, "level": "2 m above gnd", "aggregation": "mean"},
    )
    response = get_query(query)
    return fmean(response[0]["codes"][0]["dataPerTimeInterval"][0]["data"][0])


def get_cumulative_rainfall(latitude, longitude, start, end):
    """
    Returns cumulative rainfall over a time period in mm
    """
    query = MeteoblueQuery()
    query.set_coordinates(latitude=latitude, longitude=longitude)
    query.set_time_interval(start=start, end=end)
    query.add_query(
        domain="NEMSGLOBAL",
        gap_fill_domain=None,
        time_resolution="daily",
        code_dict={"code": 61, "level": "sfc", "aggregation": "sum"},
    )
    response = get_query(query)
    return sum(
        filter(None, response[0]["codes"][0]["dataPerTimeInterval"][0]["data"][0])
    )


def get_cumulative_evaporation(latitude, longitude, start, end):
    """
    Returns cumulative evaporation over a time period in mm
    """
    query = MeteoblueQuery()
    query.set_coordinates(latitude=latitude, longitude=longitude)
    query.set_time_interval(start=start, end=end)
    query.add_query(
        domain="NEMSGLOBAL",
        gap_fill_domain=None,
        time_resolution="daily",
        code_dict={"code": 261, "level": "sfc", "aggregation": "sum"},
    )
    response = get_query(query)
    return sum(response[0]["codes"][0]["dataPerTimeInterval"][0]["data"][0])


def get_soil_moisture(latitude, longitude):
    """
    Returns soil moisture in percentage
    """
    response = fetch_soil_data(latitude, longitude)
    return response["soil_moisture"]


def get_daily_maximum_temperature(latitude, longitude):
    query = MeteoblueQuery()
    query.set_coordinates(latitude=latitude, longitude=longitude)
    query.set_time_interval(
        start=datetime.now() - timedelta(hours=1), end=datetime.now()
    )
    query.add_query(
        domain="NEMSGLOBAL",
        gap_fill_domain=None,
        time_resolution="daily",
        code_dict={"code": 11, "level": "2 m above gnd", "aggregation": "max"},
    )
    response = get_query(query)
    return response[0]["codes"][0]["dataPerTimeInterval"][0]["data"][0][0]


def get_daily_minimum_temperature(latitude, longitude):
    query = MeteoblueQuery()
    query.set_coordinates(latitude=latitude, longitude=longitude)
    query.set_time_interval(
        start=datetime.now() - timedelta(hours=1), end=datetime.now()
    )
    query.add_query(
        domain="NEMSGLOBAL",
        gap_fill_domain=None,
        time_resolution="daily",
        code_dict={"code": 11, "level": "2 m above gnd", "aggregation": "min"},
    )
    response = get_query(query)
    return response[0]["codes"][0]["dataPerTimeInterval"][0]["data"][0][0]


def get_daytime_optimum_limit_temperature_by_crop(crop_type):
    """
    Returns tuple (t_max_optimum, t_max_limit)
    """
    match crop_type:
        case "soybean":
            return 32, 45
        case "corn":
            return 33, 44
        case "cotton":
            return 32, 38


def get_nighttime_optimum_limit_temperature_by_crop(crop_type):
    """
    Returns tuple (t_min_optimum, t_min_limit)
    """
    match crop_type:
        case "soybean":
            return 22, 28
        case "corn":
            return 22, 28
        case "cotton":
            return 20, 25


def get_query(query):
    response = requests.post(
        url=f"https://my.meteoblue.com/dataset/query?apikey={os.getenv('HISTORICAL_API_KEY')}",
        json=query.body,
        headers={"Content-Type": "application/json"},
    )
    return response.json()
