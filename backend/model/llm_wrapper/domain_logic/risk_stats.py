from model.llm_wrapper.domain_logic.calculations import (
    get_daytime_heat_stress_risk,
    get_nighttime_heat_stress_risk,
    get_frost_stress,
    get_drought_risk,
    get_yield_risk,
)

OPTIMAL_DAYTIME_HEAT_STRESS_RISK = "0"
WORST_DAYTIME_HEAT_STRESS_RISK = "9"
OPTIMAL_NIGHTTIME_HEAT_STRESS_RISK = "0"
WORST_NIGHTTIME_HEAT_STRESS_RISK = "9"
OPTIMAL_FROST_STRESS = "0"
WORST_FROST_STRESS = "9"
OPTIMAL_DROUGHT_RISK = ">1"
WORST_DROUGHT_RISK = "<0"
OPTIMAL_YIELD_RISK = "0"
WORST_YIELD_RISK = ">1000"


def get_stats(latitude, longitude, crop_type):
    daytime_heat_stress_risk = round(
        get_daytime_heat_stress_risk(latitude, longitude, crop_type), 2
    )

    nighttime_heat_stress_risk = round(
        get_nighttime_heat_stress_risk(latitude, longitude, crop_type), 2
    )

    frost_stress = round(get_frost_stress(latitude, longitude, crop_type), 2)

    drought_risk = round(get_drought_risk(latitude, longitude), 2)

    yield_risk = round(get_yield_risk(latitude, longitude, crop_type), 2)

    stats = {
        "daytime_heat_stress_risk": [
            get_daytime_heat_stress_risk_level(daytime_heat_stress_risk),
            str(daytime_heat_stress_risk),
            OPTIMAL_DAYTIME_HEAT_STRESS_RISK,
            WORST_DAYTIME_HEAT_STRESS_RISK,
        ],
        "nighttime_heat_stress_risk": [
            get_nighttime_heat_stress_risk_level(nighttime_heat_stress_risk),
            str(nighttime_heat_stress_risk),
            OPTIMAL_NIGHTTIME_HEAT_STRESS_RISK,
            WORST_NIGHTTIME_HEAT_STRESS_RISK,
        ],
        "frost_stress": [
            get_frost_stress_risk_level(frost_stress),
            str(frost_stress),
            OPTIMAL_FROST_STRESS,
            WORST_FROST_STRESS,
        ],
        "drought_risk": [
            get_drought_risk_level(drought_risk),
            str(drought_risk),
            OPTIMAL_DROUGHT_RISK,
            WORST_DROUGHT_RISK,
        ],
        "yield_risk": [
            get_yield_risk_level(yield_risk),
            str(yield_risk),
            OPTIMAL_YIELD_RISK,
            WORST_YIELD_RISK,
        ],
    }

    stats["recommended_products"] = get_recommended_products(stats)

    return stats


def get_recommended_products(stats):
    recommended = []
    for key, value in stats.items():
        if key in [
            "daytime_heat_stress_risk",
            "nighttime_heat_stress_risk",
            "frost_stress",
            "drought_risk",
        ] and (value[0] == "medium" or value[0] == "high"):
            recommended.append("stress_buster")
        print(key)
        if key == "yield_risk" and (value[0] == "medium" or value[0] == "high"):
            recommended.append("yield_booster")
    return recommended


def get_daytime_heat_stress_risk_level(value):
    if value < 3:
        return "low"
    if value < 6:
        return "medium"
    if value <= 9:
        return "high"


def get_nighttime_heat_stress_risk_level(value):
    if value < 3:
        return "low"
    if value < 6:
        return "medium"
    if value <= 9:
        return "high"


def get_frost_stress_risk_level(value):
    if value < 3:
        return "low"
    if value < 6:
        return "medium"
    if value <= 9:
        return "high"


def get_drought_risk_level(value):
    if value >= 1.3:
        return "low"
    if 1.3 > value > 0.7:
        return "medium"
    if value <= 0.7:
        return "high"


def get_yield_risk_level(value):
    if value < 250:
        return "low"
    if 250 <= value <= 600:
        return "medium"
    if value > 600:
        return "high"
