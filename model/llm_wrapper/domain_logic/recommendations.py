def recommend_fertilizer(crop_type, yield_risk, pH, N_Actual):
    """
    Which fertilizer to use based on yield risk, pH, N_Actual.
    """
    product = None
    if yield_risk > 1000:
        product = "Stress Buster"  # placeholder
    else:
        product = "Yield Booster"
    
    return {
        "product": product,
        "application_advice": "Apply at the V4 stage"  # example
    }