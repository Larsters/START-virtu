def calculate_gdd(weather_data, base_temp):
    """
    Given a list of dicts: [{tmax, tmin, date}, ...], compute total GDD.
    GDD for each day = ((Tmax + Tmin)/2) - base_temp, if > 0 else 0
    """
    total_gdd = 0
    for day in weather_data:
        avg_temp = (day["tmax"] + day["tmin"]) / 2
        daily_gdd = avg_temp - base_temp
        if daily_gdd < 0:
            daily_gdd = 0
        total_gdd += daily_gdd
    return round(total_gdd, 2)

def calculate_yield_risk(crop_type, GDD, Precipitation, pH, N_Actual):
    """
    Use your existing yield risk formula.
    """
    crop_optimal_values = {
        "Soybean": {"GDD_opt": 2700, "P_opt": 575, "pH_opt": 6.4, "N_opt": 0.013},
        "Corn": {"GDD_opt": 2900, "P_opt": 650, "pH_opt": 6.4, "N_opt": 0.115},
        "Cotton": {"GDD_opt": 2400, "P_opt": 1000, "pH_opt": 6.3, "N_opt": 0.072},
    }
    w1, w2, w3, w4 = 0.3, 0.3, 0.2, 0.2
    opt = crop_optimal_values[crop_type]

    yield_risk = (
        w1 * (GDD - opt["GDD_opt"])**2 +
        w2 * (Precipitation - opt["P_opt"])**2 +
        w3 * (pH - opt["pH_opt"])**2 +
        w4 * (N_Actual - opt["N_opt"])**2
    )

    return round(yield_risk, 2)